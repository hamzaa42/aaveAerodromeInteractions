const { ethers } = require('ethers')

const testKey = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80'
const provider = new ethers.getDefaultProvider('http://127.0.0.1:8545/')
const testAddress = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266'

//my contract
const my_contract = '0x610178dA211FEF7D417bC0e6FeD39F05609AD788'


//related to borrowing usdc
const aavePool = '0xA238Dd80C259a72e81d7e4664a9801593F98d1c5'
const USDbC = '0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA'
const usdbcABI = require('./ABIs/usdbcABI.json'); // 

//related to depositing eth
const aaveEthPool = '0x18CD499E3d7ed42FEbA981ac9236A278E4Cdc2ee'


const wallet = new ethers.Wallet(testKey, provider);



async function initMyContract() {

    const contractABI = require('../artifacts/contracts/manager.sol/manager.json')

    const contract = new ethers.Contract(my_contract, contractABI.abi, wallet)

    return contract

}
async function initUsdbcContract() {

    const contractABI = require('../artifacts/contracts/manager.sol/manager.json')

    const contract = new ethers.Contract(USDbC, usdbcABI, wallet)

    return contract

}

async function lfg() {

    const myContract = await initMyContract()
    const usdbcContract = await initUsdbcContract()
   // console.log(await usdbcContract.transfer(my_contract, 80000000000))

    const gasLimitA = ethers.parseEther('0.05'); // 0.1 Ether
    const usdcmAmt = ethers.parseEther('91006300000')
    console.log(usdcmAmt)
    const ethPayload = ethers.parseEther('0.001'); // 0.1 Ether
    console.log(ethPayload)
    

    //console.log(await myContract.getOwner())
    console.log('**********************************')
    const gasPriceInWei = ethers.parseUnits('0.001722545', 'gwei'); // Gas price in Wei (50 Gwei)
    const gasLimit = 2000000; // Gas limit
    
    console.log(
        await myContract.supplyBorrowStake(
            usdcmAmt, USDbC, aavePool, ethPayload,
            { gasPrice: gasPriceInWei, gasLimit: gasLimit }
        )
    )
}


lfg()
