// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @dev Contract deployed on Base Sepolia
 * @notice You can view the deployed contract at:
 * https://sepolia.basescan.org/address/0x1dfe0B41dDebe308B6096D32a0c404b2d835C6Ce#code
*/

contract USDCPet {
    string public name = "USD Coin Pet";
    string public symbol = "USDCPet";
    uint8 public decimals = 6;
    
    mapping(address => uint256) public balanceOf;


    // Function to mint new tokens
    function mint(address to, uint256 amount) public {
        balanceOf[to] += amount;
    }

    // Function to transfer tokens
    function transfer(address to, uint256 amount) public returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
    
}