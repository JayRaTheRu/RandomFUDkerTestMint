// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FUDkers is ERC721Enumerable, Ownable {
    string private baseURI;
    uint256 public constant MAX_SUPPLY = 1700; // Total supply across all card types
    uint256[17] public cardSupplies; // Track supply for each card type
    uint256 public mintPrice; // Adjustable mint price
    uint256 public saleStartTime; // Sale start time
    uint256 public saleEndTime; // Sale end time

    // Events for contract configuration changes
    event BaseURIChanged(string newBaseURI);
    event MintPriceChanged(uint256 newMintPrice);
    event SaleTimeChanged(uint256 newSaleStartTime, uint256 newSaleEndTime);

    constructor() ERC721("FUDkers", "FUDK") {}

    // Modifier to check if the sale is active
    modifier saleIsActive() {
        require(block.timestamp >= saleStartTime && block.timestamp <= saleEndTime, "Sale is not active");
        _;
    }

    // Public mint function with payable to enforce mint price
    function mint() public payable saleIsActive {
        require(msg.value >= mintPrice, "Insufficient payment for minting");
        require(totalSupply() < MAX_SUPPLY, "All cards are minted");
        uint256 cardType = _randomCardType();
        uint256 tokenId = totalSupply() + 1;
        _safeMint(msg.sender, tokenId);
        cardSupplies[cardType]++;
    }

    // Admin function to set the base URI for metadata
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
        emit BaseURIChanged(baseURI);
    }

    // Admin function to set the mint price
    function setMintPrice(uint256 _newMintPrice) public onlyOwner {
        mintPrice = _newMintPrice;
        emit MintPriceChanged(mintPrice);
    }

    // Admin function to set the sale start and end times
    function setSaleTime(uint256 _saleStartTime, uint256 _saleEndTime) public onlyOwner {
        require(_saleEndTime > _saleStartTime, "End time must be after start time");
        saleStartTime = _saleStartTime;
        saleEndTime = _saleEndTime;
        emit SaleTimeChanged(saleStartTime, saleEndTime);
    }

    // Admin function to withdraw contract balance to the owner's wallet
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds available");
        payable(owner()).transfer(balance);
    }

    // Override to return the set baseURI
    protected override function _baseURI() internal view returns (string memory) {
        return baseURI;
    }

    // Token URI construction based on card type
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Query for nonexistent token");
        string memory base = _baseURI();
        uint256 cardType = (tokenId - 1) % 17 + 1; // Simplified card type logic
        return bytes(base).length > 0 ? string(abi.encodePacked(base, _toString(cardType), ".jpg")) : "";
    }

    // Internal function for simplified "random" card type selection
    function _randomCardType() internal view returns (uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 17;
        while (cardSupplies[random] >= 100) {
            random = (random + 1) % 17;
        }
        return random;
    }

    // Utility to convert uint256 to string
    function _toString(uint256 value) internal pure returns (string memory) {
        bytes memory buffer = new bytes(78);
        uint256 length = 0;
        do {
            buffer[length++] = bytes1(uint8(48 + value % 10));
            value /= 10;
        } while (value != 0);
        bytes memory str = new bytes(length);
        for (uint256 i = 0; i < length; i++) {
            str[i] = buffer[length - 1 - i];
        }
        return string(str);
    }
}
