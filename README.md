# Trend Project

This project is a Hardhat-based Ethereum project that includes smart contracts, scripts, and tests for the `MyToken` ERC-20 token. It allows for token minting, burning, and includes additional functionalities like blacklisting.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Scripts](#scripts)
- [Testing](#testing)
- [Deployment](#deployment)
- [License](#license)

## Prerequisites

Ensure you have the following installed:

- [Node.js](https://nodejs.org/en/) v12 or higher
- [NPM](https://www.npmjs.com/) or [Yarn](https://yarnpkg.com/)
- [Hardhat](https://hardhat.org/)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Getting Started

## Setup and Deployment Guide

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/yourusername/MyTokenProject.git
   cd MyTokenProject
   Compile Contracts:
2. Compile the smart contracts using Hardhat.

    npx hardhat compile

4. Scripts
Deploy the Contract:
Use the deploy.js script located in the scripts directory to deploy the contract.

npx hardhat run scripts/deploy.js --network <network_name>
e.g npx hardhat run --network testnet scripts/deploy.js

6. verify smart contract
7. 
   npx hardhat verify --network <network_name> <contract_address> <constructor_arguments>
   e.g #npx hardhat verify --network testnet contractaddress "arg1","arg2"

## Documentation guide
   #USER GUIDE:https://docs.google.com/document/d/1wbSrjGdXO-bWgX0QBQVVIjM7USSsE_vhDZZ35ZpZkJ8/edit?tab=t.0

