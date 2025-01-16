// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title USDCPaws
 * @dev Implementation of an ERC20 token with OpenZeppelin
 */
contract USDCPaws is ERC20, Ownable {

    uint8 private immutable _decimals = 6;

    /**
     * @dev Constructor to initialize the token with name, symbol, and decimals.
     */
    constructor() ERC20("USD Coin Paws", "USDCPaws") Ownable(msg.sender) {}

    /**
     * @dev Returns the number of decimals the token uses.
     */
    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Mints `amount` tokens to the `to` address.
     * Can only be called by the owner.
     * @param to Address to mint tokens to.
     * @param amount Amount of tokens to mint.
     */
    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Cannot mint to the zero address");
        _mint(to, amount);
    }

    /**
     * @dev Burns `amount` tokens from the `from` address.
     * Can only be called by the owner.
     * @param from Address to burn tokens from.
     * @param amount Amount of tokens to burn.
     */
    function burn(address from, uint256 amount) external onlyOwner {
        require(from != address(0), "Cannot burn from the zero address");
        _burn(from, amount);
    }
}
