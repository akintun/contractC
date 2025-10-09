// SPDX-License-Identifier: MIT
// This first line is a standard identifier declaring the code's license.

// This tells the compiler which version of Solidity to use.
pragma solidity ^0.8.20;

// We are importing the standard ERC20 contract from the OpenZeppelin library.
// Remix automatically fetches this code from the URL.
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC20/ERC20.sol";

/**
 * @title ChainBreakerToken (CBT)
 * @dev This is the ERC20 token for the ChainBreaker game rewards.
 * It inherits from OpenZeppelin's standard ERC20 contract.
 */
contract ChainBreakerToken is ERC20 {

    /**
     * @dev The constructor is a special function that runs only ONCE when the
     *      contract is first deployed.
     * @param initialOwner The wallet address that will receive the entire initial supply.
     */
    constructor(address initialOwner) ERC20("ChainBreaker Token", "CBT") {
        // We will mint an initial supply of 1,000,000 tokens.
        // ERC20 tokens have decimals. Just like $1.00 has cents, tokens have smaller units.
        // The standard is 18 decimals, so 1 token = 1 followed by 18 zeros.
        // So, 1,000,000 tokens is 1,000,000 * (10 ** 18).
        _mint(initialOwner, 1000000 * (10 ** 18));
    }
}