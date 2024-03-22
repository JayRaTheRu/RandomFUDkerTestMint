// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts@4.0.0/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.0.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.0.0/security/Pausable.sol";
import "@openzeppelin/contracts@4.0.0/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract FUDkersTN is ERC721Enumerable, Ownable, Pausable {
    using Strings for uint256;

    uint256 public mintPrice = 0.05 ether;
    string private baseURI;
    string[] private _cardNames = [
        "Viny-L",
        "Bloo",
        "Lou-Cypher",
        "kiETH",
        "Krypta",
        "Pe-Pe",
        "Pau-Lee",
        "Ayuh",
        "YuDoo-YuGee",
        "FunKer",
        "JBee",
        "JoeJo",
        "TyRa",
        "eM-eF"
    ];
    mapping(uint256 => uint256) public cardScores;
    mapping(uint256 => uint256) private _cardTypes;

    constructor(string memory initialBaseURI)
        ERC721("FUDkersTN", "FUDkersMagmaTN")
    {
        setBaseURI(initialBaseURI);
        transferOwnership(msg.sender); // Explicitly set the contract owner
    }

    function mint(uint256 quantity) public payable whenNotPaused {
        require(
            quantity == 1 || quantity == 5,
            "Can only mint 1 or 5 at a time"
        );
        require(msg.value >= mintPrice * quantity, "Ether sent is not correct");

        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = totalSupply() + 1;
            uint256 cardType = _randomCardType();
            _safeMint(msg.sender, tokenId);
            _cardTypes[tokenId] = cardType;
            cardScores[tokenId] = _randomScore();
        }
    }

    function _randomCardType() private view returns (uint256) {
        uint256 random = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, msg.sender, totalSupply())
            )
        ) % 1000;
        // Let Solidity infer the array type
        uint256[] memory thresholds = new uint256[](14);
        thresholds[0] = 100;
        thresholds[1] = 200;
        thresholds[2] = 300;
        thresholds[3] = 400;
        thresholds[4] = 500;
        thresholds[5] = 600;
        thresholds[6] = 700;
        thresholds[7] = 800;
        thresholds[8] = 875;
        thresholds[9] = 925;
        thresholds[10] = 950;
        thresholds[11] = 975;
        thresholds[12] = 990;
        thresholds[13] = 1000;

        for (uint256 i = 0; i < thresholds.length; i++) {
            if (random < thresholds[i]) {
                return i;
            }
        }
        return thresholds.length - 1; // Safeguard, should not be reached
    }

    function _randomScore() private view returns (uint256) {
        return
            (uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, totalSupply())
                )
            ) % 100) + 1;
    }

    function setMintPrice(uint256 _mintPrice) external onlyOwner {
        mintPrice = _mintPrice;
    }

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        baseURI = newBaseURI;
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        // Retrieve the card name for the tokenId
        string memory cardName = _cardNames[_cardTypes[tokenId]];

        // Convert the card name to lowercase to match your file naming convention
        string memory imageName = toLower(cardName);

        // Construct the image URL using the base URI and the lowercase card name
        string memory imageURI = string(
            abi.encodePacked(baseURI, imageName, "_magma.png")
        );

        string memory name = string(
            abi.encodePacked(cardName, " #", tokenId.toString())
        );
        string memory description = "Meet the FUDkers, a whole bunch of FUDkers who live in the 'Neighborhood On The Blockchain'! These are the Magma:Onyx TESTNET 'FUDkers' Card Editions.\n\nSometimes you see more clearly with your two eyes shut. Most want to see 'TO THE MOON' &, 'WAGMI', but when you keep it REAL, that's when you become a FUDker.. And FUDkers are ALWAYS welcome in the Neighborhood O.T.B.";
        string memory score = cardScores[tokenId].toString();

        // Construct the JSON metadata
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name":"',
                        name,
                        '", ',
                        '"description":"',
                        description,
                        '", ',
                        '"attributes":[{"trait_type":"Score", "value": ',
                        score,
                        "}], ",
                        '"image":"',
                        imageURI,
                        '"}'
                    )
                )
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    // Helper function to convert a string to lowercase
    function toLower(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint256 i = 0; i < bStr.length; i++) {
            // If uppercase character, convert to lowercase
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }
}
