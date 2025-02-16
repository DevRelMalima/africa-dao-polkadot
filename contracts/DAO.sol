// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./GovernanceToken.sol";

 ==================== Structs ====================
    struct Proposal {
        address recipient;      // Address to receive funds if the proposal passes
        uint256 amount;         // Amount of funds to transfer
        string description;     // Description of the proposal
        uint256 votesFor;       // Total votes in favor
        uint256 votesAgainst;   // Total votes against
        bool executed;          // Whether the proposal has been executed
        uint256 deadline;       // Deadline for voting
    }

    // ==================== State Variables ====================
    mapping(address => bool) public members; // Tracks DAO members
    Proposal[] public proposals;            // Array of all proposals
    uint256 public quorum;                  // Minimum number of votes required for a proposal to pass
    GovernanceToken public token;           // Reference to the governance token

    // ==================== Events ====================
    event MemberAdded(address indexed member);             // Emitted when a new member is added
    event ProposalCreated(uint256 indexed proposalId);     // Emitted when a new proposal is created
    event Voted(uint256 indexed proposalId, bool vote);    // Emitted when a member votes on a proposal
    event ProposalExecuted(uint256 indexed proposalId);    // Emitted when a proposal is executed

    constructor(uint256 _quorum, address _tokenAddress) {
        require(_tokenAddress != address(0), "Invalid token address");
        quorum = _quorum;
        token = GovernanceToken(_tokenAddress);
        members[msg.sender] = true; // Add the deployer as the first member
        emit MemberAdded(msg.sender);
    }

    modifier onlyMember() {
        require(members[msg.sender], "Not a member");
        _;
    }

    function addMember(address _member) external onlyMember {
        require(!members[_member], "Already a member");
        members[_member] = true;
        emit MemberAdded(_member);
    }

    function createProposal(
        address _recipient,
        uint256 _amount,
        string memory _description,
        uint256 _votingPeriod // Duration in seconds
    ) external onlyMember {
        require(_recipient != address(0), "Invalid recipient address");

        Proposal memory newProposal = Proposal({
            recipient: _recipient,
            amount: _amount,
            description: _description,
            votesFor: 0,
            votesAgainst: 0,
            executed: false,
            deadline: block.timestamp + _votingPeriod
        });

        proposals.push(newProposal);
        emit ProposalCreated(proposals.length - 1);
    }

    function vote(uint256 _proposalId, bool _vote) external onlyMember {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(block.timestamp <= proposal.deadline, "Voting period over");

        uint256 votingPower = token.balanceOf(msg.sender);
        require(votingPower > 0, "No voting power");

        if (_vote) {
            proposal.votesFor += votingPower;
        } else {
            proposal.votesAgainst += votingPower;
        }

        emit Voted(_proposalId, _vote);
    }

    function executeProposal(uint256 _proposalId) external onlyMember {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(block.timestamp >= proposal.deadline, "Voting period not over");

        if (
            proposal.votesFor > proposal.votesAgainst &&
            proposal.votesFor + proposal.votesAgainst >= quorum
        ) {
            (bool success, ) = proposal.recipient.call{value: proposal.amount}("");
            require(success, "Transfer failed");

            proposal.executed = true;
            emit ProposalExecuted(_proposalId);
        }
    }

    function getProposalCount() external view returns (uint256) {
        return proposals.length;
    }

    function getProposal(uint256 _proposalId)
        external
        view
        returns (
            address recipient,
            uint256 amount,
            string memory description,
            uint256 votesFor,
            uint256 votesAgainst,
            bool executed,
            uint256 deadline
        )
    {
        Proposal memory proposal = proposals[_proposalId];
        return (
            proposal.recipient,
            proposal.amount,
            proposal.description,
            proposal.votesFor,
            proposal.votesAgainst,
            proposal.executed,
            proposal.deadline
        );
    }

    receive() external payable {
        revert("DAO does not accept direct Ether transfers");
    }
}