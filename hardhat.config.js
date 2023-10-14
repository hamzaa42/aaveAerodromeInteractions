
require("@nomicfoundation/hardhat-toolbox")
require("@nomicfoundation/hardhat-verify")

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.0",
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 8453,
      forking: {
        url: 'https://rpc.ankr.com/base',
      }
    }
  }
  
};