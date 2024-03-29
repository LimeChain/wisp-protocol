// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./../src/crc-messages/inbox/optimism/OptimismInbox.sol";

import {Types as CRCTypes} from "./../src/crc-messages/libraries/Types.sol";
import {Types as OptimismTypes} from "extractoor-contracts/library/optimism/Types.sol";
import {SimpleLightClient} from "extractoor-contracts/L2/SimpleLightClient.sol";

contract MockLightClient is SimpleLightClient {
    constructor(address owner) SimpleLightClient(owner) {}
}

contract MockTargetReceiver is IMessageReceiver {
    function receiveMessage(
        CRCTypes.CRCMessageEnvelope calldata envelope,
        uint256 sourceChainId
    ) external returns (bool success) {
        return true;
    }
}

contract FailingTargetReceiver is IMessageReceiver {
    function receiveMessage(
        CRCTypes.CRCMessageEnvelope calldata envelope,
        uint256 sourceChainId
    ) external returns (bool success) {
        payable(0x0).transfer(1 ether);
    }
}

contract OptimismInboxTest is Test {
    OptimismInbox public inbox;

    address public constant outputOracleAddress =
        0xE6Dfba0953616Bacab0c9A8ecb3a9BBa77FC15c0;

    address public constant messageTarget =
        0x058A39bEFBBA6a41e1CcBE97C3457dcc894B0fF2;
    uint64 public constant targetL1BlockNum = 8529353;
    bytes32 public constant targetL1StateRoot =
        0xd743b1d6e0e5964666245e144c84184d69dd9a1123b4091ed7e6e5b88ebaca75;
    uint256 public constant destinationChainId = 31337;

    address public constant sender = 0xe42682eEa1DFC432C2fF5a779CD1D9a1e1c7f405;
    uint256 public constant outputIndex =
        0x00000000000000000000000000000000000000000000000000000000000038c5;

    uint8 public constant protocolVersion = 0;
    uint64 public constant messageNonce = 12;
    bytes public constant payload = hex"00";
    uint256 public constant stateRelayFee = 21;
    uint256 public constant deliveryFee = 42;
    bytes public constant extra = hex"00";

    bytes32 public constant optimismStateRoot =
        0x0be474c5d51154dda88b82a1104daa7a11c0af2df18e9ba53c3c548e731c890b;
    bytes32 public constant withdrawalStorageRoot =
        0x3b68b6c6c479aa4ee368f0d0162b7e649dfd8fe0578b3ac2da21bce869002ed7;
    bytes32 public constant latestBlockhash =
        0x77a309c22c569bf77d4062865ffccf1a1e9e96cf66b566a085638e58c103999a;

    address public constant crcOutboxAddress =
        0xcA7B05255F52C700AE25C278DdB03C02459F7AE8;
    bytes32 public constant slotPosition =
        0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e564;

    bytes public constant optimismStateProofsBlob =
        hex"f9140cf90c93f90211a015668fd24d681352ec493452131df0033b9ec9b26cfea40fe6d6af603253c340a0975570ffcee49b0c63afa763de250a07b4bf79f06b649d64ceb93e4f38ecc5afa09541f8876332264c80f7da4e9c93d03d9bf8e30297757dc54f07e71de9695d9da0ffa833e1cb5167d59bc62bc0d5e09f0f2be624a42e882ea9a4a347d384f908d4a0cbb29d094260953d88491d903a3d2728432eaf609314afa27b25d03700540d0da03c566b069c9b4d5112ddd6580b31eedeff530870fe7718dfbf0987fe96b32cefa082d37219a78fd96553e14d8d4c549270a0e8826352cfae719dbd4934df38eca6a0ac7652bda6dcc7ecee91a92f011e39546d4cdff8d07b4556076fefa2fdd52562a0cbdc84c9f6566a09eb44b2433e0adf72ce5e8ba8272f8142f7a77ea09591cdeea0e574046b638c6b28533dd00f8953ec09eb513c1145726ff3ea543595c68c312da0b9eaa684b40b5226325c7442985bd1727d80c3e7091a7434e9769f2ad4796915a02fb7ee7834eae43d0dbf328738dc1559215d3dcf7d99c426aa761e4944280b5ca0e9e720c7a998547c93e8013b1a4912145e0cd8f5d82e6006cec0618686b268b8a0126e819c80da70b75df0b3c1a318c9f40f6a98aaf1786228a300ef5a60db3a8fa0e5574d7544b5263a1c9aa83c0df954a99f5a66b54ffc356a2fafa501d47dca21a0fd93925a44b70222312dfb43d7c11ee045e36b3e76bd02f87feb226013a1e6e780f90211a0ff3a4da5561d299599c574a7d25285f37168b8cb6a1ebdbac1d5c57ac9a47cb3a099ddbef234e3cef270ad670d74a0c63ec233e113c55c7c9860fae53f7afcdca6a0f4ff50eb049a20f3e7fe303113a428161c5cc413bbc751099677bbef81d85e6ca0e99729c27cb6e54140bac9e3227211132d83b9e5f5bf1e98d621a21544c938eca0bec40b35ffa824282f621754d05aac1af49117496ae23bc52a22b35725a2bebca03e567c9865ed43af0abea6eed2b30fa7134095f214d6ce2bb60ccce54328c421a0063f5a795a98824b16c278b8e94177907e890765dff30674d6c4e57f0352f492a036abb4fca7579d890f41768dc0c6b7c901cfa3543a89d49027e9c7bf3c5376f4a06fc23cd1494057c0ae33e66afc1a17a128496881f8aae271fb5dc23faad7555da0a6f6c41cd6c9c9e661a9bee826036b7e63e27bdfe6f047cff186dfb99df64851a05042a05bc8c03ad6588f27e36ecc55a3f49d5722043c4c8293be8bb6655bc406a02663218124b0153b5912b53e9f31906317cbe015a445c6fb8e140f1b19adadeea04890ac654ed3e6eb71136417fc379f6e3a3fb1805f5267c31e166d44a6759496a07838e8ff4393a8393d1bfdb00e09dfaa66dc796bc8ffd80f3e1db2e06c65cd9ea0da874ed7069efc5d269d27e0ed37aff61c414d8ed3fcf52197fb826c3dcdee91a002817cc4a03da8f49a20a33ac6a3147be3ed4c0a5922cce6d72a8d2d44573ef780f90211a0acbdbf9f4662bc65df26cf0f5c966ca34e28eb4d472142d10709f866f15c5524a016e40cf504a57d3ce908b1ab448da0936ab7fae3777f7fbc2589cf8b1b011ca9a0a12bf59e47bb2c6e5b519f995aa2ff8d421c4b3629f0ddb84f240bbd04bf4811a0b06be1797e188fb64c49b6385b5da81f18823ed7d48e409c750199cf2ff2c056a032f8c305cd0474be0ff738a748b42e3a68eaefe86929186f3fae624fe636f2a7a0b98aa5e77615fcf4bae898d838e31c08b27f8363b7943232a91634b38cdc9337a070f5f7a089ea11a11c446faac4fa69d5b79085fe4b7e907385936d0738cf8285a05f3065fde36f5edfd37b8dd57e7e4e1fdf98bc16100fe23d9686f61a1a4ccb94a04641af62f416d59d50b208146aa7e98e4822b3a9f4c4e8f2b936a3584f69b9f9a028d83784f7521f224112339f10d4f796097b663d72d91236ac1b2aeb7a3638bca080311f1aa44ec115a6e42e9b74ef13b2c0a06c21f5768587b68e876c19bd28f8a0e058b929cd911712e34b34046c73575ccf4a9f6818a45897398be8e5fd6d38b7a00d75509138defb148e0affad084cce733391e7bbdcf9dcf3924c52d63ea19f9fa056acd5ff11ec93fab7abcfc213890763c82e1aada218e15c7e4bbd2ed3aabfcca05f5d27b2edf0e86d0760d7cd238d5ce47be1f3c70cc7bf3cc7a9b895d32c7ca2a0b52bb32dffe70af728a7e84d907f89e04fab4bc86a58b129fd5ab0fc6f6b829f80f90211a00125054413b0cc437c80d3c0547554781c7ad1ae56037249cc0dbde39f31b6a2a05d72e07843d44d04096461b3fb66f384a415c51b9f9f3df8284c5deb89161194a0301d32805b95292de9447b8acdd99c8d31508bc72a55bfec4d0d53d8fbc2f9f0a048c673b2b1af08987343ae887817d74ff177dff6a65aab242abe1c7589500b19a09b38d28b89ba22373aa8e90d2540489752c9a0b2262850eb415ea05dd095aae5a0ecbb9832b7c5cf7e7f9d961445c6cd7c172de7c3e3d8812009ec40596f2af479a0f4730a5a950868979751a5b93027fdce1676ef59dc0fd80a426c154d67812133a086239cef5a83506d8401d21204bb4e39c2ffb9af0cdac853a431f1bf853be88ea0f2ea15ea04e3a6788dbe5fb4d8d2d44234be89d91cd70fe5c2bfb489087b5384a05120d3414ce35f702e498e0e3ff850e78f8d82f28b435f54f969c8ec902d204ba076602cdb8e42c3d2623b9f7097ffbcf48a8a1f4719d35d5a90b9b7db7988d8dba06c94c462665d1cf53ae626f25eaa75e252df707e7de4eb4cdfc5ee44795fbd0da05b68fda1217213b1ecc897270432481bfbe06ecbbb63322ed8bdcd14b7de8984a0452119ccbc024f7bf75c487c4aabca9c3f2ee8b404b32a33633d7d8a3ad5dfc6a042755a7a0db221e4dd71f5e7b363059ab6e961f3a3ba5dc1e82aac06461653fca061382dbd36e59dccf96f3cc237b48e293a25cbc10ed5fc5ee9e534408a222dcf80f90211a024aeddb5ea834caf7c5b0a7f95b0c34e5e4dca39198662f075bcbe6bd8913504a094bf7bd47a7209895e76815cb830fe54052a03bccbcd44f5f45f11df5cff42bea0329e9f756290dd6eddb7b4c9a623b9d764fbd0f8426e061c6dd31f5c158ff2c2a092ae7cfbebf0b4c2c58e25927a0de8fc4d9363789d75abf06c91a68dcce83787a097dac9795372b9eecdfd2aff092654c1877a0cf163ba62516d2b8811824e6cfea07d7fef6fae2b1db8946ab12b3e294cd1233f3739681d784d093b096d79d5fc24a06e71559561fb265bb289300c259526d95ab3f521e6cd445248a48e8cae9e82c1a0aa3a0ccd7573a95e713048611cba6f5a2cde8c44dd4600cb8f4c9d071552d915a025a60c1cf33d0b2e386c8ad982135f25c3cca86460bc68ff786c2d9669d539fea0121034a425cbe20ea175c23c829ad8fa8b4be84544129bf021a64bca2c0a43dea0704ee8c7f80906550e6d354ad76552727dfb14bee7030508e3ede0e150d95ae5a0d8a16b0cf534ba352261e415a5e6e621e48d03c35ca9a0d662fd7ffc64d27c95a00e4373d299bf9c2053855ae2060fcc431e11914a7352b97c35df4a2819b93242a0721642b3678b61a42b6ccb4f63c04087d1cb997e3c4b71aaf3b269382c0a7cada03674d08036deca1ab18c30c30c40d3b610d0c0468cca91c5bad4ffbd9843f815a0fc03a5241d382ea0d91b8e4dd4998b9e1586dd7e38d0e3adff2acafe1528940f80f90151a0250fd44548b7db972c2850a9b6f9f1cdc38852c97a5dc3b94db0e8ca89a4b9188080a09c61fc8d25e7abf4ea1e605071352c460ea20580d412da62b73fb357d4bd2870a05e70e3faa7e298e447b9bc163969f98d9896fbd82e9e5a50f9579b8cf0708296a0b752d5a5811807a622a01d87081f4a6817fb7daa2ba97bdb6974ba706759532ca061bcf629693fc0f1df9919434f7ed1dc3b073ab201d3ae42d9a2f62b7d3de3d780a0447a1b87e78f2a02d2c042fae3e9c344587186cd3370ea89fa8668c188383e5d8080a07fe14166970101d34cbf476fa4f18b3bac46d4a764775539e12a2156c83590efa0feba2ed701770913c6bfdd619436157ff95b03e5c8dc7c9f115f5cc0fb55ca70a002331aeb4823d537dd9c76165ac4627cf487b8c6f002b46fcfbb552f9affd97b80a01129082da2030c42d4982fec7dd446fff6b885d9f86fe395fe2711649d3c27c180f8718080a07e1b01dbc4dd963a24521e6ca1fab940cbce7d3d554d7cc829649fd31c34033e80a05c2737c7d6818ee4248d136ef7b262bdb8b8b46b5cd87cd60d9cfdd68305ed1f80a08f00f4e9ba8cd5f3996b984d2d21ca48a9306e3a742d2b5413bfa158d12c7ebd80808080808080808080f8669d342b28574dad1179c95f6118bb5117b4b78c6afba7e20082d091b8a702b846f8440180a0045a7cac748a1a9dcb4613323af05c9f66ec2c3c98ca8b6cfc732e56cb7d9606a01f958654ab06a152993e7a0ae7b6dbb0d4b19265cc9337b8789fe1353bd9dc35f90773f90211a06e3d83f552b00bc4ca936d0bf21f9d76a860a714a056d1a7d501dce5e69fe9bfa006fe0e6728a62f3f3796aee8c629ba0b7566460218fd577df713a7eaceb19986a057257d3bd26ce92c42a90b0504b0b2411e961b36d02d023d94421c67c23d5d44a04f95620b9269a944e13ac7a14a68443384e3fd045a5b779a92dc3fb14224ff14a0a32a35f8e6f85b54a53db020e660fefe9e985a55fe7d08db590baafa151661b4a004dab792661f91a174d1b1af5b55f2fbb7dfcc0ca40e590f70db5d00c43ebd32a0b49d07a77479c1535e84fe8c3e9adf9cf1b1811221e2c129ba92b61aea42a6b7a0240ea1a30b37c3a50c137752010d100c8c90bbfb706f2212b8dfbc1fdc9f1ba9a0d1dbccc59d0f6ff653983d65695204532c4bdbaf699649a967cfacb8e2030d45a0f52d414bd92e61312e3384e4f1c2089f804b0209505b27947947d5c4b508949ea0ecce1dfe7a978a2e025889a6b5dd176fb888a5f1b56f15007198070ad4248af5a014d6235b1a08fc122de8aedbdf9bddbda4077fd753ace52381ed2a5bc375fd80a0bae0cc34a17fc3f9f09d805fa788beadb384e7c98a42e0c12f55e6d0c1c3ead5a0213839082dbf1ba2e73deddeb1a8ed82992bcd5e42591f27005b9b6e30f10b70a03a969a0df9f2d31ad8ca687846b4ed0f04d3459659d89749832a8240db6669b0a04cc2d6248d0c3e3ad35d0e874c53bc1db37a47994d538f12e95e7a99236b3bf080f90211a022e96ec9b68a379524f11046b0fe3fef0790c03694f4cc8462985af2959d19caa0f739d1d22816f1d742ae516437c8e96b7748d23552f4541def3101ce44137863a0cd829ad6864b090b57b62bbf4bd884aa1fa2678ba00c4dd40aceac1b06fb72f0a064545ad4eeb5ff4f0c6684910d18f7239d41c1f9eb81443ab6c82eef6d760774a00150643268d09c0db8722e6053e3ee2d528bd690cdffdd8dac8d172043c65932a07ce3dae740875a61981f8d9a431d12f4df06728c378cdb1bf15276464dfc827fa05868cce6ddbce0f3a42d460c07588078e155d3fe06557c3b00c6cb4a31c109a6a02493e9f3f8f25c38b501556fbacdbd235eea7c5f239f1e4ea4bcc78f63f7ecfda0030465f768891cf9cbdddfbf21464bf44f2f79f0143d93bf1a8729379950c8d9a078772fa38b774a82334590e4a21cb648e55bafc877d2e0de70ca1786ef96a13da0cbcc6106332f7f125059e1bb6b705127f5a8f897809eaa9efdc9fdb494bc3b59a075366d54053c71ffdbb89cccd248c62dbc2e044971bfd88cf20953864eb29092a0be5c936a346e45e8c69dedd3c7b9a9f92ad023cc6147ff58b24af69961299551a01851fcc60c75990eb62a20caa76ce31aa2d4af1f57c795f4657ededb9bab19bca0e153fc02457dc74dfa1a348af437faf20094814bd6100e8e29072a91a4a3ce57a0a9036db021e101c19835f4ff35b87f94303f4e076b131e86e86734d76c6960b980f90211a0a4e480577b7fdbd3ec998abdd951cbeaaa67c296d9d197a21b73633ad13cdad3a0d6012e688d9dfea923d07407e1db3fc5905868792f7548a42108c4c7bd490050a043ee451b688a32e4314761810b10fa90a4d87324d522d640c56591b281804b22a0223146ed3ef85710442816200fdba75f8fb225238fe5f87df79f89f61c553ddfa0a78331311a23cf4eb9c47d46f9c24a145adc67ccaba42942a22847d8d6a7d001a0f610e248e53a7804dfa7c1cb0acb0f9e7127dd3e4d608f5cac9dcf112d029e57a09406f27695fa6842ee9fcc2405a18b8095f4ccd0225f9cc3d682aa01e19d70fea0687cfef8b1778648bd4bedcc4af93bf539bf53ea2f6e67955b64601a289c66cca0df46672760045ac7ff491dee0d59e3ee0f102478624e872a60b4b9a9255ffedfa07a13974a8e3b08166f618c5aafbc3e7b61c31e172ee716f46afd66b1d68d4c08a035a80728f0ae964476bb3cca71c20e3c5b423e68953d2d9f0983f1f1513f7851a034a7879f7237d785ae4fded6cc6381a2438a0ecb80d969f276a494caf838feeca0776f71ab953c13cac326a35e6a06c4ac2d801de005323351318c67427b5d4237a0c2986fbe531f043d3b4e4d3cbe4d91e4acfb2ee757f41767d067c3b9a39e33d2a0a051e58bba59ae97a6925c4e9416acd9404d53d9eb207c359bba9d67656c2db2a07f61a995620fda93d70272c13d848adbf1411769b443445cf96847b1a18fe00e80f8f1a02011b30d491439a4282fbd367d4594ca962a1de8d04e9f102628d838bc2418ac80a043f91ca860efff51a62454c272acaf85048649703123738bc534cd6a4d65abd9a079f8d704c66a133239ae1e3e7ec2eeffcccddfec8377a449795105a4b789f86a80a03a9eefcc4e1a495f9a49e4a2ea150abedffe065ffe545deb200e02b2cb51576180a03ff934404a23e0a31ca3a51c7a1bf4831629658ad041a91035a7934450544e1580a0908b374b03c4b639bd3633fc0c56d962a28b8d335be28aab960743fd8a5fdf8580808080a0dbc680f6c188c9a52a3b704b1ab3a10fd2fb6f1ffd9ecd968ce68edb297b75838080f8429f20c3034337b1befbb08a9f2c06485560de0bc85defc5b8727cc0ab2525e2cca1a018ac89ebccd36f2426481ee868e03b12f4994bee3fb00a6da3184ac663d72290";

    bytes public constant inclusionProofsBlob =
        hex"f90abcf909bff90211a077bb1a1e643a9253db2e39b8119c1898a3302f6fe41da7f170803415e011e55aa04c7c8ba78278661c9f3210edbed99528ac0427c42dfb14bf8c43e2d5a2294998a0032383fb0c163b2d34dc86eba3ee7c8cfbb3898630964dcb3409e90aa9d190fba051166ae548e4f090f65bf0cc7b18e052b9d0070af34301c4e465936ebc546cfda0e18305da7fe84628d9ceb638126414da0e988088819f295c06beea3f3ad84b92a0d896cfc46c953d8b140c92b7a2289c33cae45cd036ce3c6fcf7b617491fe99d7a083f2cdc8a395fdbb58589be42f2eb595ff731f0c68aa988b86f9edb57472aadfa0aa3b3c55ba1aad29538025ddf864cab50bddfc9348a6af350eff0a31dc607316a0b0b808fff294570915dfe241342117c81117b8b7525514877ed206c9fa9afda2a06116192ad108a0ee639585147971ce3939eef0df5840176b9d09540990c86d07a0c863c31d491e99ceee4327eb60b514e5c0234f9329adce874331e30c7765163ea09ba870d6d1d05ae3e8a853886cde2cb118cf1b183d9fed4ee47ba9d032580a15a07b87be735d3de2df7ef927d3e0158ba1759ef0fe17d3aefca20fd8553db48831a0f602f9d262e6477ef5fba19eb068041a4a49efc6765b75c14ef94667b6b74933a09789486415a3d2910b645af7bdc6008b65cf0b3154e8eef98732c79e4a94ff74a0d639862fb14f23d373f4529451a6688fff88b7bbae2e1fc98c026a72d4dca06280f90211a06c444830970bb467e3fc008c4af70f7fcadbe4db32196fab1b1ad939d3e7addea09c5c9f2f80159ece8f075c8af218007465a8bbdd8edaf0983e30ffed4af8f0c8a0d074e7d52ece1fca9120ee376b4212b51d1686051ba07b95fbd5bd1a905da1bba061aa8b15d01e64356b3fcb6884e47dce647c78b8e0adb8c496c7d42c533eb509a060a216bde8ef11ad6cd312a63b65cf72dfe35b06fdf97e71b4c0b0242f245e1aa0ae8112155f975b9b77fbf581756e4e6c920f38c69cbe1332427bfceef89533afa081797b94828ac342bdf9eb5fa4f40fbd954439091fbbc21ac9d72dc4483ce4a6a0a9cc1be026d3dd2f5e63bfc5c0be171ba2c96322169268fada5d2f9f385e3a6aa0abfc3a3445da28795c5bbdf5314cdba4df1a89d5ed4881f944cdbeb346e9a40ea0692d3db9594c30e7357269748299297035c62388317c2b5dd8445c5c87cb362ea0cdfb91a2c375113339d5de639ac33d3c5d103d9dd95e38e36fea86a5d83e0245a02c02a250a7f7ce7a5e391a497b411eaa5a98534e64306e7af7f0fe54bc44c618a009a988afb830f2b309fd5ddbf59adde22b6a1f7429b7253b19126d6e2c2d022ca04d8d032a36ee2a57ebed1ba97107168b2d6b4efeca3c68d29a701d02c1202341a0a0a405b37f5c106191ab0a6bdd704c9282b178a6cd25ea409fdafab87ca36e30a0c334ccd44477fc93b078970b590044fde36d033be1e85464941a9ebcd32eedd480f90211a0153b57f1b6cb17b7354e1c45a3e33d5d04fbdcd9f52fe8dd94e70cd3978dfb08a0b4bf52e23a6153a956a874d308ac1b6f45fe5559ab1739e3f5b7aab09300b3bea07a7926a2803bb32ba5f8062842eed7c373607ae56e19938592cf26187365b633a0c9c3810b0a2361b858a06a697d5ffadf4f1efd7cbd57dd2912c8f9a9110cec8aa09c32289607ea435780c3674276c1f57238bdfceecca622b9e3bcfca82337823ca0dfd1026884bb5c03139967e88642c1acea875041bc19eb9ab51bd58c08170fc4a0965b8ee1eaf99e4eeb88d819fa9f0da25494b6ad2791d92e35e93d2f7b4ce30aa0ee06600b69e59cdda67c519fb046418a59feee2851e4bc6375aa25a1ee0174ffa073cdd098dd9e2569991859dc864b937b190549e8db48374ffaf92dcc3834ae9aa0994b592993f4bc7eebf64cedcfe25ad519bc0d5d47847bcc4a90cc9d2f19411ca0c639574621926c8cd5bcd4c532934a586e297f4adbba1237c6aefd0866d6270ca01918e34ccf7a1be828446ca2046904a89dd2714b463b784aed6bd029fe2a6f14a00d51c3f0247d9136b6eed4e901bbcf3bb5af7e6bde1994b83f93eccddad38c49a072ff531f7f11ba15ed59e8b9185e6e553978460d1209b1627600fc890c81f3d7a0cef7f32fe370cb89b8b9bfbdd038d6b7b65470ba8a341d788935184c7d9fab65a0dc8c6809684ec0664e5c973d2dbc4c8b5da8a001e26019ae180b6dea1f8cb43780f90211a0a0b118d0f6367bcb84a5660c462614eea9618dc4d0b82ca3e5172187baef1a25a0354d8d902d882825d98e576ed6441606a82bf18040803c9e3c0759a71244cc53a0886c4804a05446ef44ccd0750b5a7060a217d2e22414ae0c43f6309d180db9e6a065a12f078b78f5c1d841a21d03c22ff3ad1a816915c8fcc591515369fc789a3ca0377e2e4d731424efdef4a3649837db570d4ee6fe8c30a4ded0e65194d5c0b050a0ba759c481a3e9d9878d6d143e7662fc56038b75ccbfb15144137390bf616f8bda0f36fbd19f76a6665082aea200043eaf31d628055ed0109ce88cf68615e583174a00b2fffdd841ae9fc97f0092448d3935646a34ee32cd44358d3a7e8e89289e038a03f54c599b86365eb935613a968adc5ad23bb3f5d6bff4706fb6b00d2b0e067e6a0823b559fad1809cc7f0db7cabfe54943f201a0b69523ab010611c968c579b31fa044bf5f3b16bae07817ae6c2469db7ed703755f673de85927a08ad4d4814fcb2ca0606f3b8f9032f9024c9c91a87dfad89a5e64d89e2d96b95a07ce76c9ec265a47a09854256fd981ae13f4552b0fef40db7f61e8e6a3480b25ed81d709fd52ef2139a0796b77f85baa276920ea16eb5ce9f82771744bb9735a942fd9e9e41d6b47732da0a4a6672421e9b55ecf3c91bfcdd690089ac4a6181246062c886e95e6a9828578a0d529b7db2d415b43e26bd7744f2affc5c298013d83df902727c0d41c506bd71380f8b1a0fb3e47a5e14be5f041c1ded9f6d4aabf87110658eb3bd9bb72f5e7a7b4e1ef6a80a05b120570f7f4ae08cf3d90f6c739f16c1ee7f864e2d70f77dc801dd6ee5bc7f7a0df53a63bbae3e70c7fb9a3f4353f750536c9958bb79ed68d93bc50b7e27ccc77808080a0ad2854d9bb7485c587cbb332afacfc4f5c58d05706b2dbf2331b65958b8691e280808080a078506c05f73a7dfd75575cee5875bbebeff45ddf1e56f945788f7bd4778131b180808080f8518080808080808080808080a027364a8bc06ebfbf36ae70eca7b0e41a74d7cb8a6d641ec2ce549297f00ecb4180a0adba1ddad1e8e56ba4e17885c0f8d5a347ee23b55aee6bd8123bee5421a73fc7808080f8679e207b92894d70fca5f58dc3b808510dc16d5d83a3c25aff7e5943b35ccdd2b846f8440180a083d9abc4bdbb439f212abaaeef2dbe63cb32d0e82c4e42214558824de64e7689a0f9072b9b62ca5c39e950622d6b0615c32d6f91905807ed93fe40df9f2df832b8f8f8f8b18080a04e918b76be51be2f02df0ac6191ec2765d401d2229e47291806815da755f5b5e8080a0dfa55a167f624ed9f8a78e7b54acb7dadc38c41438a877ee892b6f9ac16bdb64a0c543fbe73665c46eebb396ebdd57e4a9eaf57eaf6ed6b3ce0fe62816c15281cca00f5ff4d9225f04f23c31352d96efdfcb7f2d9ffc11b0ebb1d61552685051e10380a0f55954014bfea9d8bbddc8ede1f1f4aefcb2ed3f124857629ba0b02ba07373e280808080808080f843a03c13d8c1c5df666ea9ca2a428504a3776c8ca01021c3a1524ca7d765f600979aa1a04971280f7abfa36cdfe04223913854da803f811cb8e4608da1711458c004b3d2";

    function setUp() public {
        MockLightClient _lightClient = new MockLightClient(address(this));
        _lightClient.setStateRoot(targetL1BlockNum, targetL1StateRoot);
        inbox = new OptimismInbox(address(_lightClient), outputOracleAddress);
        inbox.setChainIdFor(crcOutboxAddress, 5);
    }

    function testReceiveMessage() public {
        CRCTypes.CRCMessage memory message = CRCTypes.CRCMessage({
            version: protocolVersion,
            destinationChainId: destinationChainId,
            nonce: messageNonce,
            user: sender,
            target: messageTarget,
            payload: payload,
            stateRelayFee: stateRelayFee,
            deliveryFee: deliveryFee,
            extra: extra
        });
        CRCTypes.CRCMessageEnvelope memory envelope = CRCTypes
            .CRCMessageEnvelope({message: message, sender: sender});

        OptimismTypes.OutputRootProof memory outputProof = OptimismTypes
            .OutputRootProof({
                stateRoot: optimismStateRoot,
                withdrawalStorageRoot: withdrawalStorageRoot,
                latestBlockhash: latestBlockhash
            });

        OptimismTypes.OutputRootMPTProof memory outputMPTProof = OptimismTypes
            .OutputRootMPTProof({
                outputRootProof: outputProof,
                optimismStateProofsBlob: optimismStateProofsBlob
            });

        OptimismTypes.MPTInclusionProof memory inclusionProof = OptimismTypes
            .MPTInclusionProof({
                target: crcOutboxAddress,
                slotPosition: slotPosition,
                proofsBlob: inclusionProofsBlob
            });

        MockTargetReceiver _targetReceiver = new MockTargetReceiver();
        bytes memory code = address(_targetReceiver).code;
        vm.etch(messageTarget, code);

        vm.chainId(destinationChainId);
        inbox.receiveMessage(
            envelope,
            targetL1BlockNum,
            outputIndex,
            outputMPTProof,
            inclusionProof
        );

        bytes32 messageHash = inbox.getMessageHash(envelope); // TODO add test for getMessageHash

        assertEq(inbox.isUsed(messageHash), true);
        assertEq(inbox.relayerOf(messageHash), address(this));
    }

    function testRevertOnWrongDestination() public {
        CRCTypes.CRCMessage memory message = CRCTypes.CRCMessage({
            version: protocolVersion,
            destinationChainId: destinationChainId,
            nonce: messageNonce,
            user: sender,
            target: messageTarget,
            payload: payload,
            stateRelayFee: stateRelayFee,
            deliveryFee: deliveryFee,
            extra: extra
        });
        CRCTypes.CRCMessageEnvelope memory envelope = CRCTypes
            .CRCMessageEnvelope({message: message, sender: sender});

        OptimismTypes.OutputRootProof memory outputProof = OptimismTypes
            .OutputRootProof({
                stateRoot: optimismStateRoot,
                withdrawalStorageRoot: withdrawalStorageRoot,
                latestBlockhash: latestBlockhash
            });

        OptimismTypes.OutputRootMPTProof memory outputMPTProof = OptimismTypes
            .OutputRootMPTProof({
                outputRootProof: outputProof,
                optimismStateProofsBlob: optimismStateProofsBlob
            });

        OptimismTypes.MPTInclusionProof memory inclusionProof = OptimismTypes
            .MPTInclusionProof({
                target: crcOutboxAddress,
                slotPosition: slotPosition,
                proofsBlob: inclusionProofsBlob
            });

        MockTargetReceiver _targetReceiver = new MockTargetReceiver();
        bytes memory code = address(_targetReceiver).code;
        vm.etch(messageTarget, code);

        vm.chainId(destinationChainId + 1);
        vm.expectRevert("Message is not intended for this network");
        inbox.receiveMessage(
            envelope,
            targetL1BlockNum,
            outputIndex,
            outputMPTProof,
            inclusionProof
        );
    }

    function testRevertOnReplayReceive() public {
        CRCTypes.CRCMessage memory message = CRCTypes.CRCMessage({
            version: protocolVersion,
            destinationChainId: destinationChainId,
            nonce: messageNonce,
            user: sender,
            target: messageTarget,
            payload: payload,
            stateRelayFee: stateRelayFee,
            deliveryFee: deliveryFee,
            extra: extra
        });
        CRCTypes.CRCMessageEnvelope memory envelope = CRCTypes
            .CRCMessageEnvelope({message: message, sender: sender});

        OptimismTypes.OutputRootProof memory outputProof = OptimismTypes
            .OutputRootProof({
                stateRoot: optimismStateRoot,
                withdrawalStorageRoot: withdrawalStorageRoot,
                latestBlockhash: latestBlockhash
            });

        OptimismTypes.OutputRootMPTProof memory outputMPTProof = OptimismTypes
            .OutputRootMPTProof({
                outputRootProof: outputProof,
                optimismStateProofsBlob: optimismStateProofsBlob
            });

        OptimismTypes.MPTInclusionProof memory inclusionProof = OptimismTypes
            .MPTInclusionProof({
                target: crcOutboxAddress,
                slotPosition: slotPosition,
                proofsBlob: inclusionProofsBlob
            });

        MockTargetReceiver _targetReceiver = new MockTargetReceiver();
        bytes memory code = address(_targetReceiver).code;
        vm.etch(messageTarget, code);

        vm.chainId(destinationChainId);
        inbox.receiveMessage(
            envelope,
            targetL1BlockNum,
            outputIndex,
            outputMPTProof,
            inclusionProof
        );

        vm.expectRevert("Message already received");
        inbox.receiveMessage(
            envelope,
            targetL1BlockNum,
            outputIndex,
            outputMPTProof,
            inclusionProof
        );
    }

    function testTransactionSucceedsOnWrongMessageTarget() public {
        CRCTypes.CRCMessage memory message = CRCTypes.CRCMessage({
            version: protocolVersion,
            destinationChainId: destinationChainId,
            nonce: messageNonce,
            user: sender,
            target: messageTarget,
            payload: payload,
            stateRelayFee: stateRelayFee,
            deliveryFee: deliveryFee,
            extra: extra
        });
        CRCTypes.CRCMessageEnvelope memory envelope = CRCTypes
            .CRCMessageEnvelope({message: message, sender: sender});

        OptimismTypes.OutputRootProof memory outputProof = OptimismTypes
            .OutputRootProof({
                stateRoot: optimismStateRoot,
                withdrawalStorageRoot: withdrawalStorageRoot,
                latestBlockhash: latestBlockhash
            });

        OptimismTypes.OutputRootMPTProof memory outputMPTProof = OptimismTypes
            .OutputRootMPTProof({
                outputRootProof: outputProof,
                optimismStateProofsBlob: optimismStateProofsBlob
            });

        OptimismTypes.MPTInclusionProof memory inclusionProof = OptimismTypes
            .MPTInclusionProof({
                target: crcOutboxAddress,
                slotPosition: slotPosition,
                proofsBlob: inclusionProofsBlob
            });

        vm.chainId(destinationChainId);
        inbox.receiveMessage(
            envelope,
            targetL1BlockNum,
            outputIndex,
            outputMPTProof,
            inclusionProof
        );
    }

    function testTransactionSucceedsOnRevertingTarget() public {
        CRCTypes.CRCMessage memory message = CRCTypes.CRCMessage({
            version: protocolVersion,
            destinationChainId: destinationChainId,
            nonce: messageNonce,
            user: sender,
            target: messageTarget,
            payload: payload,
            stateRelayFee: stateRelayFee,
            deliveryFee: deliveryFee,
            extra: extra
        });
        CRCTypes.CRCMessageEnvelope memory envelope = CRCTypes
            .CRCMessageEnvelope({message: message, sender: sender});

        OptimismTypes.OutputRootProof memory outputProof = OptimismTypes
            .OutputRootProof({
                stateRoot: optimismStateRoot,
                withdrawalStorageRoot: withdrawalStorageRoot,
                latestBlockhash: latestBlockhash
            });

        OptimismTypes.OutputRootMPTProof memory outputMPTProof = OptimismTypes
            .OutputRootMPTProof({
                outputRootProof: outputProof,
                optimismStateProofsBlob: optimismStateProofsBlob
            });

        OptimismTypes.MPTInclusionProof memory inclusionProof = OptimismTypes
            .MPTInclusionProof({
                target: crcOutboxAddress,
                slotPosition: slotPosition,
                proofsBlob: inclusionProofsBlob
            });

        FailingTargetReceiver _targetReceiver = new FailingTargetReceiver();
        bytes memory code = address(_targetReceiver).code;
        vm.etch(messageTarget, code);

        vm.chainId(destinationChainId);
        inbox.receiveMessage(
            envelope,
            targetL1BlockNum,
            outputIndex,
            outputMPTProof,
            inclusionProof
        );

        bytes32 messageHash = inbox.getMessageHash(envelope);

        assertEq(inbox.isUsed(messageHash), true);
        assertEq(inbox.relayerOf(messageHash), address(this));
    }
}
