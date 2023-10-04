// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// openzeppelin util for encoding onChain
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


contract MoodNft is ERC721, Ownable {
    error ERC721Metadata__URI_QueryFor_NonExistentToken();
    error MoodNft__CantFlipMoodIfNotOwner();

     enum NFTState {
        HAPPY,
        SAD
    }

    uint256 private s_tokenCounter;
    mapping(uint256 => NFTState) private s_tokenIdToState;

    event CreatedNFT(uint256 indexed tokenId);

    // we encode the svg by going to its directory and running : base64 -i happy.svg
    // this produces the below encoded string : 
    /*   
    PHN2ZyB2aWV3Qm94PSIwIDAgMjAwIDIwMCIgd2lkdGg9IjQwMCIgIGhlaWdodD0iNDAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxjaXJjbGUgY3g9IjEwMCIgY3k9IjEwMCIgZmlsbD0ieWVsbG93IiByPSI3OCIgc3Ryb2tlPSJibGFjayIgc3Ryb2tlLXdpZHRoPSIzIi8+CiAgPGcgY2xhc3M9ImV5ZXMiPgogICAgPGNpcmNsZSBjeD0iNjEiIGN5PSI4MiIgcj0iMTIiLz4KICAgIDxjaXJjbGUgY3g9IjEyNyIgY3k9IjgyIiByPSIxMiIvPgogIDwvZz4KICA8cGF0aCBkPSJtMTM2LjgxIDExNi41M2MuNjkgMjYuMTctNjQuMTEgNDItODEuNTItLjczIiBzdHlsZT0iZmlsbDpub25lOyBzdHJva2U6IGJsYWNrOyBzdHJva2Utd2lkdGg6IDM7Ii8+Cjwvc3ZnPg==    
    */
    // if we prepend : data:image/svg+xml;base64,
    /*   
    data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjAwIDIwMCIgd2lkdGg9IjQwMCIgIGhlaWdodD0iNDAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxjaXJjbGUgY3g9IjEwMCIgY3k9IjEwMCIgZmlsbD0ieWVsbG93IiByPSI3OCIgc3Ryb2tlPSJibGFjayIgc3Ryb2tlLXdpZHRoPSIzIi8+CiAgPGcgY2xhc3M9ImV5ZXMiPgogICAgPGNpcmNsZSBjeD0iNjEiIGN5PSI4MiIgcj0iMTIiLz4KICAgIDxjaXJjbGUgY3g9IjEyNyIgY3k9IjgyIiByPSIxMiIvPgogIDwvZz4KICA8cGF0aCBkPSJtMTM2LjgxIDExNi41M2MuNjkgMjYuMTctNjQuMTEgNDItODEuNTItLjczIiBzdHlsZT0iZmlsbDpub25lOyBzdHJva2U6IGJsYWNrOyBzdHJva2Utd2lkdGg6IDM7Ii8+Cjwvc3ZnPg==
    */
    // then we have an encoded version of the svg which we can directly pass to the contract. We can also 
    // encode it on chain but the above method saves us gas

    string private s_happySvgImageUri;
    string private s_sadSvgImageUri;

    constructor(string memory sadSvgImageUri, string memory happySvgImageUri) ERC721("Mood NFT", "MN") {
        s_tokenCounter = 0;
        s_happySvgImageUri = happySvgImageUri;
        s_sadSvgImageUri = sadSvgImageUri;
    }

    function mintNft() public {
        uint256 tokenCounter = s_tokenCounter;
        _safeMint(msg.sender, tokenCounter);
        s_tokenCounter ++;
        emit CreatedNFT(tokenCounter);
    }

    function flipMood(uint256 tokenId) public {
        if (!_isApprovedOrOwner(msg.sender, tokenId)) {
            revert MoodNft__CantFlipMoodIfNotOwner();
        }

        if (s_tokenIdToState[tokenId] == NFTState.HAPPY) {
            s_tokenIdToState[tokenId] = NFTState.SAD;
        } else {
            s_tokenIdToState[tokenId] = NFTState.HAPPY;
        }
    }


     function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view override returns(string memory){
        if (!_exists(tokenId)) {
            revert ERC721Metadata__URI_QueryFor_NonExistentToken();
        }
        string memory imageURI = s_happySvgImageUri;

        if (s_tokenIdToState[tokenId] == NFTState.SAD) {
            imageURI = s_sadSvgImageUri;
        }
        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name(), // You can add whatever name here
                                '", "description":"An NFT that reflects the mood of the owner, 100% on Chain!", ',
                                '"attributes": [{"trait_type": "moodiness", "value": 100}], "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
    
     function getHappySVG() public view returns (string memory) {
        return s_happySvgImageUri;
    }

    function getSadSVG() public view returns (string memory) {
        return s_sadSvgImageUri;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

     function getTokenState(uint256 tokenId) public view returns (NFTState) {
        return s_tokenIdToState[tokenId];
    }
}