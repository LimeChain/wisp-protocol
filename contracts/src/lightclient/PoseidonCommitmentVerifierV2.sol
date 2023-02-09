pragma solidity 0.8.14;

import "./libraries/Pairing.sol";

contract PoseidonCommitmentVerifierV2 {

	struct PoseidonCommitmentVerifyingKey {
		Pairing.G1Point alfa1;
		Pairing.G2Point beta2;
		Pairing.G2Point gamma2;
		Pairing.G2Point delta2;
		Pairing.G1Point[] IC;
	}

	struct PoseidonCommitmentProof {
		Pairing.G1Point A;
		Pairing.G2Point B;
		Pairing.G1Point C;
	}

	function poseidonCommitmentVerifyingKey() internal pure returns (PoseidonCommitmentVerifyingKey memory vk) {
		vk.alfa1 = Pairing.G1Point(
			20491192805390485299153009773594534940189261866228447918068658471970481763042,
			9383485363053290200918347156157836566562967994039712273449902621266178545958
		);

		vk.beta2 = Pairing.G2Point(
			[4252822878758300859123897981450591353533073413197771768651442665752259397132,
			6375614351688725206403948262868962793625744043794305715222011528459656738731],
			[21847035105528745403288232691147584728191162732299865338377159692350059136679,
			10505242626370262277552901082094356697409835680220590971873171140371331206856]
		);
		vk.gamma2 = Pairing.G2Point(
			[11559732032986387107991004021392285783925812861821192530917403151452391805634,
			10857046999023057135944570762232829481370756359578518086990519993285655852781],
			[4082367875863433681332203403145435568316851327593401208105741076214120093531,
			8495653923123431417604973247489272438418190587263600148770280649306958101930]
		);
		vk.delta2 = Pairing.G2Point(
			[18786680396777194796086991707264341469485266483672204696181238523481704834964,
			4643824748117722983483541185379427666564303011432234388830668536908214439350],
			[12263711157414915835936369286382011310282535806363279116890586062818913031598,
			6018062989053396856532861398969952450040359375406865984740999732630529317298]
		);
		vk.IC = new Pairing.G1Point[](34);

		vk.IC[0] = Pairing.G1Point(
			21763191512158685577083517911933799197606673810451844309858440329036250324600,
			13726473062263927792360003979531240924495589049640333826477495406519668951418
		);

		vk.IC[1] = Pairing.G1Point(
			1365562294947090782239512887790873526331609535427698669936023650116102904829,
			3174633668773209142146253692078489085637203875303636500263231551278224608624
		);

		vk.IC[2] = Pairing.G1Point(
			10956182374015002204408467425327848756819631523718707154949514612564389444354,
			14436084528887728613182748250003681209821602375980408545563908878167839111638
		);

		vk.IC[3] = Pairing.G1Point(
			11329784881465718026013458454578355082127492065603307590565184979090206108462,
			1774045350300778502967267439290520186085672279369728488857982855317636197255
		);

		vk.IC[4] = Pairing.G1Point(
			307941779253314281139239164059221443144145101553286617795832073549533646709,
			20157957757455934722180643252702014590110044797384292870563888309922943890595
		);

		vk.IC[5] = Pairing.G1Point(
			7953591480885633468444910330856361123872770293996868540087670074953269967240,
			2469428366234761584071636451348900308868229578278521928005371797557332147721
		);

		vk.IC[6] = Pairing.G1Point(
			14333497813639597553549015717733291557043649878663532493718308231736132614419,
			15243696065200340524710604031429703616272121300379050086838625706252675733225
		);

		vk.IC[7] = Pairing.G1Point(
			18482556680685283628494433817161693313986511857581570923221680927341948489730,
			7831370985364761507107250319714918234044212532114686787065023834006507635799
		);

		vk.IC[8] = Pairing.G1Point(
			9543906213199847722875044848229941133500821013697600293326430757794072788277,
			18991875258865908467494940985430728026368770189648608148424128910075178207349
		);

		vk.IC[9] = Pairing.G1Point(
			20732106183296149550722690960542261370333414443869707556857709537645107047855,
			18777365490856040593357558973972205302964620262884384729566445555811953247146
		);

		vk.IC[10] = Pairing.G1Point(
			13123655164031980604767074780418720858772706036064712257112440095547982287620,
			2577636231994456429435854169837180567595839098169009523861652711050126234820
		);

		vk.IC[11] = Pairing.G1Point(
			18637673850782126876470287304924181701406363143077643257341514396090013286301,
			1724196633867057293178748393489639043795852761419456121624504640431046939
		);

		vk.IC[12] = Pairing.G1Point(
			18535381754132355115904577546613388855170633484934134256539433642140500922140,
			4543011854776992067081782402628698094658977045408431744628693031507686752124
		);

		vk.IC[13] = Pairing.G1Point(
			10414071054492188615707820122967933562908239528717887476913640400187552307318,
			9294351990676640210558234877020853527239656850065319641917573954789164959428
		);

		vk.IC[14] = Pairing.G1Point(
			10220357152417871901763225409223355475280815906057535096403887480018535465445,
			9879865699057945938514696748658224973085209814300407173497667892843318431650
		);

		vk.IC[15] = Pairing.G1Point(
			17296282020413761204823324976173033428855618369487670517195642772476416495443,
			9145029958071817248822722786829354700407682797285889353039042874103673620713
		);

		vk.IC[16] = Pairing.G1Point(
			16055100057948523121245032634677636119771584594794058766223691206027997493431,
			19020292955804937710654148020322378416708813508751081888097747591787998328511
		);

		vk.IC[17] = Pairing.G1Point(
			1257480113963838377546140749917065748374427744707632296950774064564701402846,
			14334713375115854400512787153653395322119932897971394059292553690257728913385
		);

		vk.IC[18] = Pairing.G1Point(
			11196517551156685514123330154862052393826014614350394740444181269004690489522,
			6988481000846143877546390382191664336643043967223970986325582566553083200769
		);

		vk.IC[19] = Pairing.G1Point(
			18517269909612636230301665148462716275963386142576823169313602052663771404332,
			4877182001555163669606142590662826545307663938276874531505231855324939573953
		);

		vk.IC[20] = Pairing.G1Point(
			13976297566584782879523938527825707121157906031964907598672891106155733025701,
			7868534612972399762231831308224194502030325820585214949825341161273346076839
		);

		vk.IC[21] = Pairing.G1Point(
			14726812571245342442573391870704398986638770382060421884237448282594639316978,
			14099826582336376020521928291137882839564470626375401144034982234176089266886
		);

		vk.IC[22] = Pairing.G1Point(
			10386770251864113413084663677428588304237687512991736282579458686960025563979,
			4780372479833246099550670079270491140443897997899074741589011752411330620776
		);

		vk.IC[23] = Pairing.G1Point(
			425444388829694553239243507981850444908224005516557396705029740646732368099,
			18028092471986852344690901852197191801650888742689424189246995565150929010082
		);

		vk.IC[24] = Pairing.G1Point(
			11333395626538893792053865014022375596783196894937176096081082693383632264981,
			11709062845816623578464660833996311755179651152305686834734638540463178157656
		);

		vk.IC[25] = Pairing.G1Point(
			19402095937922706199402427770808993318455372892357213079326900846642145054815,
			13619989193586727679387154529003433999806036607486791619257619706022151070477
		);

		vk.IC[26] = Pairing.G1Point(
			5393641920731732428778359881784147054956133907787578991467037748775563388449,
			13381162809975398408850066462903376789280092577218654682068783149034402380874
		);

		vk.IC[27] = Pairing.G1Point(
			1080488131958277242020435399576176540686352141829533204215613700919085251158,
			7974809292743468703184844735524462894337847973279988947923412320713345309620
		);

		vk.IC[28] = Pairing.G1Point(
			19655236705341720380805141665716677592797890852877703552184109994139834482975,
			20202909300570972915381687145081230858046049355030488382555313241490862796322
		);

		vk.IC[29] = Pairing.G1Point(
			564069205914560651165447190275021385047805875603211547572140253577754585799,
			16369258594900281200929400949679110980389334051792420296549778803292898959886
		);

		vk.IC[30] = Pairing.G1Point(
			16209922391530179086009974341959139598878840943873810309972428068517749144283,
			259267152003937207770349924867496254494510949605081340876814876383341378839
		);

		vk.IC[31] = Pairing.G1Point(
			10140371869095370961334125343345154545188820174482528146977431953645392334520,
			289495153745332185645714385097951969813474265811730594731893508738255553705
		);

		vk.IC[32] = Pairing.G1Point(
			12790662218596448128629065909678902773923326057090054364476512025191624775319,
			7385749122182794053576974556934748162908652356848230903792016756595577983536
		);

		vk.IC[33] = Pairing.G1Point(
			9063927461119286629983024252452297375811357202407995308374065521246269846470,
			9009908855692637612277610390186595611467273844840926676626092813883303807036
		);

	}

	function verifyPoseidonCommitmentMapping(uint[] memory input, PoseidonCommitmentProof memory proof) internal view returns (uint) {
		uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
		PoseidonCommitmentVerifyingKey memory vk = poseidonCommitmentVerifyingKey();
		require(input.length + 1 == vk.IC.length, "verifier-bad-input");
		// Compute the linear combination vk_x
		Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
		for (uint i = 0; i < input.length; i++) {
			require(input[i] < snark_scalar_field, "verifier-gte-snark-scalar-field");
			vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
		}
		vk_x = Pairing.addition(vk_x, vk.IC[0]);
		if (!Pairing.pairingProd4(
			Pairing.negate(proof.A),
			proof.B,
			vk.alfa1,
			vk.beta2,
			vk_x,
			vk.gamma2,
			proof.C,
			vk.delta2
		)) return 1;
		return 0;
	}
	/// @return r  bool true if proof is valid
	function verifyCommitmentMappingProof(
		uint[2] memory a,
		uint[2][2] memory b,
		uint[2] memory c,
		uint[33] memory input
	) public view returns (bool r) {
		PoseidonCommitmentProof memory proof;
		proof.A = Pairing.G1Point(a[0], a[1]);
		proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
		proof.C = Pairing.G1Point(c[0], c[1]);
		uint[] memory inputValues = new uint[](input.length);
		for (uint i = 0; i < input.length; i++) {
			inputValues[i] = input[i];
		}
		if (verifyPoseidonCommitmentMapping(inputValues, proof) == 0) {
			return true;
		} else {
			return false;
		}
	}
}