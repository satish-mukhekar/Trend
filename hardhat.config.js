/**
* @type import('hardhat/config').HardhatUserConfig
*/
require('dotenv').config();
require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");

module.exports = {
  etherscan: {
    // apiKey: "YEUP1IJ89CKAK9D5GTHDKX5VWU8517B3WM", 
    apiKey:"Y1SHCTJWG2WDJT73YD8FGMB851IB1KKTDV"
  },
  defaultNetwork: "testnet" || "hardhat",
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1,
      },
    }
  },
  networks: {
    // testnet1: {
    //   url: "https://sepolia.base.org",
    //   chainId: 84532,
    //   accounts: ['0xea2a728ffaab51a545bc53873f33176196a37f4d94b10ad842b4bdf54bf05562'],
    // }
    testnet: {
      url: "https://rpc-amoy.polygon.technology",
      chainId: 80002,
      accounts: ['0x80950bd3cf0265e325e7c9c99c84f1c5407c44e9e04f09ef5693261f9dfbc716'],
    }
    // 0x43c012137260c52997933e252ec1155137d77eD6
  }
};

// npx hardhat verify --network testnet 0xd6C35e12966cF059dE3A75fb93a2b8ab29643025 "investor" 