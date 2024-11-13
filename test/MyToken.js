const Web3 = require('web3');
const { abi, evm } = require('./MyToken.json'); // ABI and bytecode from your compiled contract

const web3 = new Web3('http://localhost:8545'); // Connect to your Ethereum node or Hardhat network
const initialSupply = web3.utils.toWei('120000000', 'ether'); // Convert the initial supply to wei (adjust if necessary)

async function deployContract() {
  const accounts = await web3.eth.getAccounts(); // Get available accounts
  const owner = accounts[0]; // Assume the deployer is the first account

  // Deploy the contract
  const myToken = await new web3.eth.Contract(abi)
    .deploy({ data: evm.bytecode.object, arguments: [initialSupply] })
    .send({ from: owner, gas: 3000000 });

  console.log(`Contract deployed at address: ${myToken.options.address}`);

  // Verify the total supply
  const totalSupply = await myToken.methods.totalSupply().call();
  console.log(`Total Supply: ${web3.utils.fromWei(totalSupply, 'ether')} tokens`);

  // Check the balance of the deployer (owner)
  const ownerBalance = await myToken.methods.balanceOf(owner).call();
  console.log(`Owner's Balance: ${web3.utils.fromWei(ownerBalance, 'ether')} tokens`);
}

deployContract().catch(console.error);
