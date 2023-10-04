// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract HeroNft is ERC721 {
    error BasicNft__TokenUriNotFound();

    string public constant Hero_URI ="ipfs://QmbnqkyYUku5S4wNbG19CvCcFuG7sttsJ12ivXLMmpCif3";
    uint256 private s_tokenCounter;
    mapping(uint256 => string) s_tokenIdToUri; 
    
    constructor() ERC721("HeroNFT", "HGR") {
        s_tokenCounter = 0;
    }

    function mintNft(string memory tokenUri) public {
        s_tokenIdToUri[s_tokenCounter] = tokenUri;
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter ++;
    }

    function tokenURI(uint256 tokenId) public view override returns(string memory) {
        if (!_exists(tokenId)) {
            revert BasicNft__TokenUriNotFound();
        }
        return s_tokenIdToUri[tokenId];
    }

        function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
