// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Bank {

    event Deposit(address indexed account, uint amount);
    event Withdraw(address indexed account, uint amount);

    error WithdrawFailed(address,uint);

    mapping(address => uint) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() external payable {
        uint amount = balances[msg.sender];

        // Re-entrancy Vulnerability::
        // external call should be made AFTER balance is set to ZERO
        // else the contract calling withdraw() can reenter
        // and steal all the funds.
        (bool ok, ) = msg.sender.call{value: amount}("");

        if (!ok) {
            revert WithdrawFailed(msg.sender, amount);
        }

        // should delete balance before completing the transfer to prevent re-entrancy
        delete balances[msg.sender];

        emit Withdraw(msg.sender, amount);
    }
}
