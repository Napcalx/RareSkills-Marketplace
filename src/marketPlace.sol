// SPDX-Licenses-Identifier
pragma solidity ^0.8.19;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {NFT} from "../src/nft.sol";

contract MarketPlace is IERC721Receiver {
    NFT nft;
    address public admin;
    uint256 public Id;

    struct Orders {
        address seller;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Orders)) public listing;
    event NftListed(
        address indexed nft,
        uint256 tokenId,
        address indexed seller,
        uint256 price
    );
    event NftBought(
        address indexed nft,
        uint256 tokenId,
        address indexed buyer,
        uint256 price
    );
    event ListingCancelled(
        address indexed nft,
        uint256 tokenId,
        address indexed seller
    );

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function ListNft(address nft_, uint256 tokenId, uint256 price) external {
        require(price >= 1 ether, "Listing price can not be Zero");
        IERC721 nftContract = IERC721(nft_);

        nftContract.safeTransferFrom(msg.sender, address(this), tokenId); // Transfef NFT from user to Contract

        listing[nft_][tokenId] = Orders({seller: msg.sender, price: price});

        emit NftListed(nft_, tokenId, msg.sender, price);
    }

    function BuyNft(address nft_, uint256 tokenId) external payable {
        Orders memory orders = listing[nft_][tokenId];
        require(listing[nft_][tokenId].seller != address(0), "NFT not listed");
        require(msg.value == listing[nft_][tokenId].price, "Incorrect Price");

        delete listing[nft_][tokenId];

        payable(listing[nft_][tokenId].seller).transfer(msg.value);

        IERC721(nft_).safeTransferFrom(address(this), msg.sender, tokenId);

        emit NftBought(nft_, tokenId, msg.sender, listing[nft_][tokenId].price);
    }

    function cancelListing(address nft_, uint256 tokenId) external {
        Orders memory orders = listing[nft_][tokenId];
        require(
            listing[nft_][tokenId].seller == msg.sender,
            "Only Seller can cancel"
        );

        delete listing[nft_][tokenId];

        IERC721(nft_).safeTransferFrom(address(this), msg.sender, tokenId);

        emit ListingCancelled(nft_, tokenId, msg.sender);
    }
}
