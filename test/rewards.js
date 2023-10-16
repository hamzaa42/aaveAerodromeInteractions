const { ethers } = require('ethers')

const testKey = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80'
const provider = new ethers.getDefaultProvider('http://127.0.0.1:8545/')

//my contract
const my_contract = '0x610178dA211FEF7D417bC0e6FeD39F05609AD788'




const wallet = new ethers.Wallet(testKey, provider);



async function initMyContract() {

    const contractABI = require('../artifacts/contracts/manager.sol/manager.json')

    const contract = new ethers.Contract(my_contract, contractABI.abi, wallet)

    return contract

}


async function lfg() {

    const myContract = await initMyContract()
    
    const gasPriceInWei = ethers.parseUnits('0.001722545', 'gwei'); // Gas price in Wei (50 Gwei)
    const gasLimit = 2000000; // Gas limit
    
   
   
    

    
    console.log(
            (await myContract.getRewards(
                        
                    { gasPrice: gasPriceInWei, gasLimit: gasLimit })
                )
    )
    
    
    
}



lfg()

        