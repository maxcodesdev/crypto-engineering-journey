// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    // Happy path tests
    function test_InitialNumberIsZero() public view {
        assertEq(counter.number(), 0);
    }

    function test_IncrementIncreasesNumber() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function test_SetNumberStoresValue() public {
        counter.setNumber(42);
        assertEq(counter.number(), 42);
    }

    // Edge case tests
    function test_SetNumberToZero() public {
        counter.setNumber(100);
        counter.setNumber(0);
        assertEq(counter.number(), 0);
    }

    function test_SetNumberToMaxUint256() public {
        counter.setNumber(type(uint256).max);
        assertEq(counter.number(), type(uint256).max);
    }

    function test_IncrementOverflowsAtMax() public {
        counter.setNumber(type(uint256).max);
        vm.expectRevert();
        counter.increment();
    }

    // Tests with cheatcodes
    function test_CallerCanBeAnyAddress() public {
        vm.prank(alice);
        counter.setNumber(123);
        assertEq(counter.number(), 123);

        vm.prank(bob);
        counter.setNumber(456);
        assertEq(counter.number(), 456);
    }

    // Fuzz test
    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }

    function test_BrokenIntentionally() public {
    counter.setNumber(10);
    console2.log("Number is:", counter.number());
    assertEq(counter.number(), 11); // Wrong assertion
}

function test_Fork_ReadFromMainnetCounter() public {

    vm.createSelectFork(vm.envString("MAINNET_RPC_URL"));

    // At this point, we're on mainnet state.
    // We could read from any deployed contract here.

    // Example: read the latest block number
    console2.log("Forked at block:", block.number);
}


function test_Fork_ReadUniswapV2Reserves() public {

    vm.createSelectFork(vm.envString("MAINNET_RPC_URL"));

    // The USDC/ETH Uniswap V2 pair on mainnet
    address pair = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc;

    IUniswapV2Pair uniswapPair = IUniswapV2Pair(pair);
    (uint112 reserve0, uint112 reserve1, ) = uniswapPair.getReserves();

    console2.log("Reserve 0 (USDC):", reserve0);
    console2.log("Reserve 1 (WETH):", reserve1);

    assertGt(reserve0, 0);
    assertGt(reserve1, 0);
}

} 
interface IUniswapV2Pair {
    function getReserves() external view returns (uint112, uint112, uint32);
}
