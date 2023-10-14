const ethers = require('ethers');

// Connect to an Ethereum provider (e.g., Infura)
const provider = new ethers.getDefaultProvider('http://127.0.0.1:8545/')
const testKey = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80'
const myWalletAddress = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266'
const vammWethUsdbc_Contract = '0xB4885Bc63399BF5518b994c1d0C153334Ee579D0'


// Specify the Ethereum address for which you want to check balances
const usdcbAddress = '0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA'; // Replace with ERC-20 token 1 contract address
const aaveBaseWethAddress = '0xD4a0e0b9149BCee3C920d2E00b5dE09138fd8bb7'; // Replace with ERC-20 token 1 contract address
const myContractAddress= '0x610178dA211FEF7D417bC0e6FeD39F05609AD788'
const usdbcABI = require('./ABIs/usdbcABI.json'); // ERC-20 balanceOf function ABI for token 1

const address = '0x610178dA211FEF7D417bC0e6FeD39F05609AD788'; // Replace with the address you want to query

// Function to get ETH balance
async function getEthBalance(target) {
  const balance = await provider.getBalance(target);
  const ethBalance = ethers.formatEther(balance);

  console.log(`${target}: ${ethBalance} ETH`);
}

// Function to get ERC-20 token balance
async function getTokenBalance(tokenaddr, target) {
const tokenContract = new ethers.Contract(tokenaddr, usdbcABI, provider);
const tokenBalance = await tokenContract.balanceOf(target);

    
//  console.log(`Token Balance for ${address}: ${tokenBalance.toString()} tokens ${ethers.formatEther(tokenBalance)}`);
 console.log(`${tokenBalance/(BigInt(1000000))} tokens ${tokenaddr} `);
}

// Replace with the ERC-20 token contract address and ABI


// Call the functions to get balances
async function main(){
console.log('USDC in Contract')
await getTokenBalance(usdcbAddress,myContractAddress);

console.log('Vamm in Contract')
await getTokenBalance(vammWethUsdbc_Contract,myContractAddress);

console.log('Eth in Contract')
await getEthBalance(myContractAddress)
}
main()