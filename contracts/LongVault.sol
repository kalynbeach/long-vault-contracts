// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


// > LongVault creation
// - TODO: Read up on factory pattern, implement it as needed

// > LongVault setup
// - TODO: Ensure eth receive() works as intended
// - TODO: Figure out of fallback() is necessary

// > LongVault opertation & maintainence
// - TODO: Create release() calling mechanism
// -- Needs to check current datetime against Release struct/object timestamps

// > Web3.js
// - TODO: Start writing tests
// - TODO: Learn how Web3.js interface is involved in contract creation


contract LongVault is AccessControl {
    using Address for address payable;

    event EtherDeposited(uint timestamp, uint amount);
    event EtherReleased(uint timestamp, uint amount);
    event ERC20Deposited(address token, uint timestamp, uint amount);
    event ERC20Released(address token, uint timestamp, uint amount);

    struct EtherRelease {
        uint id;
        uint amount;
        uint timestamp;
        bool released;
    }

    struct ERC20Release {
        uint id;
        address token;
        uint amount;
        uint timestamp;
        bool released;
    }

    EtherRelease[] public etherReleases;
    ERC20Release[] public erc20Releases;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant BENEFICIARY_ROLE = keccak256("BENEFICIARY_ROLE");
    address public admin;
    address payable public beneficiary;

    mapping(address => uint) public erc20Tokens;
    
    uint public createdAt;
    uint public totalReleaseCount;
    uint public nextRelease;
    uint etherReleaseCount;
    uint erc20ReleaseCount;
    uint lastDepositDate;
    uint lastDepositToken;
    uint lastDepositAmount;
    
    constructor(address payable beneficiary_) {
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(BENEFICIARY_ROLE, beneficiary_);
        admin = msg.sender;
        beneficiary = beneficiary_;
        createdAt = block.timestamp;
    }

    // Receive ETH (when msg.data is empty)
    receive() external payable {
        // TODO: Implement as needed
    }

    // Called when msg.data is not empty
    fallback() external payable {

    }

    // Deposit Ether
    function deposit() public payable virtual onlyRole(ADMIN_ROLE) {
        // uint amount = msg.value;
        emit EtherDeposited(block.timestamp, msg.value);
    }

    // Deposit ERC20 tokens
    function depositERC20(
        address token_,
        uint amount_
    ) public payable onlyRole(ADMIN_ROLE) {
        erc20Tokens[token_] += amount_;
        lastDepositAmount = amount_;
        lastDepositDate = block.timestamp;
        emit ERC20Deposited(token_, block.timestamp, amount_);
    }

    // Release ether to beneficiary
    function releaseEther(EtherRelease memory release_) public onlyRole(ADMIN_ROLE) {
        uint amount = release_.amount;
        beneficiary.sendValue(amount);
        emit EtherReleased(block.timestamp, amount);
    }

    // Release ERC20 tokens to beneficiary
    function releaseERC20(ERC20Release memory release_) public onlyRole(ADMIN_ROLE) {
        address token = release_.token;
        uint amount = release_.amount;
        // TODO: Send tokens to beneficiary wallet
        emit ERC20Released(token, block.timestamp, amount);
    }

    // Create and add a new ether Release
    function createEtherRelease(
        uint amount_,
        uint releaseTimestamp_
    ) public onlyRole(ADMIN_ROLE) {
        etherReleases.push(EtherRelease({
            id: etherReleaseCount,
            amount: amount_,
            timestamp: releaseTimestamp_,
            released: false
        }));
        etherReleaseCount++;
        totalReleaseCount++;
    }

    // Create and add a new ERC20 token Release
    function createERC20Release(
        address token_,
        uint amount_,
        uint releaseTimestamp_
    ) public onlyRole(ADMIN_ROLE) {
        erc20Releases.push(ERC20Release({
            id: erc20ReleaseCount,
            token: token_,
            amount: amount_,
            timestamp: releaseTimestamp_,
            released: false
        }));
        erc20ReleaseCount++;
        totalReleaseCount++;
    }

    // Ether balance
    function getEtherBalance() public view returns (uint) {
        return address(this).balance;
    }

    // ERC20 token balance
    function getERC20Balance(address token_) public view returns (uint) {
        return erc20Tokens[token_];
    }
    
}