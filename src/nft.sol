// SPDX-Licenses-Identifier

pragma solidity ^0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721 {
    address public owner;
    uint256 public totalSupply;

    constructor() ERC721("Kali", "KL") {}

    function mint(uint256 tokenId) external {
        require(msg.sender != address(0));
        totalSupply++;
        _mint(msg.sender, tokenId);
    }
}
