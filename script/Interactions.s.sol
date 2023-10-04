// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {HeroNft} from "../src/HeroNft.sol";
import {MoodNft} from "../src/MoodNft.sol";
//import {MoodNft} from "../src/MoodNft.sol";

contract MintHeroNft is Script {
    string public constant HERO_URI =
        "ipfs://QmbnqkyYUku5S4wNbG19CvCcFuG7sttsJ12ivXLMmpCif3";
    uint256 deployerKey;

    function run() external {
        address mostRecentlyDeployedHeroNft = DevOpsTools
            .get_most_recent_deployment("HeroNft", block.chainid);
        mintNftOnContract(mostRecentlyDeployedHeroNft);
    }

    function mintNftOnContract(address heroNftAddress) public {
        vm.startBroadcast();
        HeroNft(heroNftAddress).mintNft(HERO_URI);
        vm.stopBroadcast();
    }
}

contract MintMoodNft is Script {
    function run() external {
        address mostRecentlyDeployedBasicNft = DevOpsTools
            .get_most_recent_deployment("MoodNft", block.chainid);
        mintNftOnContract(mostRecentlyDeployedBasicNft);
    }

    function mintNftOnContract(address moodNftAddress) public {
        vm.startBroadcast();
        MoodNft(moodNftAddress).mintNft();
        vm.stopBroadcast();
    }
}

contract FlipMoodNft is Script {
    uint256 public constant TOKEN_ID_TO_FLIP = 0;

    function run() external {
        address mostRecentlyDeployedBasicNft = DevOpsTools
            .get_most_recent_deployment("MoodNft", block.chainid);
        flipMoodNft(mostRecentlyDeployedBasicNft);
    }

    function flipMoodNft(address moodNftAddress) public {
        vm.startBroadcast();
        MoodNft(moodNftAddress).flipMood(TOKEN_ID_TO_FLIP);
        vm.stopBroadcast();
    }
}

