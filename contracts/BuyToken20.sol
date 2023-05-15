//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.9;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenPurchase {
    address public tokenAddress;  // Address of the ERC-20 token contract
    address public seller;  // Address of the token seller
    uint256 public price;  // Price per token in wei

    event TokensPurchased(address buyer, uint256 amount);

    constructor(address _tokenAddress, address _seller, uint256 _price) {
        tokenAddress = _tokenAddress;
        seller = _seller;
        price = _price;
    }

    function buyTokens(uint256 tokenAmount) external payable {
        IERC20 token = IERC20(tokenAddress);

        uint256 weiAmount = price * tokenAmount;
        require(msg.value >= weiAmount, "Insufficient payment");

        // Transfer tokens from the seller to the buyer
        require(token.transferFrom(seller, msg.sender, tokenAmount), "Token transfer failed");

        // Refund any excess payment
        if (msg.value > weiAmount) {
            uint256 refundAmount = msg.value - weiAmount;
            payable(msg.sender).transfer(refundAmount);
        }

        emit TokensPurchased(msg.sender, tokenAmount);
    }
}