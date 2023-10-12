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

    // function setUserUseReserveAsCollateral(
    //     address asset, 
    //     bool useAsCollateral) external;
   
}

// Define an interface for interacting with aave eth pool.
interface AaveWethGateway{

    // Borrow ETH from the pool.
    function borrowETH(
        address pool,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode
    ) external;

    // Repay borrowed ETH to the pool.
    function repayETH(
        address pool,
        uint256 amount,
        uint256 rateMode,
        address onBehalfOf
  ) external payable;
    
}

interface VariableDebtToken{
    
    function approveDelegation(
        address delegatee,
        uint256 amount
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
    AaveWethGateway public aaveWethGateway;
    VariableDebtToken public debtToken;
    AeroPool public aeroPool;
    address public owner;

    constructor(address usdbcAddress,
        address aavePoolAddress,
        address aaveWethGatewayAddress,
        address variableDebtToken,
        address aerodromePoolAddress
        )
    
        {
            usdbc = USDbC(usdbcAddress);
            aavePool = AavePool(aavePoolAddress);
            aaveWethGateway = AaveWethGateway(aaveWethGatewayAddress);
            debtToken = VariableDebtToken(variableDebtToken);
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

    receive() external payable {
    
    }
   
    function supplyBorrowStake(
        uint256 usdbcAmount, 
        address usdbc_,
        address aavePool_,
        address aaveWethGateway_,
        uint256 delegationAmt,
        uint256 ethAmount) external onlyOwner{
            
        debtToken.approveDelegation(aaveWethGateway_,delegationAmt);
        usdbc.approve(aavePool_, usdbcAmount); 
        aavePool.supply(usdbc_,usdbcAmount,address(this),0);
        aaveWethGateway.borrowETH(aavePool_,ethAmount,2,0);

    }

 
    //Function to repay all borrowed assets and redeem all supplied assets
    function repayAndRedeem(uint256 usdbcAmount, int256 ethAmount) external payable onlyOwner{
        
    }

}

