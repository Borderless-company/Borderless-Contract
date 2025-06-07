import { task } from "hardhat/config";
import { ethers } from "hardhat";

task("grant-role", "Grant a role to an account")
  .addParam("contract", "The contract address")
  .addParam("role", "The role to grant (default_admin, founder, treasury, signature, accounting, minter)")
  .addParam("account", "The account to grant the role to")
  .setAction(async (taskArgs, hre) => {
    const { ethers } = hre;
    const contract = await ethers.getContractAt("BorderlessAccessControl", taskArgs.contract);

    // Convert role string to bytes32
    let roleBytes32: string;
    switch (taskArgs.role.toLowerCase()) {
      case "default_admin":
        roleBytes32 = "0x0000000000000000000000000000000000000000000000000000000000000000";
        break;
      case "founder":
        roleBytes32 = ethers.keccak256(ethers.toUtf8Bytes("FOUNDER_ROLE"));
        break;
      case "treasury":
        roleBytes32 = ethers.keccak256(ethers.toUtf8Bytes("TREASURY_ROLE"));
        break;
      case "signature":
        roleBytes32 = ethers.keccak256(ethers.toUtf8Bytes("SIGNATURE_ROLE"));
        break;
      case "accounting":
        roleBytes32 = ethers.keccak256(ethers.toUtf8Bytes("ACCOUNTING_ROLE"));
        break;
      case "minter":
        roleBytes32 = ethers.keccak256(ethers.toUtf8Bytes("MINTER_ROLE"));
        break;
      default:
        console.log("Invalid role. Available roles: default_admin, founder, treasury, signature, accounting, minter");
        process.exit(1);
    }

    try {
      const tx = await contract.grantRole(roleBytes32, taskArgs.account);
      await tx.wait();
      console.log(`Successfully granted ${taskArgs.role} role to ${taskArgs.account}`);
    } catch (error) {
      console.error("Error granting role:", error);
      process.exit(1);
    }
  }); 