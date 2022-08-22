// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

contract SimpleGateway {
    function trigger(address ticketContract, uint256 tokenId) public payable {
        (bool success, ) = ticketContract.call(
            abi.encodeWithSignature("use(address,uint256)", msg.sender, tokenId)
        );
        require(success, "Failed to use ticket");
    }
}