// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/utils/cryptography/ECDSA.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/access/Ownable.sol";

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}

/**
 * @title ClaimContract
 * @dev This contract manages the distribution of rewards for the ChainBreaker game.
 * It holds the tokens and releases them only upon receiving a valid signature
 * from a trusted backend server.
 */
contract ClaimContract is Ownable {
    address private signerAddress;
    mapping(uint256 => bool) private usedNonces;

    event RewardClaimed(address indexed player, address indexed tokenContract, uint256 amount, uint256 nonce);

    /**
     * @dev The constructor runs once on deployment.
     * @param _initialOwner The address that will own this contract (your wallet).
     * @param _signerAddress The public address of the backend server's wallet.
     */
    constructor(address _initialOwner, address _signerAddress) Ownable(_initialOwner) {
        signerAddress = _signerAddress;
    }

    /**
     * @dev The main function for a player to claim their reward.
     * @param tokenContract The address of the ERC20 token they are claiming.
     * @param amount The amount of tokens to be claimed.
     * @param nonce A unique number for this specific claim to prevent replays.
     * @param signature The cryptographic signature from the backend server.
     */
    function claimReward(
        address tokenContract,
        uint256 amount,
        uint256 nonce,
        bytes memory signature
    ) external {
        require(!usedNonces[nonce], "ClaimContract: Nonce has already been used.");

        // We construct the message hash. This must be IDENTICAL to how the backend creates it.
        bytes32 messageHash = keccak256(abi.encodePacked(msg.sender, tokenContract, amount, nonce));

        // Use the simplified ECDSA.recover function. It handles the Ethereum Signed Message hash internally.
        address recoveredAddress = ECDSA.recover(messageHash, signature);

        require(recoveredAddress == signerAddress, "ClaimContract: Invalid signature.");

        usedNonces[nonce] = true;
        IERC20(tokenContract).transfer(msg.sender, amount);
        emit RewardClaimed(msg.sender, tokenContract, amount, nonce);
    }

    // --- Administrative Functions ---

    function updateSignerAddress(address _newSignerAddress) external onlyOwner {
        signerAddress = _newSignerAddress;
    }

    function withdrawTokens(address tokenContract, address to, uint256 amount) external onlyOwner {
        IERC20(tokenContract).transfer(to, amount);
    }
}