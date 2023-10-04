// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployHeroNft} from "../../script/DeployHeroNft.s.sol";
import {HeroNft} from "../../src/HeroNft.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {MintHeroNft} from "../../script/Interactions.s.sol";

contract HeroNftTest is StdCheats, Test {
    string constant NFT_NAME = "HeroNFT";
    string constant NFT_SYMBOL = "HGR";
    HeroNft public heroNft;
    DeployHeroNft public deployer;
    address public deployerAddress;

    string public constant Hero_URI =
        "ipfs://QmbnqkyYUku5S4wNbG19CvCcFuG7sttsJ12ivXLMmpCif3";
    address public saga = makeAddr("saga");

    function setUp() public {
        deployer = new DeployHeroNft();
        heroNft = deployer.run();
    }

    function testInitializedCorrectly() public view {
        console.log(heroNft.name(), NFT_NAME);
        console.log();
        assert(
            keccak256(abi.encodePacked(heroNft.name())) ==
                keccak256(abi.encodePacked((NFT_NAME)))
        );
        assert(
            keccak256(abi.encodePacked(heroNft.symbol())) ==
                keccak256(abi.encodePacked((NFT_SYMBOL)))
        );
    }

    function testCanMintAndHaveABalance() public {
        vm.prank(saga);
        heroNft.mintNft(Hero_URI);

        assert(heroNft.balanceOf(saga) == 1);
    }

    function testTokenURIIsCorrect() public {
        vm.prank(saga);
        heroNft.mintNft(Hero_URI);

        assert(
            keccak256(abi.encodePacked(heroNft.tokenURI(0))) ==
                keccak256(abi.encodePacked(Hero_URI))
        );
    }

    function testMintWithScript() public {
        uint256 startingTokenCount = heroNft.getTokenCounter();
        MintHeroNft mintHeroNft = new MintHeroNft();
        mintHeroNft.mintNftOnContract(address(heroNft));
        assert(heroNft.getTokenCounter() == startingTokenCount + 1);
    }

}