// in src/TimeLock.sol
pragma solidity ^0.8.13;

contract TimeLock {
    uint256 public unlockTime;
    address public beneficiary;

    constructor(uint256 _unlockTime, address _beneficiary) {
        unlockTime = _unlockTime;
        beneficiary = _beneficiary;
    }

    function withdraw() public {
        require(block.timestamp >= unlockTime, "Locked");
        require(msg.sender == beneficiary, "Not beneficiary");
        payable(beneficiary).transfer(address(this).balance);
    }

    receive() external payable {}
}
