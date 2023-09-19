// SPDX-License-Identifier : MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

error Marketplace__isnotListed();

contract Markeplace {
    struct Listing {
        uint256 price;
        address seller;
        uint256 quantity;
    }

    mapping(address => mapping(uint256 => Listing)) private s_listings;
    mapping(address => uint256) private s_proceeds;
    uint256 public constant MAX_QUANTITY = 100;
    uint256 public constant MAX_PRICE = 100 ether;

    /**
     * 4 EVENTS
     */
    //ITEMLISTED
    event assetListed(
        address indexed contractAddress, uint256 indexed tokenId, uint256 quantity, uint256 indexed price
    );
    event assetBought(
        address indexed contractAddress,
        uint256 indexed tokenId,
        uint256 quantity,
        uint256 indexed totalprice,
        address buyer,
        address seller
    );
    event listingUpdated(
        address indexed contractAddress,
        uint256 indexed tokenId,
        uint256 newQuantity,
        uint256 indexed newPrice,
        address updater
    );
    event assetRemoved(
        address indexed contractAddress,
        uint256 indexed tokenId,
        uint256 quantity,
        uint256 indexed price,
        address seller
    );
    event ProceedsWithdrawn(address to, uint256 amount);

    //ITEMPRICEUPDATED or ITEM ANYTHING UPDATED
    //ITEM REMOVED
    //ITEM BUYED BY SOMEONE

    //TWO MODIFIERS
    modifier isListed(address tokenAddress, uint256 tokenId) {
        require(s_listings[msg.sender][tokenId].seller != address(0), "Marketplace__isnotListed");
        _;
    }

    modifier isNotListed(address tokenAddress, uint256 tokenId) {
        require(s_listings[msg.sender][tokenId].seller == address(0), "Marketplace__isAlreadyListed");
        _;
    }

    //ONLY OWNER OF NFT

    /* Four Functions right */
    // LIST NFT"S
    function ListAssets(address TokenAddress, uint256 tokenId, uint256 quantity, uint256 price)
        external
        isNotListed(TokenAddress, tokenId)
    {
        if (price <= 0 || price > MAX_PRICE) revert();
        if (quantity <= 0 || quantity > MAX_QUANTITY) revert();
        if (!_isApprovedForAll(TokenAddress, msg.sender)) {
            revert("You are not allowed to list assets, Not Approved!!");
        }
        IERC1155 token = IERC1155(TokenAddress);
        require(token.balanceOf(msg.sender, tokenId) >= quantity, "Insufficient balance");
        token.safeTransferFrom(msg.sender, address(this), tokenId, quantity, "");
        s_listings[msg.sender][tokenId] = Listing(price, msg.sender, quantity);
        emit assetListed(msg.sender, tokenId, quantity, price);
    }

    function _isApprovedForAll(address TokenAddress, address owner) private view returns (bool) {
        IERC1155 token = IERC1155(TokenAddress);
        return token.isApprovedForAll(owner, address(this));
    }

    // function to buy NFT's marketplace
    function BuyAssets(address TokenAddress, uint256 tokenId, uint256 quantity)
        external
        payable
        isListed(TokenAddress, tokenId)
    {
        Listing storage listing = s_listings[msg.sender][tokenId];
        if (quantity <= 0 || quantity > listing.quantity) revert();
        uint256 totalPrice = listing.price * quantity;
        require(msg.value == totalPrice, "Not enough funds sent");

        s_proceeds[listing.seller] += totalPrice;
        if (quantity == listing.quantity) {
            delete s_listings[msg.sender][tokenId];
        } else {
            listing.quantity -= quantity;
        }
        IERC1155 token = IERC1155(TokenAddress);
        token.safeTransferFrom(address(this), msg.sender, tokenId, quantity, "");
        emit assetBought(TokenAddress, tokenId, quantity, totalPrice, msg.sender, listing.seller);
    }

    //UPDATE NFT"s
    function UpdateDetails(address TokenAddress, uint256 tokenId, uint256 newQuantity, uint256 newPrice)
        external
        isListed(TokenAddress, tokenId)
    {
        require(newQuantity > 0 && newQuantity <= MAX_QUANTITY, "You have exceeded max quantity");
        require(newPrice > 0 && newPrice <= MAX_PRICE, "You have exceeded max price");
        Listing storage listing = s_listings[msg.sender][tokenId];
        require(msg.sender == listing.seller);
        listing.quantity = newQuantity;
        listing.price = newPrice;
        emit listingUpdated(TokenAddress, tokenId, newQuantity, newPrice, msg.sender);
    }

    //Delete token from the marketplace
    function RemoveListing(address TokenAddress, uint256 tokenId) external isListed(TokenAddress, tokenId) {
        Listing storage listing = s_listings[msg.sender][tokenId];
        require(msg.sender == listing.seller, "Only the seller can remove the listing");
        IERC1155 token = IERC1155(TokenAddress);
        token.safeTransferFrom(address(this), msg.sender, tokenId, listing.quantity, "");
        delete s_listings[msg.sender][tokenId];
        emit assetRemoved(TokenAddress, tokenId, listing.quantity, listing.price, msg.sender);
    }

    function WithdrawProceeds() external {
        uint256 proceeds = s_proceeds[msg.sender];
        require(proceeds > 0, "No proceeds to withdraw");
        (bool k,) = payable(msg.sender).call{value: proceeds}("");
        if (!k) revert();
        emit ProceedsWithdrawn(msg.sender, proceeds);
    }

    function getProceeds(address _account) external view returns (uint256) {
        return s_proceeds[_account];
    }

    function getListingDetails(address tokenAddress, uint256 tokenId)
        external
        view
        returns (uint256 price, address seller, uint256 quantity)
    {
        Listing storage listing = s_listings[tokenAddress][tokenId];
        require(listing.seller != address(0), "Listing not found");
        return (listing.price, listing.seller, listing.quantity);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
