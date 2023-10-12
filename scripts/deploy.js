const { ethers } = require('ethers');

async function main() {
  // Replace with your private key and RPC endpoint
  const privateKey = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80'
  const rpcEndpoint = 'http://127.0.0.1:8545'

  // Create a provider using your RPC endpoint
  const provider = new ethers.JsonRpcProvider(rpcEndpoint)

  // Connect a wallet using the private key
  const wallet = new ethers.Wallet(privateKey, provider)

  // Replace with the actual address of the IPool contract
  const usdbc_Contract = '0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA'
  const aavePool_Contract = '0xA238Dd80C259a72e81d7e4664a9801593F98d1c5'
  const aaveETH_Contract = '0x18CD499E3d7ed42FEbA981ac9236A278E4Cdc2ee'
  const aaveVariableDebtToken_Contract = '0x24e6e0795b3c7c71D965fCc4f371803d1c1DcA1E'
  const aeroDrome_Contract = '0x0000000000000000000000000000000000000000'
  const aerodromeEthUsdbc_Contract = ''


  // Provide the ABI for your contract
  const contractAbi = require('../artifacts/contracts/manager.sol/manager.json')

  // Create a ContractFactory with ABI and signer
  const managerFactory = new ethers.ContractFactory(contractAbi.abi, contractAbi.bytecode, wallet)

  // Deploy the contract
//   constructor(address usdbcAddress,
//     address aavePoolAddress,
//     address aaveEthPoolAddress,
//     address aerodromePoolAddress
//     )
  const manager = await managerFactory.deploy(
    usdbc_Contract,
    aavePool_Contract,
    aaveETH_Contract,
    aaveVariableDebtToken_Contract,
    aeroDrome_Contract
    )

//  await manager.deployed();
  console.log(manager)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
