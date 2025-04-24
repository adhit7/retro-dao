// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract RetroNFT is ERC721Enumerable{
   constructor() ERC721("Retro", "ONE") {}

   function mint() public {
        _safeMint(msg.sender, totalSupply());
   }
}