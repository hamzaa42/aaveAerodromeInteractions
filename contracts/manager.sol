// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// Define an relevant ERC20 functions.
interface IERC20 {
    function approve(address spender, uint amount) external returns (bool);

    function transfer(address to, uint amount) external returns (bool);

    function balanceOf(address account) external view returns (uint);
}

interface IWETH {
    function approve(address spender, uint amount) external returns (bool);

    function transfer(address to, uint amount) external returns (bool);

    function balanceOf(address account) external view returns (uint);

    function withdraw(uint wad) external;
 

}

// Define an interface for interacting with aave shitcoin pool.
interface IAavePool {
    // Supply funds to the pool.
    function supply(
        address asset,
        uint amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    // Withdraw funds from the pool.
    function withdraw(address asset, uint amount, address to) external;

    // function setUserUseReserveAsCollateral(
    //     address asset,
    //     bool useAsCollateral) external;
}

// Define an interface for interacting with aave eth pool.
interface IAaveWethGateway {
    // Borrow ETH from the pool.
    function borrowETH(
        address pool,
        uint amount,
        uint interestRateMode,
        uint16 referralCode
    ) external;

    // Repay borrowed ETH to the pool.
    function repayETH(
        address pool,
        uint amount,
        uint rateMode,
        address onBehalfOf
    ) external payable;
}

interface IVariableDebtToken {
    function approveDelegation(address delegatee, uint amount) external;
}

// Define an interface for the Aero Router.
interface IAeroRouter {
    function addLiquidityETH(
        address token,
        bool stable,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external payable;

    function quoteAddLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        address _factory,
        uint amountADesired,
        uint amountBDesired
    )
        external
        view
        returns (uint amountA, uint amountB, uint liquidity);

    function quoteRemoveLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        address _factory,
        uint liquidity
    ) external view returns (uint amountA, uint amountB);
}

interface IAeroStaker {
    function deposit(uint amount) external;

    //https://basescan.org/tx/0x257273bb0ab9c0fc8fba6a68fed662c91e572901507389a577c30d08d64bc679
    function getReward(address user) external;

    //https://basescan.org/tx/0x46439616cf4cdd117a54142f0c77ca532de80d6c2b380c92d64afbcbffad19e6
    function withdraw(uint _amount) external;

    function balanceOf(address user) external returns (uint);
}

//Defining Smart contract
contract manager {
    //creating contract's API
    IERC20 private USDBC;
    IWETH private WETH;
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
    ) {
        USDBC = IERC20(usdbcAddress);
        WETH = IWETH(wethAddress);
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

    receive() external payable {}

    /**
     supply usdbc
     borrow eth
     lp with usdbc and eth
     stake lp tokens
     */
    function expose(
        uint _usdbcSupplyAmount,
        uint _delegationAmt,
        uint _ethAmount,
        address _aeroFactory,
        uint _usdbcLPAmount
    ) external payable onlyOwner {
        //approving usdbc to be used in the pool
        USDBC.approve(address(AAVE_POOL), _usdbcSupplyAmount);
        //approving debt tokens to be delegated
        DEBT_TOKEN.approveDelegation(
            address(AAVE_WETH_GATEWAY),
            _delegationAmt
        );
        //approving usdbc amount to aero router
        USDBC.approve(address(AERO_ROUTER), _usdbcLPAmount);

        //supplying usdbc
        AAVE_POOL.supply(address(USDBC), _usdbcSupplyAmount, address(this), 0);

        //borrowing eth as collateral
        AAVE_WETH_GATEWAY.borrowETH(address(AAVE_POOL), _ethAmount, 2, 0);

        //initializing variables to get quotes
        uint amountA;
        uint amountB;
        uint liquidity;
        uint deadline;

        //getting quote for providing liquidity to aerodrome
        (amountA, amountB, liquidity) = AERO_ROUTER.quoteAddLiquidity(
            address(WETH),
            address(USDBC),
            false,
            _aeroFactory,
            _ethAmount,
            _usdbcLPAmount
        );

        //defining deadline for liquidity tx, 1s indicating within the same block
        deadline = block.timestamp + 1;

        //adding the LP for LP tokens and saving return
        (amountA, amountB, liquidity) = AERO_ROUTER.addLiquidityETH{
            value: amountA
        }(
            address(USDBC),
            false,
            _usdbcLPAmount,
            amountB,
            amountA,
            address(this),
            deadline
        );

        //approving LP tokens to stake
        VAMM.approve(address(AERO_STAKER), liquidity);

        //depositing staked token
        AERO_STAKER.deposit(liquidity);
    }

    /**
unstake
remove liquidity
repay eth
withdraw usdbc
 */
    function normalize(address aeroFactory, uint usdbcAmountAave, uint ethDebt) external payable onlyOwner {

        uint stakedAmount = AERO_STAKER.balanceOf(address(this));
        //uint aaveWETHDebt = DEBT_TOKEN.balanceOf(address(this));
        
        AERO_STAKER.withdraw(stakedAmount);
        
        uint vammBalance;
        uint wethAmount;
        uint usdbcAmount;
        
        uint deadline = block.timestamp + 1;
        
        vammBalance = VAMM.balanceOf(address(this));
        VAMM.approve(address(AERO_ROUTER), vammBalance);
        
        (wethAmount,usdbcAmount) = AERO_ROUTER.quoteRemoveLiquidity(
            address(WETH),
            address(USDBC),
            false,
            aeroFactory,
            vammBalance
        );

        AERO_ROUTER.removeLiquidity(
            address(WETH),
            address(USDBC),
            false,
            vammBalance,
            wethAmount,
            usdbcAmount,
            address(this),
            deadline
        );

        WETH.withdraw(wethAmount);
        AAVE_WETH_GATEWAY.repayETH{value:ethDebt}(address(AAVE_POOL),ethDebt,2,address(this));
        AAVE_POOL.withdraw(address(USDBC),usdbcAmountAave,address(this));
    }

    function getStakingRewards() external onlyOwner {
        AERO_STAKER.getReward(address(this));
        
    }

    function getLPRewards() external onlyOwner {
        // get lp rewards
    }

    function withdrawERC20(
        address tokenAddress,
        uint amount
    ) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        token.transfer(msg.sender, amount);
    }

    function allETH() external onlyOwner {
        //return all eth to owner
    }
}
