// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// Define an relevant ERC20 functions.
interface IERC20 {
    function approve(
        address spender,
        uint256 amount
    ) external returns (bool);

    function transfer(
        address to,
        uint256 amount
     ) external returns (bool);

     function balanceOf(
        address account) external view returns (uint256);

}

// Define an interface for interacting with aave shitcoin pool.
interface IAavePool {

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
interface IAaveWethGateway{

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

interface IVariableDebtToken{
    
    function approveDelegation(
        address delegatee,
        uint256 amount
        ) external;

}

//Define an interface for interacting with aerodrome pool
interface IAeroPool{
    function addLiquidityETH(
        address token,
        bool stable,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline) external payable;

    //function idkName_redeem() external;
}

interface IAeroStaker{
 
    function deposit(uint256 amount) external returns (bool);
}

//Defining Smart contract
contract manager {
    //creating contract's API
    IERC20 private _usdbc;
    IERC20 private _weth;
    IERC20 private _vammWethUsdbc;
    IAavePool private _aavePool;
    IAaveWethGateway private _aaveWethGateway;
    IVariableDebtToken private _debtToken;
    IAeroPool private _aeroPool;
    IAeroStaker private _aeroStaker;
    address public owner;

    constructor(
        address usdbcAddress,
        address wethAddress,
        address vammWethUsdbcAddress,
        address aavePoolAddress,
        address aaveWethGatewayAddress,
        address variableDebtTokenAddress,
        address aerodromePoolAddress,
        address aeroStakerAddress
        )
    
        {
            _usdbc = IERC20(usdbcAddress);
            _weth = IERC20(wethAddress);
            _vammWethUsdbc = IERC20(vammWethUsdbcAddress);
            _aavePool = IAavePool(aavePoolAddress);
            _aaveWethGateway = IAaveWethGateway(aaveWethGatewayAddress);
            _debtToken = IVariableDebtToken(variableDebtTokenAddress);
            _aeroPool = IAeroPool(aerodromePoolAddress);
            _aeroStaker = IAeroStaker(aeroStakerAddress);
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
   
    function supplyBorrow(
        uint256 usdbcAmount, 
        address usdbc_,
        address aavePool_,
        address aaveWethGateway_,
        uint256 delegationAmt,
        uint256 ethAmount) external onlyOwner{

        //approving my debt tokens to be delegated    
        _debtToken.approveDelegation(aaveWethGateway_,delegationAmt);
        //approving usdbc to be used in the pool
        _usdbc.approve(aavePool_, usdbcAmount); 
        //supplying usdbc
        _aavePool.supply(usdbc_,usdbcAmount,address(this),0);
        //borrowing eth as collateral
        _aaveWethGateway.borrowETH(aavePool_,ethAmount,2,0);

    }

 
    //Function to repay all borrowed assets and redeem all supplied assets
    function addLiquidityStake(
        address aeroPool,
        address lptoken,
        address usdbc,
        uint256 usdbcAmount,
        uint256 ethAmount,
        uint256 max) external onlyOwner returns(bool){
    
    // https://basescan.org/tx/0x282b3354944cc1632433f5bf63982985ffaa7f1708232747d124aed74bbfa957
    
    _usdbc.approve(aeroPool,usdbcAmount);
    //todo remaining placeholders here
    _aeroPool.addLiquidityETH(usdbc,false,3,4,ethAmount,address(this),7);
    _vammWethUsdbc.approve(lptoken,max);
    
     //https://basescan.org/address/0xeca7ff920e7162334634c721133f3183b83b0323#code

    uint256 vammBalance = _vammWethUsdbc.balanceOf(address(this)); 
    _aeroStaker.deposit(vammBalance);
    return true;
           
    }

    function getRewardsUnstakeRemoveLiquidity(uint256 usdbcAmount, int256 ethAmount) external onlyOwner{
    //get reward
    //unstake
    //approve approve wethusdbc 
    //remove liquidity
    //now I have weth and usdbc -> todo convert weth to usdbc on uniswap
    }

    function repayDebtWithdrawCollateral() external onlyOwner{
        //repay debt to aave
        //withdraw collateral
    }

    function getRewards() external onlyOwner{
        //get staking rewards in smart contract
        //dump for usdbc
        //send rewards to owner
    }


    function withdrawERC20(address tokenAddress, uint256 amount) external onlyOwner{
        IERC20 token = IERC20(tokenAddress);
        token.transfer (msg.sender, amount);
    }

    function allETH() external onlyOwner{
    //return all eth to owner
    }
}

