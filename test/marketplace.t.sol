// SPDX-Licenses-Identifier

pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/marketPlace.sol";
import "../src/nft.sol";

contract MarketPlaceTest is Test {
    MarketPlace public marketplace;
    NFT public nft;
    address public seller;
    address public buyer;

    function setUp() public {
        // Deploy NFT and MarketPlace contracts
        nft = new NFT();
        marketplace = new MarketPlace();

        // Assign roles
        seller = address(0x1);
        buyer = address(0x2);

        // Mint an NFT to the seller
        vm.prank(seller);
        nft.mint(1);

        // Approve the marketplace to manage the seller's NFT
        vm.prank(seller);
        nft.approve(address(marketplace), 1);
    }

    function testListNft() public {
        // Seller lists the NFT
        vm.prank(seller);
        marketplace.ListNft(address(nft), 1, 1 ether);

        // Verify listing details
        (address listedSeller, uint256 price) = marketplace.listing(
            address(nft),
            1
        );
        assertEq(listedSeller, seller);
        assertEq(price, 1 ether);
    }

    function testBuyNft() public {
        // Seller lists the NFT
        vm.prank(seller);
        marketplace.ListNft(address(nft), 1, 1 ether);

        // Buyer purchases the NFT
        vm.deal(buyer, 1 ether); // Fund the buyer
        vm.prank(buyer);
        marketplace.BuyNft{value: 1 ether}(address(nft), 1);

        // Verify ownership transfer
        assertEq(nft.ownerOf(1), buyer);

        // Verify listing removal
        (address listedSeller, uint256 price) = marketplace.listing(
            address(nft),
            1
        );
        assertEq(listedSeller, address(0));
        assertEq(price, 0);
    }

    function testCancelListing() public {
        // Seller lists the NFT
        vm.prank(seller);
        marketplace.ListNft(address(nft), 1, 1 ether);

        // Seller cancels the listing
        vm.prank(seller);
        marketplace.cancelListing(address(nft), 1);

        // Verify ownership transfer back to the seller
        assertEq(nft.ownerOf(1), seller);

        // Verify listing removal
        (address listedSeller, uint256 price) = marketplace.listing(
            address(nft),
            1
        );
        assertEq(listedSeller, address(0));
        assertEq(price, 0);
    }

    function testCannotListWithZeroPrice() public {
        // Attempt to list with zero price
        vm.prank(seller);
        vm.expectRevert("Listing price can not be Zero");
        marketplace.ListNft(address(nft), 1, 0);
    }

    function testCannotBuyWithIncorrectPrice() public {
        // Seller lists the NFT
        vm.prank(seller);
        marketplace.ListNft(address(nft), 1, 1 ether);

        // Attempt to buy with incorrect price
        vm.deal(buyer, 0.5 ether);
        vm.prank(buyer);
        vm.expectRevert("Incorrect Price");
        marketplace.BuyNft{value: 0.5 ether}(address(nft), 1);
    }

    function testCannotCancelIfNotSeller() public {
        // Seller lists the NFT
        vm.prank(seller);
        marketplace.ListNft(address(nft), 1, 1 ether);

        // Attempt to cancel listing by someone other than the seller
        vm.prank(buyer);
        vm.expectRevert("Only Seller can cancel");
        marketplace.cancelListing(address(nft), 1);
    }
}
