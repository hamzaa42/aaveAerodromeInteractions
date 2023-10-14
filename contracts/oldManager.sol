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

// Define an interface for the Aero Router.
interface IAeroRouter {

    function addLiquidityETH(
        address token,
        bool stable,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function quoteRemoveLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        address _factory,
        uint256 liquidity
    ) external view returns (uint256 amountA, uint256 amountB);

    function quoteAddLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        address _factory,
        uint256 amountADesired,
        uint256 amountBDesired
    ) external view returns (uint256 amountA, uint256 amountB, uint256 liquidity);
}


interface IAeroStaker{
 
    function deposit(uint256 amount) external;
}

//Defining Smart contract
contract manager {
    //creating contract's API
    IERC20 private USDBC;
    IERC20 private WETH;
    IERC20 private VAMM;
    IAavePool private AAVE_POOL;
    IAaveWethGateway private AAVE_WETH_GATEWAY;
    IVariableDebtToken private DEBT_TOKEN;
    IAeroRouter private AERO_ROUTER;
    IAeroStaker private AERO_STAKER;
    address public owner;

    constructor(
        address usdbcAddress,
        address wethAddress,
        address vammWethUsdbcAddress,
        address aavePoolAddress,
        address aaveWethGatewayAddress,
        address variableDebtTokenAddress,
        address aeroStakerAddress,
        address aerodromeRouterAddress
        )
    
        {
            USDBC = IERC20(usdbcAddress);
            WETH = IERC20(wethAddress);
            VAMM = IERC20(vammWethUsdbcAddress);
            AAVE_POOL = IAavePool(aavePoolAddress);
            AAVE_WETH_GATEWAY = IAaveWethGateway(aaveWethGatewayAddress);
            DEBT_TOKEN = IVariableDebtToken(variableDebtTokenAddress);
            AERO_ROUTER = IAeroRouter(aerodromeRouterAddress);
            AERO_STAKER = IAeroStaker(aeroStakerAddress);
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
        uint256 _usdbcAmount, 
        uint256 _delegationAmt,
        uint256 _ethAmount) external onlyOwner{

        //approving my debt tokens to be delegated    
        DEBT_TOKEN.approveDelegation(address(AAVE_WETH_GATEWAY),_delegationAmt);
        //approving usdbc to be used in the pool
        USDBC.approve(address(AAVE_POOL), _usdbcAmount); 
        //supplying usdbc
        AAVE_POOL.supply(address(USDBC),_usdbcAmount,address(this),0);
        //borrowing eth as collateral
        AAVE_WETH_GATEWAY.borrowETH(address(AAVE_POOL),_ethAmount,2,0);

    }

 
    // Function to repay all borrowed assets and redeem all supplied assets
     function addLiquidityStake(
        address _aeroFactory,
        uint256 _usdbcAmount,
        uint256 _ethAmount) external payable onlyOwner returns (bool){
    
    uint256 amountA;
    uint256 amountB;
    uint256 liquidity;
    uint256 deadline;

     (amountA, amountB, liquidity) = AERO_ROUTER.quoteAddLiquidity(
            address(WETH),
            address(USDBC),
            false,
            _aeroFactory,
            _ethAmount,
            _usdbcAmount
        );

        deadline = block.timestamp + 1;

    USDBC.approve(address(AERO_ROUTER),_usdbcAmount);

    (amountA, amountB, liquidity) = AERO_ROUTER.addLiquidityETH
        {value:amountA}
        (
            address(USDBC),
            false,
            _usdbcAmount,
            amountB,
            amountA,
            address(this),
            deadline
            );

    VAMM.approve(address(AERO_STAKER),liquidity);
        
   AERO_STAKER.deposit(liquidity);
    return (true);
           
    }

    function getRewardsUnstakeRemoveLiquidity(uint256 usdbcAmount, int256 ethAmount) external onlyOwner{
    //get reward
    //unstake
    //approve approve wethusdbc to liquidity pool contract
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
