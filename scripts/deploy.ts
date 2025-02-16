import { ethers, upgrades } from "hardhat";

async function main() {
  try {
    // Step 1: Deploy the Governance Token
    console.log("Deploying Governance Token...");
    const GovernanceToken = await ethers.getContractFactory("GovernanceToken");
    const governanceToken = await GovernanceToken.deploy(1000000); // Initial supply of 1M tokens
    await governanceToken.waitForDeployment();

    if (!governanceToken.target) {
      throw new Error("Governance Token deployment failed.");
    }

    console.log(`Governance Token deployed to: ${governanceToken.target}`);

    // Step 2: Deploy the DAO Proxy
    console.log("Deploying DAO Proxy...");
    const DAO = await ethers.getContractFactory("DAO");

    const daoProxy = await upgrades.deployProxy(DAO, [2, governanceToken.target]); 
    await daoProxy.waitForDeployment();

    if (!daoProxy.target) {
      throw new Error("DAO Proxy deployment failed.");
    }

    console.log(`DAO Proxy deployed to: ${daoProxy.target}`);
  } catch (error) {
    console.error("Deployment failed:", error);
    process.exitCode = 1;
  }
}

main();