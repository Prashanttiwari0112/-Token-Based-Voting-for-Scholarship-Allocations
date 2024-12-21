// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScholarshipVoting {
    address public admin;
    uint256 public totalScholarships;
    mapping(address => uint256) public tokenBalances;
    mapping(uint256 => Scholarship) public scholarships;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    struct Scholarship {
        uint256 id;
        string description;
        uint256 votes;
    }

    uint256 public nextScholarshipId;

    event TokensMinted(address to, uint256 amount);
    event ScholarshipProposed(uint256 id, string description);
    event Voted(uint256 scholarshipId, address voter);
    event ScholarshipWinner(uint256 scholarshipId, string description, uint256 votes);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function mintTokens(address to, uint256 amount) external onlyAdmin {
        require(amount > 0, "Amount must be greater than zero");
        tokenBalances[to] += amount;
        emit TokensMinted(to, amount);
    }

    function proposeScholarship(string memory description) external onlyAdmin {
        scholarships[nextScholarshipId] = Scholarship({
            id: nextScholarshipId,
            description: description,
            votes: 0
        });

        emit ScholarshipProposed(nextScholarshipId, description);

        nextScholarshipId++;
    }

    function vote(uint256 scholarshipId) external {
        require(tokenBalances[msg.sender] > 0, "No tokens to vote");
        require(!hasVoted[scholarshipId][msg.sender], "Already voted for this scholarship");

        Scholarship storage scholarship = scholarships[scholarshipId];
        require(bytes(scholarship.description).length > 0, "Scholarship does not exist");

        scholarship.votes += tokenBalances[msg.sender];
        hasVoted[scholarshipId][msg.sender] = true;

        emit Voted(scholarshipId, msg.sender);
    }

    function declareWinner(uint256 scholarshipId) external onlyAdmin {
        Scholarship memory scholarship = scholarships[scholarshipId];
        require(bytes(scholarship.description).length > 0, "Scholarship does not exist");

        emit ScholarshipWinner(scholarshipId, scholarship.description, scholarship.votes);
    }

    function getScholarship(uint256 scholarshipId) external view returns (Scholarship memory) {
        return scholarships[scholarshipId];
    }

    function getTokenBalance(address user) external view returns (uint256) {
        return tokenBalances[user];
    }
}