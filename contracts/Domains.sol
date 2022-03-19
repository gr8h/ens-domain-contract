// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import { StringUtils } from "./libraries/StringUtils.sol";
import "hardhat/console.sol";

contract Domains {

    string public tld;

    mapping(string => address) public domains;
    mapping(string => string) public records;
    mapping(string => string) public emails;

    constructor(string memory _tld) payable {
        tld = _tld;
        console.log("%s is the NSD.", _tld);
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

        domains[name] = msg.sender;
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