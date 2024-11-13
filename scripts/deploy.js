const hre = require("hardhat");

async function main() {

  const Taskcontract = await hre.ethers.deployContract("Trend", ["120000000"]);
  console.log(`Deployed address: ${Taskcontract.target}`);
}

// npx hardhat run --network hardhat scripts/deploy.js
// npx hardhat run --network testnet scripts/deploy.js

main().catch((error) => {

  console.error(error);
  process.exitCode = 1;
});

//contract addres
// 0x31EEa8798eBf438F34DFBb33195dEbB6764Df6AD(Trend)