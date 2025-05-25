import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import type {
  Governance_JP_LLC,
  LETS_JP_LLC_EXE,
  LETS_JP_LLC_NON_EXE,
} from "../typechain-types";
import { deployFullFixture } from "./utils/DeployFixture";
import { createCompany } from "./utils/CreateCompany";
import { tokenMintFromTokenMinter } from "./utils/LETSMint";
import { grantMinterRole } from "./utils/Role";

describe("Governance_JP_LLC Service", function () {
  const getGovernance = async () => {
    const { deployer, proxy, founder, executiveMember, executiveMember2 } =
      await loadFixture(deployFullFixture);
    const { companyAddress, services } = await createCompany();

    // Get Governance_JP_LLC contract instance
    const governance = (await ethers.getContractAt(
      "Governance_JP_LLC",
      companyAddress
    )) as Governance_JP_LLC;
    const letsExe = services[2] as unknown as LETS_JP_LLC_EXE;
    const letsNonExe = services[4] as unknown as LETS_JP_LLC_NON_EXE;
    return {
      deployer,
      proxy,
      founder,
      executiveMember,
      executiveMember2,
      governance,
      letsExe,
      letsNonExe,
    };
  };

  describe("Transaction Registration", function () {
    it("should register a transaction with standard threshold (LEVEL_1)", async function () {
      const { founder, executiveMember, governance, letsExe, letsNonExe } =
        await getGovernance();

      // Prepare transaction parameters
      const value = 0;
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 0; // LEVEL_1 (2/3)
      const voteStart = Math.floor(Date.now() / 1000);
      const voteEnd = voteStart + 3600; // 1 hour later
      const proposalMemberContracts = [letsExe];

      // Register transaction
      const tx = await governance
        .connect(founder)
        .registerTransaction(
          value,
          data,
          to,
          executor,
          proposalLevel,
          voteStart,
          voteEnd,
          proposalMemberContracts
        );

      const receipt = await tx.wait();
      expect(receipt).to.emit(governance, "TransactionCreated").withArgs(0);
    });

    it("should register a transaction with custom threshold", async function () {
      const { founder, executiveMember, governance, letsExe } =
        await getGovernance();

      // Prepare transaction parameters
      const value = 0;
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 2; // LEVEL_3 (Custom)
      const numerator = 3;
      const denominator = 4;
      const voteStart = Math.floor(Date.now() / 1000);
      const voteEnd = voteStart + 3600;
      const proposalMemberContracts = [letsExe];

      // Register transaction with custom threshold
      const tx = await governance
        .connect(founder)
        .registerTransactionWithCustomThreshold(
          value,
          data,
          to,
          executor,
          proposalLevel,
          numerator,
          denominator,
          voteStart,
          voteEnd,
          proposalMemberContracts
        );

      const receipt = await tx.wait();
      expect(receipt).to.emit(governance, "TransactionCreated").withArgs(0);
    });

    it("should fail to register transaction with invalid proposal level", async function () {
      const { founder, executiveMember, governance, letsExe } =
        await getGovernance();

      // Prepare transaction parameters with invalid proposal level
      const value = 0;
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 2; // LEVEL_3
      const voteStart = Math.floor(Date.now() / 1000);
      const voteEnd = voteStart + 3600;
      const proposalMemberContracts = [letsExe];

      // Attempt to register transaction with standard threshold but LEVEL_3
      await expect(
        governance
          .connect(founder)
          .registerTransaction(
            value,
            data,
            to,
            executor,
            proposalLevel,
            voteStart,
            voteEnd,
            proposalMemberContracts
          )
      ).to.be.revertedWithCustomError(governance, "InvalidProposalLevel");
    });
  });

  describe("Transaction Approval", function () {
    it("should allow token holder to approve transaction", async function () {
      const { deployer, proxy, founder, executiveMember, governance, letsExe } =
        await getGovernance();

      // Register a transaction first
      const value = 0;
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 0; // LEVEL_1
      const voteStart = Math.floor(Date.now() / 1000);
      const voteEnd = voteStart + 3600;
      const proposalMemberContracts = [letsExe];

      await governance
        .connect(founder)
        .registerTransaction(
          value,
          data,
          to,
          executor,
          proposalLevel,
          voteStart,
          voteEnd,
          proposalMemberContracts
        );

      // grant minter role
      await grantMinterRole(deployer, proxy, founder);

      await tokenMintFromTokenMinter(
        (await ethers.getContractAt(
          "LETS_JP_LLC_EXE",
          letsExe
        )) as LETS_JP_LLC_EXE,
        founder,
        await executiveMember.getAddress()
      );

      // Approve transaction
      const tx = await governance
        .connect(executiveMember)
        .approveTransaction(1);
      const receipt = await tx.wait();

      expect(receipt)
        .to.emit(governance, "TransactionApproved")
        .withArgs(1, await executiveMember.getAddress());
    });

    it("should fail to approve transaction outside vote period", async function () {
      const { founder, executiveMember, governance, letsExe } =
        await getGovernance();

      // Register a transaction with past vote period
      const value = 0;
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 0;
      const voteStart = Math.floor(Date.now() / 1000) - 7200; // 2 hours ago
      const voteEnd = Math.floor(Date.now() / 1000) - 3600; // 1 hour ago
      const proposalMemberContracts = [letsExe];

      await governance
        .connect(founder)
        .registerTransaction(
          value,
          data,
          to,
          executor,
          proposalLevel,
          voteStart,
          voteEnd,
          proposalMemberContracts
        );

      // Attempt to approve expired transaction
      await expect(
        governance.connect(executiveMember).approveTransaction(0)
      ).to.be.revertedWithCustomError(governance, "NotInVotePeriod");
    });

    it("should fail to approve transaction twice", async function () {
      const { deployer, proxy, founder, executiveMember, governance, letsExe } =
        await getGovernance();

      // Register a transaction
      const value = 0;
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 0;
      const voteStart = Math.floor(Date.now() / 1000);
      const voteEnd = voteStart + 3600;
      const proposalMemberContracts = [letsExe];

      await governance
        .connect(founder)
        .registerTransaction(
          value,
          data,
          to,
          executor,
          proposalLevel,
          voteStart,
          voteEnd,
          proposalMemberContracts
        );

      // grant minter role
      await grantMinterRole(deployer, proxy, founder);

      await tokenMintFromTokenMinter(
        (await ethers.getContractAt(
          "LETS_JP_LLC_EXE",
          letsExe
        )) as LETS_JP_LLC_EXE,
        founder,
        await executiveMember.getAddress()
      );
      // First approval
      await governance.connect(executiveMember).approveTransaction(1);

      // Attempt second approval
      await expect(
        governance.connect(executiveMember).approveTransaction(1)
      ).to.be.revertedWithCustomError(governance, "AlreadyApproved");
    });
  });

  describe("Transaction Execution", function () {
    it("should execute transaction when threshold is reached", async function () {
      const {
        deployer,
        proxy,
        founder,
        executiveMember,
        governance,
        letsExe,
        letsNonExe,
      } = await getGovernance();

      // Register a transaction with LEVEL_2 (1/2 threshold)
      const value = 0;
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 1; // LEVEL_2
      const voteStart = Math.floor(Date.now() / 1000);
      const voteEnd = voteStart + 3600;
      const proposalMemberContracts = [letsExe, letsNonExe];

      await governance
        .connect(founder)
        .registerTransaction(
          value,
          data,
          to,
          executor,
          proposalLevel,
          voteStart,
          voteEnd,
          proposalMemberContracts
        );

      // grant minter role
      await grantMinterRole(deployer, proxy, founder);

      await tokenMintFromTokenMinter(
        (await ethers.getContractAt(
          "LETS_JP_LLC_EXE",
          letsExe
        )) as LETS_JP_LLC_EXE,
        founder,
        await executiveMember.getAddress()
      );

      // Get approval from one member (enough for 1/2 threshold)
      await governance.connect(executiveMember).approveTransaction(1);

      // Execute transaction
      const tx = await governance.connect(founder).execute(1);
      const receipt = await tx.wait();

      expect(receipt).to.emit(governance, "TransactionExecuted").withArgs(1);
      const transaction = await governance.getTransaction(1);
      expect(transaction.executed).to.equal(true);
    });

    it("should fail to execute transaction when threshold is not reached", async function () {
      const {
        deployer,
        proxy,
        founder,
        executiveMember,
        governance,
        letsExe,
        letsNonExe,
      } = await getGovernance();

      // Register a transaction with LEVEL_1 (2/3 threshold)
      const value = 0;
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 0; // LEVEL_1
      const voteStart = Math.floor(Date.now() / 1000);
      const voteEnd = voteStart + 3600;
      const proposalMemberContracts = [letsExe, letsNonExe];

      await governance
        .connect(founder)
        .registerTransaction(
          value,
          data,
          to,
          executor,
          proposalLevel,
          voteStart,
          voteEnd,
          proposalMemberContracts
        );

      // grant minter role
      await grantMinterRole(deployer, proxy, founder);

      await tokenMintFromTokenMinter(
        (await ethers.getContractAt(
          "LETS_JP_LLC_EXE",
          letsExe
        )) as LETS_JP_LLC_EXE,
        founder,
        await executiveMember.getAddress()
      );

      // Attempt to execute transaction
      await expect(
        governance.connect(founder).execute(1)
      ).to.be.revertedWithCustomError(governance, "ThresholdNotReached");
    });

    it("should fail to execute transaction by non-executor", async function () {
      const {
        deployer,
        proxy,
        founder,
        executiveMember,
        executiveMember2,
        governance,
        letsExe,
        letsNonExe,
      } = await getGovernance();

      // Register a transaction
      const value = 0;
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 1; // LEVEL_2
      const voteStart = Math.floor(Date.now() / 1000);
      const voteEnd = voteStart + 3600;
      const proposalMemberContracts = [letsExe, letsNonExe];

      await governance
        .connect(founder)
        .registerTransaction(
          value,
          data,
          to,
          executor,
          proposalLevel,
          voteStart,
          voteEnd,
          proposalMemberContracts
        );

      // grant minter role
      await grantMinterRole(deployer, proxy, founder);

      await tokenMintFromTokenMinter(
        (await ethers.getContractAt(
          "LETS_JP_LLC_EXE",
          letsExe
        )) as LETS_JP_LLC_EXE,
        founder,
        await executiveMember.getAddress()
      );

      // Get approval from one member
      await governance.connect(executiveMember).approveTransaction(1);

      // Attempt to execute transaction by non-executor
      await expect(
        governance.connect(executiveMember2).execute(1)
      ).to.be.revertedWithCustomError(governance, "NotExecutor");
    });
  });

  describe("Transaction Cancellation", function () {
    it("should allow cancellation of transaction", async function () {
      const { founder, executiveMember, governance, letsExe } =
        await getGovernance();

      // Register a transaction
      const value = 0;
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 0;
      const voteStart = Math.floor(Date.now() / 1000);
      const voteEnd = voteStart + 3600;
      const proposalMemberContracts = [letsExe];

      await governance
        .connect(founder)
        .registerTransaction(
          value,
          data,
          to,
          executor,
          proposalLevel,
          voteStart,
          voteEnd,
          proposalMemberContracts
        );

      // Cancel transaction
      const tx = await governance.connect(founder).cancelTransaction(0);
      const receipt = await tx.wait();

      expect(receipt).to.emit(governance, "TransactionCancelled").withArgs(0);
    });
  });
});
