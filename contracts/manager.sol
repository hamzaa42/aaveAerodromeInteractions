// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// Define an interface for approving the spending of usdbc.
interface USDbC {
    function approve(
        address spender,
        uint256 amount
    ) external returns (bool);

    function transfer(
        address to,
        uint256 amount
     ) external returns (bool);


}

// Define an interface for interacting with aave shitcoin pool.
interface AavePool {

    // Supply funds to the pool.
    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    // Withdraw funds from the pool.
    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external;

   
}

// Define an interface for interacting with aave eth pool.
interface AaveEPool{

    // Borrow ETH from the pool.
    function borrowETH(address ,
    uint256 amount,
    uint256 interestRateMode,
    uint16 referralCode
    ) external;

    // Repay borrowed ETH to the pool.
    function repayETH(address ,
    uint256 amount,
    uint256 interestRateMode,
    address onBehalfOf
    ) external;
    
}
//Define an interface for interacting with aerodrome pool
interface AeroPool{
    function idkName_supply() external returns (bool);

    function idkName_redeem() external returns (bool);
}

//Defining Smart contract
contract manager {
    //creating contract's API
    USDbC public usdbc;
    AavePool public aavePool;
    AaveEPool public aaveEthPool;
    AeroPool public aeroPool;
    address public owner;

    constructor(address usdbcAddress,
        address aavePoolAddress,
        address aaveEthPoolAddress,
        address aerodromePoolAddress
        )
    
        {
            usdbc = USDbC(usdbcAddress);
            aavePool = AavePool(aavePoolAddress);
            aaveEthPool = AaveEPool(aaveEthPoolAddress);
            aeroPool = AeroPool(aerodromePoolAddress);
            owner = msg.sender;
    
        }
    //defining the onlyowner modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Function to get the owner's address (accessible by anyone)
    function getOwner() external view returns (address) {
        return owner;
    }
    // //Function to approve usdbc spend onlyOwner
    // function approveUSDbC(address contractAddress, uint256 amount)external onlyOwner{
    //     usdbc.approve(contractAddress,amount);
    // }
    //Function to perform supply borrow and take operation
    //supply usdbc on aave
    //borrow eth against it
    //add liquidity in aerodrome and stake it
    function supplyBorrowStake(
        uint256 usdbcAmount, 
        address usdbcContract,
        address aavePoolContract,
        uint256 ethAmount, 
        address ethPool) external onlyOwner{
            
      usdbc.approve(aavePoolContract, usdbcAmount); 
      aavePool.supply(usdbcContract,usdbcAmount,address(this),0);
      aaveEthPool.borrowETH(ethPool,ethAmount,2,0);

    }

    //Function to repay all borrowed assets and redeem all supplied assets
    function repayAndRedeem(uint256 usdbcAmount, int256 ethAmount) external payable onlyOwner{
        
    }

}

