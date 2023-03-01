pragma solidity 0.8.14;
pragma experimental ABIEncoderV2;

import "./Structs.sol";
import "./BLSAggregatedSignatureVerifier.sol";
import "./PoseidonCommitmentVerifier.sol";
import "./libraries/SimpleSerialize.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

uint256 constant OPTIMISTIC_UPDATE_TIMEOUT = 86400;
uint256 constant SLOTS_PER_EPOCH = 32;
uint256 constant SLOTS_PER_SYNC_COMMITTEE_PERIOD = 8192;
uint256 constant MIN_SYNC_COMMITTEE_PARTICIPANTS = 10;
uint256 constant SYNC_COMMITTEE_SIZE = 512;
uint256 constant FINALIZED_ROOT_INDEX = 105;
uint256 constant NEXT_SYNC_COMMITTEE_INDEX = 55;
uint256 constant EXECUTION_STATE_ROOT_INDEX = 402;
uint256 constant BLOCK_NUMBER_ROOT_INDEX = 406;

contract BeaconLightClient is PoseidonCommitmentVerifier, BLSAggregatedSignatureVerifier, Ownable {
    bytes32 public immutable GENESIS_VALIDATORS_ROOT;
    uint256 public immutable GENESIS_TIME;
    uint256 public immutable SECONDS_PER_SLOT;

    bool public active;
    bytes4 public defaultForkVersion;
    uint64 public headSlot;
    uint64 public headBlockNumber;
    uint256 public latestSyncCommitteePeriod;

    mapping(uint64 => uint64) public slot2block;
    mapping(uint64 => bytes32) public executionStateRoots;
    mapping(uint256 => bytes32) public syncCommitteeRootByPeriod;
    mapping(bytes32 => bytes32) public sszToPoseidon;

    event HeadUpdate(uint64 indexed slot, uint64 indexed blockNumber, bytes32 indexed executionRoot);
    event SyncCommitteeUpdate(uint64 indexed period, bytes32 indexed root);

    constructor(
        bytes32 genesisValidatorsRoot,
        uint256 genesisTime,
        uint256 secondsPerSlot,
        bytes4 forkVersion,
        uint256 startSyncCommitteePeriod,
        bytes32 startSyncCommitteeRoot,
        bytes32 startSyncCommitteePoseidon
    ) {
        GENESIS_VALIDATORS_ROOT = genesisValidatorsRoot;
        GENESIS_TIME = genesisTime;
        SECONDS_PER_SLOT = secondsPerSlot;
        defaultForkVersion = forkVersion;
        latestSyncCommitteePeriod = startSyncCommitteePeriod;
        syncCommitteeRootByPeriod[startSyncCommitteePeriod] = startSyncCommitteeRoot;
        sszToPoseidon[startSyncCommitteeRoot] = startSyncCommitteePoseidon;
        active = true;
    }

    modifier isActive {
        require(active, "Light client must be active");
        _;
    }

    modifier verifyLightClientUpdate(LightClientUpdate calldata _update) {
        _verifyLightClientUpdate(_update);
        _;
    }

    /*
    * @dev Returns the execution state root for a given slot.
    */
    function executionStateRoot(uint64 slot) external view returns (bytes32) {
        return executionStateRoots[slot];
    }

    /*
    * @dev Updates the execution state root given a finalized light client update. The primary conditions for this are:
    *   1) At least 2n/3+1 signatures from the current sync committee where n = 512
    *   2) A valid merkle proof for the finalized header inside the currently attested header
    */
    function update(LightClientUpdate calldata update) external isActive verifyLightClientUpdate(update) {
        _update(update);
    }

    function _update(LightClientUpdate calldata update) internal {
        require(update.finalizedHeader.slot > headSlot, "Update slot must be greater than the current head");
        require(update.finalizedHeader.slot <= getCurrentSlot(), "Update slot is too far in the future");

        headSlot = update.finalizedHeader.slot;
        headBlockNumber = update.blockNumber;
        slot2block[update.finalizedHeader.slot] = update.blockNumber;
        executionStateRoots[update.blockNumber] = update.executionStateRoot;
        emit HeadUpdate(update.finalizedHeader.slot, update.blockNumber, update.executionStateRoot);
    }
    /*
    * @dev Set the sync committee validator set root for the next sync committee period. This root is signed by the current
    * sync committee. To make the proving cost of zkBLSVerify(..) cheaper, we map the ssz merkle root of the validators to a
    * poseidon merkle root (a zk-friendly hash function)
    */
    function updateWithSyncCommittee(
        LightClientUpdate calldata update,
        bytes32 nextSyncCommitteePoseidon,
        Groth16Proof calldata commitmentMappingProof
    ) external isActive verifyLightClientUpdate(update) {
        _update(update);

        uint64 currentPeriod = getSyncCommitteePeriodFromSlot(update.finalizedHeader.slot);
        uint64 nextPeriod = currentPeriod + 1;
        require(syncCommitteeRootByPeriod[nextPeriod] == 0, "Next sync committee was already initialized");
        require(SimpleSerialize.isValidMerkleBranch(
                update.nextSyncCommitteeRoot,
                NEXT_SYNC_COMMITTEE_INDEX,
                update.nextSyncCommitteeBranch,
                update.finalizedHeader.stateRoot
            ), "Next sync committee proof is invalid");

        zkMapSSZToPoseidon(update.nextSyncCommitteeRoot, nextSyncCommitteePoseidon, commitmentMappingProof);

        latestSyncCommitteePeriod = nextPeriod;
        syncCommitteeRootByPeriod[nextPeriod] = update.nextSyncCommitteeRoot;
        emit SyncCommitteeUpdate(nextPeriod, update.nextSyncCommitteeRoot);
    }

    /*
    * @dev Implements shared logic for processing light client updates. In particular, it checks:
    *   1) Does Merkle Inclusion Proof that proves inclusion of finalizedHeader in attestedHeader
    *   2) Does Merkle Inclusion Proof that proves inclusion of executionStateRoot in finalizedHeader
    *   3) Checks that 2n/3+1 signatures are provided
    *   4) Verifies that the light client update has update.signature.participation signatures from the current sync committee with a zkSNARK
    */
    function _verifyLightClientUpdate(LightClientUpdate calldata update) internal view {
        require(update.finalityBranch.length > 0, "No finality branches provided");
        require(update.executionStateRootBranch.length > 0, "No execution state root branches provided");

        // Potential for improvement: Use multi-node merkle inclusion proofs instead of 2 separate single proofs
        require(SimpleSerialize.isValidMerkleBranch(
                SimpleSerialize.sszBeaconBlockHeader(update.finalizedHeader),
                FINALIZED_ROOT_INDEX,
                update.finalityBranch,
                update.attestedHeader.stateRoot
            ), "Finality checkpoint proof is invalid");

        require(SimpleSerialize.isValidMerkleBranch(
                update.executionStateRoot,
                EXECUTION_STATE_ROOT_INDEX,
                update.executionStateRootBranch,
                update.finalizedHeader.bodyRoot
            ), "Execution state root proof is invalid");
        require(SimpleSerialize.isValidMerkleBranch(
                SimpleSerialize.toLittleEndian(update.blockNumber),
                BLOCK_NUMBER_ROOT_INDEX,
                update.blockNumberBranch,
                update.finalizedHeader.bodyRoot
            ), "Block number proof is invalid");

        require(3 * update.signature.participation > 2 * SYNC_COMMITTEE_SIZE, "Not enough members of the sync committee signed");

        uint64 currentPeriod = getSyncCommitteePeriodFromSlot(update.finalizedHeader.slot);
        bytes32 signingRoot = SimpleSerialize.computeSigningRoot(update.attestedHeader, defaultForkVersion, GENESIS_VALIDATORS_ROOT);
        require(syncCommitteeRootByPeriod[currentPeriod] != 0, "Sync committee was never updated for this period");
        require(zkBLSVerify(signingRoot, syncCommitteeRootByPeriod[currentPeriod], update.signature.participation, update.signature.proof), "Signature is invalid");
    }

    /*
    * @dev Maps a simple serialize merkle root to a poseidon merkle root with a zkSNARK. The proof asserts that:
    *   SimpleSerialize(syncCommittee) == Poseidon(syncCommittee).
    */
    function zkMapSSZToPoseidon(bytes32 sszCommitment, bytes32 poseidonCommitment, Groth16Proof calldata proof) internal {
        uint256[33] memory inputs;
        // inputs is syncCommitteeSSZ[0..32] + [syncCommitteePoseidon]
        uint256 sszCommitmentNumeric = uint256(sszCommitment);
        for (uint256 i = 0; i < 32; i++) {
            inputs[32 - 1 - i] = sszCommitmentNumeric % 2 ** 8;
            sszCommitmentNumeric = sszCommitmentNumeric / 2 ** 8;
        }
        inputs[32] = uint256(poseidonCommitment);
        require(verifyCommitmentMappingProof(proof.a, proof.b, proof.c, inputs), "Proof is invalid");
        sszToPoseidon[sszCommitment] = poseidonCommitment;
    }

    /*
    * @dev Does an aggregated BLS signature verification with a zkSNARK. The proof asserts that:
    *   Poseidon(validatorPublicKeys) == sszToPoseidon[syncCommitteeRoot]
    *   aggregatedPublicKey = InnerProduct(validatorPublicKeys, bitmap)
    *   BLSVerify(aggregatedPublicKey, signature) == true
    */
    function zkBLSVerify(bytes32 signingRoot, bytes32 syncCommitteeRoot, uint256 claimedParticipation, Groth16Proof calldata proof) internal view returns (bool) {
        require(sszToPoseidon[syncCommitteeRoot] != 0, "Must map SSZ commitment to Poseidon commitment");
        uint256[34] memory inputs;
        inputs[0] = claimedParticipation;
        inputs[1] = uint256(sszToPoseidon[syncCommitteeRoot]);
        uint256 signingRootNumeric = uint256(signingRoot);
        for (uint256 i = 0; i < 32; i++) {
            inputs[(32 - 1 - i) + 2] = signingRootNumeric % 2 ** 8;
            signingRootNumeric = signingRootNumeric / 2 ** 8;
        }
        return verifySignatureProof(proof.a, proof.b, proof.c, inputs);
    }

    function getCurrentSlot() internal view returns (uint64) {
        return uint64((block.timestamp - GENESIS_TIME) / SECONDS_PER_SLOT);
    }

    function getSyncCommitteePeriodFromSlot(uint64 slot) internal pure returns (uint64) {
        return uint64(slot / SLOTS_PER_SYNC_COMMITTEE_PERIOD);
    }

    function setDefaultForkVersion(bytes4 forkVersion) public onlyOwner {
        defaultForkVersion = forkVersion;
    }

    function setActive(bool newActive) public onlyOwner {
        active = newActive;
    }
}
