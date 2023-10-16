const ethers = require('ethers');

// Connect to an Ethereum provider (e.g., Infura)
const provider = new ethers.getDefaultProvider('http://127.0.0.1:8545/')
const testKey = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80'
const myWalletAddress = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266'
const vammWethUsdbc_Contract = '0xB4885Bc63399BF5518b994c1d0C153334Ee579D0'
const aero_Contract = '0x7C48D6D053a8004eC634C0D7950b1dE2d6A2D7c4'
const aaveBaseWethAddress = '0xD4a0e0b9149BCee3C920d2E00b5dE09138fd8bb7'; // Replace with ERC-20 token 1 contract address


const weth_contract = '0x4200000000000000000000000000000000000006'
const wethABI = require('./ABIs/wethABI.json'); // ERC-20 balanceOf function ABI for token 1

const usdcbAddress = '0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA'; // Replace with ERC-20 token 1 contract address
const myContractAddress= '0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e'
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

async function getWETHBalance(target) {
const tokenContract = new ethers.Contract(weth_contract, wethABI, provider);
const tokenBalance = await tokenContract.balanceOf(target)
const balance = ethers.formatEther(tokenBalance)
    
//  console.log(`Token Balance for ${address}: ${tokenBalance.toString()} tokens ${ethers.formatEther(tokenBalance)}`);
 console.log(`${balance} WETH `);
}

// Replace with the ERC-20 token contract address and ABI


// Call the functions to get balances
async function main(){
console.log('USDC in Contract')
await getTokenBalance(usdcbAddress,myContractAddress);

console.log('Vamm in Contract')
await getTokenBalance(vammWethUsdbc_Contract,myContractAddress);

console.log('AERO in Contract')
await getTokenBalance(aero_Contract,myContractAddress);

console.log('WETH in Contract')
await getWETHBalance(myContractAddress);

console.log('ETH in Contract')
await getEthBalance(myContractAddress)
}
main()