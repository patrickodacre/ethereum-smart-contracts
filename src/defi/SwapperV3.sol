//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.20;

import {Test, console2 as console} from "forge-std/Test.sol";
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import "../../lib/forge-std/src/interfaces/IERC20.sol";

contract SwapperV3 {
	ISwapRouter router;

    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    IERC20 private constant weth = IERC20(WETH);
    IERC20 private constant dai = IERC20(DAI);
    address public owner;

	constructor(address _router) {
		router = ISwapRouter(_router);
		owner = msg.sender;
	}


    function swapExactInputSingleHop(
        uint amountIn,
        uint amountOutMin
    ) external {
        weth.transferFrom(msg.sender, address(this), amountIn);
        weth.approve(address(router), amountIn);


        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams(
            address(weth),
            address(dai),
            3000,
            msg.sender,
            block.timestamp,
            amountIn,
            amountOutMin,
            0
            );

        router.exactInputSingle(params);

    }

    function swapExactOutputSingleHop(
        uint amountOut,
        uint amountInMax
    ) external {
        weth.transferFrom(msg.sender, address(this), amountInMax);
        weth.approve(address(router), amountInMax);

        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams(
            address(weth),
            address(dai),
            3000,
            msg.sender,
            block.timestamp,
            amountOut,
            amountInMax,
            0
            );

        uint tokensUsed = router.exactOutputSingle(params);

        if (tokensUsed < amountInMax) {
            weth.approve(address(router), 0);
            weth.transfer(msg.sender, amountInMax - tokensUsed);
        }
    }

}