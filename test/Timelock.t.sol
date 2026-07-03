// in test/TimeLock.t.sol
import {Test} from "forge-std/Test.sol";
import {TimeLock} from "../src/TimeLock.sol";

contract TimeLockTest is Test {
    TimeLock public timelock;
    address alice = makeAddr("alice");

    function setUp() public {
        timelock = new TimeLock(block.timestamp + 7 days, alice);
        vm.deal(address(timelock), 10 ether);
    }

    function test_RevertsBeforeUnlockTime() public {
        vm.prank(alice);
        vm.expectRevert("Locked");
        timelock.withdraw();
    }

    function test_RevertsForNonBeneficiary() public {
        vm.warp(block.timestamp + 8 days);
        vm.expectRevert("Not beneficiary");
        timelock.withdraw();
    }

    function test_WithdrawsAfterUnlockTime() public {
        uint256 aliceBalanceBefore = alice.balance;
        vm.warp(block.timestamp + 8 days);
        vm.prank(alice);
        timelock.withdraw();
        assertEq(alice.balance, aliceBalanceBefore + 10 ether);
    }
}