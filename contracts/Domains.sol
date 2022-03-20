// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import { StringUtils } from "./libraries/StringUtils.sol";
import {Base64} from "./libraries/Base64.sol";

import "hardhat/console.sol";

contract Domains is ERC721URIStorage {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string public tld;

    // We'll be storing our NFT images on chain as SVGs
    string svgPartOne = '<svg xmlns="http://www.w3.org/2000/svg" width="270" height="270" fill="none"><path fill="url(#B)" d="M0 0h270v270H0z"/><defs><filter id="A" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="270" width="270"><feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".225" width="200%" height="200%"/></filter></defs><svg x="85" y="-60" width="70" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1333.3 1062.26" shape-rendering="geometricPrecision" text-rendering="geometricPrecision" image-rendering="optimizeQuality" fill-rule="evenodd" clip-rule="evenodd"><defs><style>.fil0{fill:#2058b6}</style></defs><g id="Layer_x0020_1"><g id="_1473327709744"><path stroke-width="10" class="fil0" d="M512.04 551.2c-39.86 7.98-39.86 55.8-31.89 119.6 7.98 71.75 31.89 119.6 71.76 111.63 39.87 0 39.87-55.82 31.9-119.6-7.97-63.78-23.93-111.63-71.76-111.63z"/><path stroke-width="10" class="fil0" d="M1333.3 630.93s-23.94-111.61-143.53-207.29c-111.63-79.74-231.23-71.77-231.23-71.77s31.9-63.79 119.6-111.63c79.74-39.87 191.35-47.82 191.35-47.82s-71.75-87.72-215.27-143.53C878.8-14.9 735.29-14.9 559.87 40.92 368.5 104.71 232.96 256.2 232.96 256.2S41.6 200.38 9.7 248.21c-39.86 47.86 55.82 231.24 55.82 231.24S41.59 535.26 49.56 638.9c7.98 111.63 71.78 191.38 71.78 191.38-31.9 7.95-63.79 23.9-63.79 47.82 0 23.93 47.84 47.85 103.65 47.85h23.93c55.8 55.8 135.54 127.55 255.14 135.53 151.49 7.97 247.17-47.82 310.96-63.78 71.75-23.93 175.41-23.93 239.19-23.93 191.36 23.93 271.08 71.78 271.08 71.78s7.97-87.73-71.75-207.33c-63.79-87.7-191.37-119.58-191.37-119.58s63.79-55.82 143.53-71.78c103.67-23.89 191.38-15.94 191.38-15.94zM121.36 766.48c-15.95-31.9-23.93-63.78-31.9-159.48 0-47.82 15.95-103.63 39.86-111.61 31.9-7.97 31.9 47.85 47.85 95.69 0 15.92 15.94 39.85 23.91 63.78-7.97-7.98-7.97-7.98-7.97 0-23.91 0-31.89 47.85-15.94 103.65 7.97 31.9 23.91 63.8 39.86 71.78-15.95 0-31.89-7.97-55.81-7.97 0 0-7.97 0-7.97 7.97-7.98-15.98-23.93-39.88-31.89-63.81zm494.33 0c-39.86 79.73-103.65 103.65-175.41 103.65-71.78 0-119.6-39.85-191.37-31.9 15.96-15.93 15.96-55.8 7.97-103.65-7.97-7.97-7.97-15.93-15.95-31.87 23.94 15.95 39.87-7.97 39.87-7.97s7.96-119.6 47.83-199.34c31.89-63.78 79.73-111.63 151.49-119.59 63.79-15.95 111.63 31.89 135.54 103.65 23.93 71.74 31.91 207.3.01 287.02z"/></g></g></svg><defs><linearGradient id="B" x1="0" y1="0" x2="27" y2="270" gradientUnits="userSpaceOnUse"><stop stop-color="#fff"/><stop offset="1" stop-color="#093871" stop-opacity=".99"/></linearGradient></defs><text x="32.5" y="231" font-size="27" fill="#fff" filter="url(#A)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
    string svgPartTwo = '</text></svg>';

    mapping(string => address) public domains;
    mapping(string => string) public records;
    mapping(string => string) public emails;

    constructor(string memory _tld) payable ERC721("Sonic Name Service", "BNS"){
        tld = _tld;
        console.log("%s is the Name service Domain.", _tld);
    }

    function price(string calldata name) public pure returns(uint) {
        uint len = StringUtils.strlen(name);
        require(len > 0);
        if (len == 3) {
            return 5 * 10**16; // 5 MATIC = 5 000 000 000 000 000 000 (18 decimals). We're going with 0.5 Matic cause the faucets don't give a lot
        } else if (len == 4) {
            return 3 * 10**16; // To charge smaller amounts, reduce the decimals. (^ 17 is 0.3)
        } else {
            return 1 * 10**16;
        }
    }

    // A register function that adds their names to our mapping
    function register(string calldata name) public payable {

        // Check that the name is unregistered (explained in notes)
        require(domains[name] == address(0));

        uint _price = price(name);
        // Check if enough Matic was paid in the transaction
        require(msg.value >= _price, "Not enough Matic paid");

        // Combine the name passed into the function  with the TLD
        string memory _name = string(abi.encodePacked(name, ".", tld));
        // Create the SVG (image) for the NFT with the name
        string memory finalSvg = string(abi.encodePacked(svgPartOne, _name, svgPartTwo));

        uint256 newRecordId = _tokenIds.current();
  	    uint256 length = StringUtils.strlen(name);
		string memory strLen = Strings.toString(length);
        console.log("Registering %s.%s on the contract with tokenID %d", name, tld, newRecordId);

        // Create the JSON metadata of our NFT. We do this by combining strings and encoding as base64
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', _name,
                        '", "description": "A domain on the Sonic name service", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(finalSvg)),
                        '","length":"', strLen,
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(abi.encodePacked("data:application/json;base64,", json));

        console.log("\n--------------------------------------------------------");
	    console.log("Final tokenURI", finalTokenUri);
	    console.log("--------------------------------------------------------\n");

        _safeMint(msg.sender, newRecordId);
        _setTokenURI(newRecordId, finalTokenUri);
        domains[name] = msg.sender;

        _tokenIds.increment();
        console.log("%s has registered a domain!", msg.sender);
    }

    // This will give us the domain owners' address
    function getAddress(string calldata name) public view returns(address) {
        return domains[name];
    }

    function setRecord(string calldata name, string calldata record) public {
        // Check that the owner is the transaction sender
        require(domains[name] == msg.sender);
        records[name] = record;
    }

    function getRecord(string calldata name) public view returns(string memory) {
        return records[name];
    }
}