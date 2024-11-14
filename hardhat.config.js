/**
* @type import('hardhat/config').HardhatUserConfig
*/
require('dotenv').config();
require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");

module.exports = {
  etherscan: {
    apiKey: "YEUP1IJ89CKAK9D5GTHDKX5VWU8517B3WM", 
    // apiKey:"Y1SHCTJWG2WDJT73YD8FGMB851IB1KKTDV"
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
    testnet: {
      url: "https://sepolia.base.org",
      chainId: 84532,
      accounts: ['0xea2a728ffaab51a545bc53873f33176196a37f4d94b10ad842b4bdf54bf05562'],
    }
    // testnet: {
    //   url: "https://rpc-amoy.polygon.technology",
    //   chainId: 80002,
    //   accounts: ['0xea2a728ffaab51a545bc53873f33176196a37f4d94b10ad842b4bdf54bf05562'],
    // }
    // testnet: {
    //   url: "https://avalanche-fuji-c-chain-rpc.publicnode.com",
    //   chainId: 43113,
    //   accounts: ['0xea2a728ffaab51a545bc53873f33176196a37f4d94b10ad842b4bdf54bf05562'],
    // }
  }
};

// npx hardhat verify --network testnet 0x7DBDE92ceD89173b7b16B9Ae5b18E2912DCddF62 "0xF694E193200268f9a4868e4Aa017A0118C9a8177","0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846"