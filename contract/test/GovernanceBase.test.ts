import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import type {
  GovernanceBase,
  LETS_JP_LLC_EXE,
  LETS_JP_LLC_NON_EXE,
} from "../typechain-types";
import { deployJP_DAO_LLCFullFixture } from "./utils/DeployFixture";
import { createCompany } from "./utils/CreateCompany";
import { tokenMintFromTokenMinter } from "./utils/LETSHelpers";
import { grantMinterRole } from "./utils/Role";

describe("GovernanceBase Service", function () {
  const getGovernanceBase = async () => {
    const {
      deployer,
      founder,
      executiveMember,
      executiveMember2,
      borderlessProxy,
      governanceBaseBeacon,
      lets_jp_llc_exeBeacon,
      lets_jp_llc_non_exeBeacon,
      aoiBeacon,
    } = await loadFixture(deployJP_DAO_LLCFullFixture);
    const { companyAddress, services } = await createCompany();
    const { companyAddress: companyAddressGovernanceBase, services: servicesGovernanceBase } = await createCompany([
      await governanceBaseBeacon.getAddress(),
      await lets_jp_llc_exeBeacon.getAddress(),
      await lets_jp_llc_non_exeBeacon.getAddress(),
      await aoiBeacon.getAddress(),
    ]);

    // Get GovernanceBase contract instance
    const governance_jp_llc = (await ethers.getContractAt(
      "Governance_JP_LLC",
      companyAddress
    )) as GovernanceBase;
    const letsExe = services[2] as unknown as LETS_JP_LLC_EXE;
    const letsNonExe = services[4] as unknown as LETS_JP_LLC_NON_EXE;
    const governanceBase = (await ethers.getContractAt(
      "GovernanceBase",
      companyAddressGovernanceBase
    )) as GovernanceBase;
    const letsExe2 = servicesGovernanceBase[2] as unknown as LETS_JP_LLC_EXE;
    const letsNonExe2 = servicesGovernanceBase[4] as unknown as LETS_JP_LLC_NON_EXE;
    return {
      deployer,
      borderlessProxy,
      founder,
      executiveMember,
      executiveMember2,
      governance_jp_llc,
      letsExe,
      letsNonExe,
      governanceBase,
      letsExe2,
      letsNonExe2,
    };
  };

  describe("Transaction Registration", function () {
    it("should register a transaction with standard threshold (LEVEL_1)", async function () {
      const { founder, executiveMember, governance_jp_llc, letsExe } =
        await getGovernanceBase();

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
      const tx = await governance_jp_llc
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
      expect(receipt).to.emit(governance_jp_llc, "TransactionCreated").withArgs(0);
    });

    it("should register a transaction with custom threshold", async function () {
      const { founder, executiveMember, governance_jp_llc, letsExe } =
        await getGovernanceBase();

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
      const tx = await governance_jp_llc
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
      expect(receipt).to.emit(governance_jp_llc, "TransactionCreated").withArgs(0);
    });

    it("should fail to register transaction with invalid proposal level", async function () {
      const { founder, executiveMember, governance_jp_llc, letsExe } =
        await getGovernanceBase();

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
        governance_jp_llc
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
      ).to.be.revertedWithCustomError(governance_jp_llc, "InvalidProposalLevel");
    });

    it("should fail to register transaction with invalid custom threshold", async function () {
      const { founder, executiveMember, governance_jp_llc, letsExe } =
        await getGovernanceBase();

      // Prepare transaction parameters with invalid custom threshold
      const value = 0;
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 2; // LEVEL_3
      const numerator = 0; // Invalid numerator
      const denominator = 4;
      const voteStart = Math.floor(Date.now() / 1000);
      const voteEnd = voteStart + 3600;
      const proposalMemberContracts = [letsExe];

      // Attempt to register transaction with invalid custom threshold
      await expect(
        governance_jp_llc
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
          )
      ).to.be.revertedWithCustomError(
        governance_jp_llc,
        "InvalidNumeratorOrDenominator"
      );
    });
  });

  describe("Transaction Approval", function () {
    it("should allow token holder to approve transaction", async function () {
      const {
        deployer,
        borderlessProxy,
        founder,
        executiveMember,
        governance_jp_llc,
        letsExe,
      } = await getGovernanceBase();

      // Register a transaction first
      const value = 0;
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 0; // LEVEL_1
      const voteStart = Math.floor(Date.now() / 1000);
      const voteEnd = voteStart + 3600;
      const proposalMemberContracts = [letsExe];

      await governance_jp_llc
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
      await grantMinterRole(deployer, borderlessProxy, founder);

      await tokenMintFromTokenMinter(
        (await ethers.getContractAt(
          "LETS_JP_LLC_EXE",
          letsExe
        )) as LETS_JP_LLC_EXE,
        founder,
        await executiveMember.getAddress()
      );

      // Approve transaction
      const tx = await governance_jp_llc
        .connect(executiveMember)
        .approveTransaction(1);
      const receipt = await tx.wait();

      expect(receipt)
        .to.emit(governance_jp_llc, "TransactionApproved")
        .withArgs(0, await executiveMember.getAddress());
    });

    it("should fail to approve transaction outside vote period", async function () {
      const { founder, executiveMember, governance_jp_llc, letsExe } =
        await getGovernanceBase();

      // Register a transaction with past vote period
      const value = 0;
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 0;
      const voteStart = Math.floor(Date.now() / 1000) - 7200; // 2 hours ago
      const voteEnd = Math.floor(Date.now() / 1000) - 3600; // 1 hour ago
      const proposalMemberContracts = [letsExe];

      await governance_jp_llc
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
        governance_jp_llc.connect(executiveMember).approveTransaction(1)
      ).to.be.revertedWithCustomError(governance_jp_llc, "NotInVotePeriod");
    });

    it("should fail to approve transaction twice", async function () {
      const {
        deployer,
        borderlessProxy,
        founder,
        executiveMember,
        governance_jp_llc,
        letsExe,
      } = await getGovernanceBase();

      // Register a transaction
      const value = 0;
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 0;
      const voteStart = Math.floor(Date.now() / 1000);
      const voteEnd = voteStart + 3600;
      const proposalMemberContracts = [letsExe];

      await governance_jp_llc
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
      await grantMinterRole(deployer, borderlessProxy, founder);

      await tokenMintFromTokenMinter(
        (await ethers.getContractAt(
          "LETS_JP_LLC_EXE",
          letsExe
        )) as LETS_JP_LLC_EXE,
        founder,
        await executiveMember.getAddress()
      );

      // First approval
      await governance_jp_llc.connect(executiveMember).approveTransaction(1);

      // Attempt second approval
      await expect(
        governance_jp_llc.connect(executiveMember).approveTransaction(1)
      ).to.be.revertedWithCustomError(governance_jp_llc, "AlreadyApproved");
    });

    it("should fail to approve transaction without token", async function () {
      const { founder, executiveMember2, governance_jp_llc, letsExe } =
        await getGovernanceBase();

      // Register a transaction
      const value = 0;
      const data = "0x";
      const to = await executiveMember2.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 0;
      const voteStart = Math.floor(Date.now() / 1000);
      const voteEnd = voteStart + 3600;
      const proposalMemberContracts = [letsExe];

      await governance_jp_llc
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

      // Attempt to approve without token
      await expect(
        governance_jp_llc.connect(executiveMember2).approveTransaction(1)
      ).to.be.revertedWithCustomError(governance_jp_llc, "NotTokenHolder");
    });
  });

  describe("Transaction Execution", function () {
    it("should execute transaction when threshold is reached", async function () {
      const {
        deployer,
        borderlessProxy,
        founder,
        executiveMember,
        letsExe2,
        letsNonExe2,
        governanceBase,
      } = await getGovernanceBase();

      // Register a transaction with LEVEL_2 (1/2 threshold)
      const value = 0;
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 1; // LEVEL_2
      const voteStart = Math.floor(Date.now() / 1000);
      const voteEnd = voteStart + 3600;
      const proposalMemberContracts = [letsExe2, letsNonExe2];

      await governanceBase
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
      await grantMinterRole(deployer, borderlessProxy, founder);

      await tokenMintFromTokenMinter(
        (await ethers.getContractAt(
          "LETS_JP_LLC_EXE",
          letsExe2
        )) as LETS_JP_LLC_EXE,
        founder,
        await executiveMember.getAddress()
      );

      // Get approval from one member (enough for 1/2 threshold)
      await governanceBase.connect(executiveMember).approveTransaction(1);

      // Execute transaction
      const tx = await governanceBase.connect(founder).execute(1);
      const receipt = await tx.wait();

      expect(receipt)
        .to.emit(governanceBase, "TransactionExecuted")
        .withArgs(0);
      const transaction = await governanceBase.getTransaction(1);
      expect(transaction.executed).to.equal(true);
    });

    it("should fail to execute transaction when threshold is not reached", async function () {
      const {
        deployer,
        borderlessProxy,
        founder,
        executiveMember,
        governanceBase,
        letsExe2,
        letsNonExe2,
      } = await getGovernanceBase();

      // Register a transaction with LEVEL_1 (2/3 threshold)
      const value = 0;
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 0; // LEVEL_1
      const voteStart = Math.floor(Date.now() / 1000);
      const voteEnd = voteStart + 3600;
      const proposalMemberContracts = [letsExe2, letsNonExe2];

      // grant minter role
      await grantMinterRole(deployer, borderlessProxy, founder);

      await tokenMintFromTokenMinter(
        (await ethers.getContractAt(
          "LETS_JP_LLC_EXE",
          letsExe2
        )) as LETS_JP_LLC_EXE,
        founder,
        await executiveMember.getAddress()
      );

      await governanceBase
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

      // Attempt to execute transaction
      await expect(
        governanceBase.connect(founder).execute(1)
      ).to.be.revertedWithCustomError(governanceBase, "ThresholdNotReached");
    });

    it("should fail to execute transaction by non-executor", async function () {
      const {
        deployer,
        borderlessProxy,
        founder,
        executiveMember,
        executiveMember2,
        governance_jp_llc,
        letsExe,
        letsNonExe,
      } = await getGovernanceBase();

      // Register a transaction
      const value = 0;
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 1; // LEVEL_2
      const voteStart = Math.floor(Date.now() / 1000);
      const voteEnd = voteStart + 3600;
      const proposalMemberContracts = [letsExe, letsNonExe];

      await governance_jp_llc
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
      await grantMinterRole(deployer, borderlessProxy, founder);

      await tokenMintFromTokenMinter(
        (await ethers.getContractAt(
          "LETS_JP_LLC_EXE",
          letsExe
        )) as LETS_JP_LLC_EXE,
        founder,
        await executiveMember.getAddress()
      );

      // Get approval from one member
      await governance_jp_llc.connect(executiveMember).approveTransaction(1);

      // Attempt to execute transaction by non-executor
      await expect(
        governance_jp_llc.connect(executiveMember2).execute(0)
      ).to.be.revertedWithCustomError(governance_jp_llc, "NotExecutor");
    });
  });

  describe("Transaction Cancellation", function () {
    it("should allow cancellation of transaction", async function () {
      const { founder, executiveMember, governance_jp_llc, letsExe } =
        await getGovernanceBase();

      // Register a transaction
      const value = 0;
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 0;
      const voteStart = Math.floor(Date.now() / 1000);
      const voteEnd = voteStart + 3600;
      const proposalMemberContracts = [letsExe];

      await governance_jp_llc
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
      const tx = await governance_jp_llc.connect(founder).cancelTransaction(0);
      const receipt = await tx.wait();

      expect(receipt)
        .to.emit(governance_jp_llc, "TransactionCancelled")
        .withArgs(0);
    });
  });

  describe("Transaction Information", function () {
    it("should return correct transaction information", async function () {
      const { deployer, borderlessProxy, founder, executiveMember, governance_jp_llc, letsExe } =
        await getGovernanceBase();

      // Register a transaction
      const value = 0;
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 0;
      const voteStart = Math.floor(Date.now() / 1000);
      const voteEnd = voteStart + 3600;
      const proposalMemberContracts = [letsExe];

      // grant minter role
      await grantMinterRole(deployer, borderlessProxy, founder);

      await tokenMintFromTokenMinter(
        (await ethers.getContractAt(
          "LETS_JP_LLC_EXE",
          letsExe
        )) as LETS_JP_LLC_EXE,
        founder,
        await executiveMember.getAddress()
      );

      await governance_jp_llc
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

      // Get transaction information
      const transaction = await governance_jp_llc.getTransaction(1);

      // Verify transaction details
      expect(transaction.value).to.equal(value);
      expect(transaction.data).to.equal(data);
      expect(transaction.to).to.equal(to);
      expect(transaction.executor).to.equal(executor);
      expect(transaction.executed).to.equal(false);
      expect(transaction.cancelled).to.equal(false);
      expect(transaction.totalMember).to.equal(proposalMemberContracts.length);
      expect(transaction.approvalCount).to.equal(0);
      expect(transaction.voteStart).to.equal(voteStart);
      expect(transaction.voteEnd).to.equal(voteEnd);
      expect(transaction.proposalInfo.proposalLevel).to.equal(proposalLevel);
      expect(transaction.proposalInfo.numerator).to.equal(2); // LEVEL_1: 2/3
      expect(transaction.proposalInfo.denominator).to.equal(3);
    });
  });

  describe("Transaction Execution with Balance Checks", function () {
    it("should execute transaction and transfer funds when threshold is reached", async function () {
      const {
        deployer,
        borderlessProxy,
        founder,
        executiveMember,
        executiveMember2,
        governance_jp_llc,
        letsExe,
      } = await getGovernanceBase();

      // Get initial balances
      const initialFounderBalance = await ethers.provider.getBalance(
        await founder.getAddress()
      );
      const initialExecutiveBalance = await ethers.provider.getBalance(
        await executiveMember.getAddress()
      );

      // Register a transaction with ETH transfer
      const value = ethers.parseEther("1.0"); // 1 ETH
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 0; // LEVEL_1
      const voteStart = Math.floor(Date.now() / 1000);
      const voteEnd = voteStart + 3600;
      const proposalMemberContracts = [letsExe];

      // Fund the governance contract
      await founder.sendTransaction({
        to: await governance_jp_llc.getAddress(),
        value: value,
      });

      await governance_jp_llc
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

      // Grant minter role and mint tokens
      await grantMinterRole(deployer, borderlessProxy, founder);
      await tokenMintFromTokenMinter(
        (await ethers.getContractAt(
          "LETS_JP_LLC_EXE",
          letsExe
        )) as LETS_JP_LLC_EXE,
        founder,
        await executiveMember.getAddress()
      );
      await tokenMintFromTokenMinter(
        (await ethers.getContractAt(
          "LETS_JP_LLC_EXE",
          letsExe
        )) as LETS_JP_LLC_EXE,
        founder,
        await executiveMember2.getAddress()
      );

      // Approve transaction by two members
      await governance_jp_llc.connect(executiveMember).approveTransaction(1);
      await governance_jp_llc.connect(executiveMember2).approveTransaction(1);

      // Execute transaction
      const tx = await governance_jp_llc.connect(founder).execute(1);
      const receipt = await tx.wait();

      // Get final balances
      const finalFounderBalance = await ethers.provider.getBalance(
        await founder.getAddress()
      );
      const finalExecutiveBalance = await ethers.provider.getBalance(
        await executiveMember.getAddress()
      );

      // Verify balances
      expect(finalExecutiveBalance).to.be.greaterThan(initialExecutiveBalance);
      expect(finalFounderBalance).to.be.lessThan(initialFounderBalance); // Due to gas costs

      // Verify events
      expect(receipt)
        .to.emit(governance_jp_llc, "TransactionExecuted")
        .withArgs(0);
    });

    it("should fail to execute transaction when threshold is not reached (send ETH)", async function () {
      const {
        deployer,
        borderlessProxy,
        founder,
        executiveMember,
        governanceBase,
        letsExe,
      } = await getGovernanceBase();

      // Register a transaction with ETH transfer
      const value = ethers.parseEther("1.0");
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 0; // LEVEL_1
      const voteStart = Math.floor(Date.now() / 1000);
      const voteEnd = voteStart + 3600;
      const proposalMemberContracts = [letsExe];

      // Fund the governance contract
      await founder.sendTransaction({
        to: await governanceBase.getAddress(),
        value: value,
      });

      // Grant minter role and mint tokens
      await grantMinterRole(deployer, borderlessProxy, founder);
      await tokenMintFromTokenMinter(
        (await ethers.getContractAt(
          "LETS_JP_LLC_EXE",
          letsExe
        )) as LETS_JP_LLC_EXE,
        founder,
        await executiveMember.getAddress()
      );

      await governanceBase
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

      // Attempt to execute transaction
      await expect(
        governanceBase.connect(founder).execute(1)
      ).to.be.revertedWithCustomError(governanceBase, "ThresholdNotReached");

      // Verify balances haven't changed
      const finalExecutiveBalance = await ethers.provider.getBalance(
        await executiveMember.getAddress()
      );
      const governanceBalance = await ethers.provider.getBalance(
        await governanceBase.getAddress()
      );

      expect(governanceBalance).to.equal(value); // Contract still has the funds
    });

    it("should execute transaction with custom threshold and verify balances (send ETH)", async function () {
      const {
        deployer,
        borderlessProxy,
        founder,
        executiveMember,
        executiveMember2,
        governanceBase,
        letsExe,
      } = await getGovernanceBase();

      // Get initial balances
      const initialFounderBalance = await ethers.provider.getBalance(
        await founder.getAddress()
      );
      const initialExecutiveBalance = await ethers.provider.getBalance(
        await executiveMember.getAddress()
      );

      // Register a transaction with custom threshold (3/4)
      const value = ethers.parseEther("1.0");
      const data = "0x";
      const to = await executiveMember.getAddress();
      const executor = await founder.getAddress();
      const proposalLevel = 2; // LEVEL_3
      const numerator = 3;
      const denominator = 4;
      const voteStart = Math.floor(Date.now() / 1000);
      const voteEnd = voteStart + 3600;
      const proposalMemberContracts = [letsExe];

      // Fund the governance contract
      await founder.sendTransaction({
        to: await governanceBase.getAddress(),
        value: value,
      });

      await governanceBase
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

      // Grant minter role and mint tokens to all members
      await grantMinterRole(deployer, borderlessProxy, founder);
      await tokenMintFromTokenMinter(
        (await ethers.getContractAt(
          "LETS_JP_LLC_EXE",
          letsExe
        )) as LETS_JP_LLC_EXE,
        founder,
        await executiveMember.getAddress()
      );
      await tokenMintFromTokenMinter(
        (await ethers.getContractAt(
          "LETS_JP_LLC_EXE",
          letsExe
        )) as LETS_JP_LLC_EXE,
        founder,
        await executiveMember2.getAddress()
      );

      // Approve transaction by two members (meeting 3/4 threshold)
      await governanceBase.connect(executiveMember).approveTransaction(1);
      await governanceBase.connect(executiveMember2).approveTransaction(1);

      // Execute transaction
      const tx = await governanceBase.connect(founder).execute(1);
      const receipt = await tx.wait();

      // Get final balances
      const finalFounderBalance = await ethers.provider.getBalance(
        await founder.getAddress()
      );
      const finalExecutiveBalance = await ethers.provider.getBalance(
        await executiveMember.getAddress()
      );

      // Verify balances
      expect(finalExecutiveBalance).to.be.greaterThan(initialExecutiveBalance);
      expect(finalFounderBalance).to.be.lessThan(initialFounderBalance); // Due to gas costs

      // Verify events
      expect(receipt)
        .to.emit(governanceBase, "TransactionExecuted")
        .withArgs(0);
    });
  });
});
