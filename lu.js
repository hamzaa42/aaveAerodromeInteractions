//command for exec
//npx hardhat run --network localhost lu.js

const { ethers, network } = require("hardhat");

const targetAddress = '0x1f9b1b84fe59fce1dba1ac2542c725bf23215f22';
const recipientAddress = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266';
const USDbC = '0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA'; // Corrected contract address
const usdbcABI = require('./test/ABIs/usdbcABI.json'); // Corrected ABI file

async function impersonateAndTransferUSDbC(targetAddress, recipientAddress, usdcAmount) {
  try {
    // Impersonate the target address
    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [targetAddress],
    });

    console.log(`Impersonated address: ${targetAddress}`);

    const impersonatedSigner = await ethers.getSigner(targetAddress);
    const usdbcContract = new ethers.Contract(USDbC, usdbcABI, impersonatedSigner);

    const targetBalance = ethers.formatUnits(await usdbcContract.balanceOf(targetAddress), 6);
    console.log(`Target balance before transfer: ${targetBalance} USDbC`);
    
    const tx = await usdbcContract.transfer(recipientAddress, usdcAmount);
    await tx.wait();
    
    console.log(`Transferred ${(usdcAmount / 1e6)} USDbC to ${recipientAddress}`);

    const targetBalanceAfter = ethers.formatUnits(await usdbcContract.balanceOf(targetAddress), 6);
    console.log(`Target balance before transfer: ${targetBalanceAfter} USDbC`);
  } catch (error) {
    console.error('Error:', error);
  }
}

// Call the function to impersonate and transfer
impersonateAndTransferUSDbC(targetAddress,
 recipientAddress,
 (BigInt('10000')*BigInt(10**6)).toString()
  );
