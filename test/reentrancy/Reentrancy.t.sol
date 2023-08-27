// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Bank} from "../../src/reentrancy/Bank.sol";
import {IBank, Attacker} from "../../src/reentrancy/Attacker.sol";

contract ReentrancyTest is Test {
    Bank public bank;
    Attacker public attacker;
	address alice;
	address bob;


    function setUp() public {
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        vm.prank(alice);
        bank = new Bank();
    }

    function test_steal() public {

        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);
        assertEq(address(bob).balance, 1 ether);

        vm.deal(address(bank), 1 ether);
        assertEq(address(bank).balance, 1 ether);

        vm.prank(bob);
        attacker = new Attacker(address(bank));
        attacker.stealFunds{value: 0.2 ether}();

        assertEq(address(bank).balance, 0, "funds remain");
        // Bob should only have 2 ether -> his original 1 ether + the 1 ether stolen from the bank
        // forge allows for double spending of the 0.2 ether, though
        assertEq(bob.balance, 2.2 ether, "unexpected balance for bob");


    }

}

