// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Token} from "../../src/erc721/Token.sol";

contract TokenTest is Test {
    Token public token;
    address public alice;
    address public bob;
    address public charlie;

    function setUp() public {

        alice = makeAddr("alice");
        bob = makeAddr("bob");
        charlie = makeAddr("charlie");

        vm.prank(alice);
        token = new Token();

        vm.prank(alice);
        token.mint(alice, 1);
    }

    function test_ownerOf() public {
        assertEq(token.ownerOf(1), alice);
    }

    function test_ownerOfFailsWhenTokenNotExist() public {
        vm.expectRevert(abi.encodeWithSelector(Token.TokenNotFound.selector, 2));
        // require with text error is more expensive
        // vm.expectRevert("not exist");
        token.ownerOf(2);
    }

    function test_balanceOf() public {
        assertEq(token.balanceOf(alice), 1);
    }

    function test_balanceOfFailsWithZeroAddress() public {
        vm.expectRevert(Token.ZeroAddress.selector);
        token.balanceOf(address(0));
    }

    function test_getApproved() public {
        assertEq(token.getApproved(1), address(0));

        vm.prank(alice);
        token.approve(bob, 1);
        assertEq(token.getApproved(1), bob);
    }

    function test_approveFailsWhenNotOwner() public {
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(Token.NotOwner.selector, bob));
        token.approve(charlie, 1);
    }

    function test_getApprovedFailsWhenTokenNotExist() public {
        vm.expectRevert(abi.encodeWithSelector(Token.TokenNotFound.selector, 2));
        token.getApproved(2);
    }





    function test_owner() public {
        address owner = token.ownerOf(1);

        assertEq(owner, alice);
    }
}