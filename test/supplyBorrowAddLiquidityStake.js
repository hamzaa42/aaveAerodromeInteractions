const { ethers } = require('ethers')

const testKey = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80'
const provider = new ethers.getDefaultProvider('http://127.0.0.1:8545/')
const testAddress = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266'

//my contract
const my_contract = '0x610178dA211FEF7D417bC0e6FeD39F05609AD788'


//related to borrowing usdc
const USDbC = '0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA'
const usdbcABI = require('./ABIs/usdbcABI.json')
const aerodromeFactory_Contract = '0x420DD381b31aEf6683db6B902084cB0FFECe40Da'

//related to depositing eth
// const aavePool = '0xA238Dd80C259a72e81d7e4664a9801593F98d1c5'
// const aaveUSDbC = '0x0a1d576f3eFeF75b330424287a95A366e8281D54'
// const aaveWethGateway_ = '0x18CD499E3d7ed42FEbA981ac9236A278E4Cdc2ee'


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
    
    const gasPriceInWei = ethers.parseUnits('0.001722545', 'gwei'); // Gas price in Wei (50 Gwei)
    const gasLimit = 2000000; // Gas limit
    const max = ethers.MaxUint256 // Maximum uint256 value
    const usdbcContract = await initUsdbcContract()
    
    //initializing my contract with usdbc
    await usdbcContract.transfer(my_contract,(BigInt('1000')*BigInt(10**6)).toString())
    
    //setting usdbc amount to borrow to my contract
    const usdbcSupplyAmount = (BigInt('666')*BigInt(10**6)).toString()
    
    //setting usdbc amount to LP to my contract
    const usdbcLPAmount = (BigInt('334')*BigInt(10**6)).toString()

    //ether payload for borrowing
    const ethPayload = ethers.parseEther('0.215')
   
    

    
    console.log(
            (await myContract.supplyBorrowAddlpStake(
                usdbcSupplyAmount,
                    max,
                    ethPayload,
                    aerodromeFactory_Contract,
                    usdbcLPAmount,           
                    { gasPrice: gasPriceInWei, gasLimit: gasLimit })
                ).data
    )
    
    
    
}



lfg()

        