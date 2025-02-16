
import { ethers } from "hardhat";

async function main() {
    const [deployer, member1, member2] = await ethers.getSigners();

    const GovernanceToken = await ethers.getContractFactory("GovernanceToken");
    const governanceToken = GovernanceToken.attach("GOVERNANCE_TOKEN_ADDRESS"); // Replace with deployed token address

    const DAO = await ethers.getContractFactory("DAO");
    const dao = DAO.attach("DAO_CONTRACT_ADDRESS"); // Replace with deployed DAO address

    // Add members
    await dao.addMember(member1.address);
    await dao.addMember(member2.address);

    console.log("Members added:", member1.address, member2.address);

    // Create a proposal
    const recipient = deployer.address;
    const amount = ethers.parseEther("1");
    const description = "Fund this project";
    const votingPeriod = 60; // 60 seconds
    const createProposalTx = await dao.connect(member1).propose(recipient, amount, description, votingPeriod);
    await createProposalTx.wait();

    console.log("Proposal created");

    // Vote on the proposal
    const proposalId = 0; // Replace with actual proposal ID
    await dao.connect(member1).castVote(proposalId, true);
    await dao.connect(member2).castVote(proposalId, true);

    console.log("Votes cast");

    // Fast forward time
    await ethers.provider.send("evm_increaseTime", [61]);
    await ethers.provider.send("evm_mine", []);

    // Execute the proposal
    const executeProposalTx = await dao.connect(member1).executeProposal(proposalId);
    await executeProposalTx.wait();

    console.log("Proposal executed");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});