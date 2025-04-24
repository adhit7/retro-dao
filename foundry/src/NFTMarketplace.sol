// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract NFTMarketplace {
   mapping(uint256 => address) public tokens;

   uint256 constant NFT_PRICE = 0.05 ether;

   function purchase(uint256 _tokenId) external payable{
    require(msg.value == NFT_PRICE, "Price is 0.05 ether"); 
    tokens[_tokenId] = msg.sender;
   }

   function getPrice() external pure returns (uint256) {
        return NFT_PRICE;
    }

    function available(uint256 _tokenId) external view returns (bool) {
        // address(0) = 0x0000000000000000000000000000000000000000
        // This is the default value for addresses in Solidity
        if (tokens[_tokenId] == address(0)) {
            return true;
        }
        return false;
    }
}
