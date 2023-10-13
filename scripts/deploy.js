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
  const weth_contract = '0x4200000000000000000000000000000000000006'
  const vammWethUsdbc_Contract = '0xB4885Bc63399BF5518b994c1d0C153334Ee579D0'
  const aavePool_Contract = '0xA238Dd80C259a72e81d7e4664a9801593F98d1c5'
  const aaveWETHGateway_Contract = '0x18CD499E3d7ed42FEbA981ac9236A278E4Cdc2ee'
  const aaveVariableDebtToken_Contract = '0x24e6e0795b3c7c71D965fCc4f371803d1c1DcA1E'
  const aerodromeWethUsdbcPool_Contract = '0xcf77a3ba9a5ca399b7c97c74d54e5b1beb874e43'
  const aerodromeStaker_Contract = '0xeca7ff920e7162334634c721133f3183b83b0323'

  // Provide the ABI for your contract
  const contractAbi = require('../artifacts/contracts/manager.sol/manager.json')

  // Create a ContractFactory with ABI and signer
  const managerFactory = new ethers.ContractFactory(contractAbi.abi, contractAbi.bytecode, wallet)


//todo update with new addresses
//namely weth aerodrome, Vamm
//add also relevent functions of aerodrome in manager
  const manager = await managerFactory.deploy(
    usdbc_Contract,
    weth_contract,
    vammWethUsdbc_Contract,
    aavePool_Contract,
    aaveWETHGateway_Contract,
    aaveVariableDebtToken_Contract,
    aerodromeWethUsdbcPool_Contract,
    aerodromeStaker_Contract
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
