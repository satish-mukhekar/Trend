const hre = require("hardhat");

async function main() {

  const Taskcontract = await hre.ethers.deployContract("Trend", [""]);
  console.log(`Deployed address: ${Taskcontract.target}`);
}

// npx hardhat run --network hardhat scripts/deploy.js
// npx hardhat run --network testnet scripts/deploy.js

main().catch((error) => {

  console.error(error);
  process.exitCode = 1;
});

//contract addres
// 0x1fE1F8a8A0E1B65E1e900D8611Ffb9F4B5E67B22
// https://sepolia.basescan.org/address/0x1fE1F8a8A0E1B65E1e900D8611Ffb9F4B5E67B22#code

//Briding(avax)
// 0x4D35935cD5a54bfaD8265f9AE808330666d01A8D
// https://testnet.snowtrace.io/address/0x4D35935cD5a54bfaD8265f9AE808330666d01A8D#code
// chain selector: 14767482510784806043
// router: 0xF694E193200268f9a4868e4Aa017A0118C9a8177
// link: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846

//Briding(sepolia)
// 0x7DBDE92ceD89173b7b16B9Ae5b18E2912DCddF62
// https://sepolia.basescan.org/address/0x7DBDE92ceD89173b7b16B9Ae5b18E2912DCddF62#code
/// chain selector: 10344971235874465080
// router: 0xD3b06cEbF099CE7DA4AcCf578aaebFDBd6e88a93
// link: 0xE4aB69C077896252FAFBD49EFD26B5D171A32410

//ccip explore 
//https://ccip.chain.link/#/side-drawer/msg/0x75b4acfaa2e77f54601322ce2bc4124a35a79ef0fbd7b5dcc912ceecbd88dbe9