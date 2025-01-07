// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;



contract USDCPet {
    string public name = "USD Coin Paws";
    string public symbol = "USDCPaws";
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