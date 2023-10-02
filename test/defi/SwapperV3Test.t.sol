// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2 as console} from "forge-std/Test.sol";
import {SwapperV3} from "../../src/defi/SwapperV3.sol";

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import "../../lib/forge-std/src/interfaces/IERC20.sol";
// import 'v3-periphery/contracts/libraries/TransferHelper.sol';

contract Uniswap3Test is Test {

	/*
export FORK_URL=https://eth-mainnet.g.alchemy.com/v2/Mmfyi_5oxVQfUu_z0XUsSod9kvC1NL63
forge test --fork-url $FORK_URL --match-path test/defi/SwapperV3Test.t.sol -vvvv


export WETH=0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
export DAI=0x6b175474e89094c44da98b954eedeac495271d0f
export LUCKY_USER=0xad0135af20fa82e106607257143d0060a7eb5c

*/

	address public ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public alice;
    address public bob;
    IERC20 weth = IERC20(WETH);
    IERC20 dai = IERC20(DAI);

	uint mainnetFork;
	SwapperV3 swapper;


	function setUp() public {
    	alice = makeAddr("alice");
        bob = makeAddr("bob");
        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);

		vm.prank(alice);
		swapper = new SwapperV3(ROUTER);

	}

	// We an deal mainnet tokens to our test accounts
	// without impersonating a mainnet account
	function test_CanDealWethToAccounts() public {

        uint balBefore = weth.balanceOf(alice);
        assertEq(balBefore, 0);

        deal(address(weth), alice, 1e6 * 1e18);

        uint balAfter = weth.balanceOf(alice);
        assertEq(balAfter, 1e6 * 1e18);

	}

	function test_swapExactInputSingleHop() public {

		uint daiBalanceBefore = dai.balanceOf(alice);

        deal(address(weth), alice, 1000);

        vm.prank(alice);
        weth.approve(address(swapper), 1000);
        vm.prank(alice);
        // any amount of dai is fine for our test
		swapper.swapExactInputSingleHop(1000, 1);

		uint daiBalanceAfter = dai.balanceOf(alice);

		assertTrue(daiBalanceAfter > daiBalanceBefore);

	}

	function test_swapExactOutputSingleHop() public {

		uint daiBalanceBefore = dai.balanceOf(alice);

        deal(address(weth), alice, 1000);

        vm.prank(alice);
        weth.approve(address(swapper), 1000);
        vm.prank(alice);
		swapper.swapExactOutputSingleHop(1000, 1000);

		uint daiBalanceAfter = dai.balanceOf(alice);

		assertTrue(daiBalanceAfter > daiBalanceBefore);
		assertTrue(daiBalanceAfter == 1000);

	}
}
