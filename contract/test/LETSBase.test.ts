import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import type { LETSBase } from "../typechain-types";
import { deployJP_DAO_LLCFullFixture } from "./utils/DeployFixture";
import { createCompany } from "./utils/CreateCompany";
import { letsEncodeParams } from "../scripts/utils/Encode";
import { grantMinterRole } from "./utils/Role";

describe("LETSBase", function () {
  const getLETSBaseContext = async () => {
    const {
      deployer,
      founder,
      executiveMember,
      executiveMember2,
      tokenMinter,
      borderlessProxy,
    } = await loadFixture(deployJP_DAO_LLCFullFixture);

    // Create a company to get LETS contract
    const { services } = await createCompany();

    // Get LETS contract
    const lets = (await ethers.getContractAt(
      "LETSBase",
      services[2]
    )) as LETSBase;

    return {
      deployer,
      founder,
      executiveMember,
      executiveMember2,
      tokenMinter,
      borderlessProxy,
      lets,
    };
  };

  describe("Initialize", function () {
    it("should initialize with correct parameters", async function () {
      const { lets } = await getLETSBaseContext();

      // Check initialization parameters
      expect(await lets.getIsMetadataFixed()).to.be.true;
      expect(await lets.getMaxSupply()).to.equal(2000);
      expect(await lets.getBaseURI()).to.equal("https://example.com/metadata/");
      expect(await lets.getExtension()).to.equal(".json");
    });
  });

  describe("Mint", function () {
    it("should mint token when called by MINTER_ROLE", async function () {
      const { deployer, borderlessProxy, lets, tokenMinter, executiveMember } = await getLETSBaseContext();

      await grantMinterRole(deployer, borderlessProxy, tokenMinter);

      // Mint token
      await lets.connect(tokenMinter).mint(executiveMember.address);

      // Check token ownership
      expect(await lets.ownerOf(1)).to.equal(executiveMember.address);
      expect(await lets.balanceOf(executiveMember.address)).to.equal(1);
    });

    it("should revert when called by non-MINTER_ROLE", async function () {
      const { lets, executiveMember, executiveMember2 } = await getLETSBaseContext();

      // Try to mint without MINTER_ROLE
      await expect(
        lets.connect(executiveMember).mint(executiveMember2.address)
      ).to.be.revertedWithCustomError(lets, "AccessControlUnauthorizedAccount");
    });

    it("should revert when max supply is reached", async function () {
      const { deployer, borderlessProxy, lets, tokenMinter, executiveMember } = await getLETSBaseContext();

      await grantMinterRole(deployer, borderlessProxy, tokenMinter);

      // Mint tokens up to max supply
      for (let i = 0; i < 2001; i++) {
        await lets.connect(tokenMinter).mint(executiveMember.address);
      }

      // Try to mint one more token
      await expect(
        lets.connect(tokenMinter).mint(executiveMember.address)
      ).to.be.revertedWithCustomError(lets, "MaxSupplyReached");
    });
  });

  describe("Freeze/Unfreeze Token", function () {
    it("should freeze and unfreeze token", async function () {
      const { deployer, borderlessProxy, lets, tokenMinter, executiveMember } = await getLETSBaseContext();

      await grantMinterRole(deployer, borderlessProxy, tokenMinter);

      // Mint a token
      await lets.connect(tokenMinter).mint(executiveMember.address);
      const tokenId = 1;

      // Freeze token
      await lets.freezeToken(tokenId);
      expect(await lets.getFreezeToken(tokenId)).to.be.true;

      // Unfreeze token
      await lets.unfreezeToken(tokenId);
      expect(await lets.getFreezeToken(tokenId)).to.be.false;
    });
  });

  describe("View Functions", function () {
    it("should return correct values for view functions", async function () {
      const { lets, founder } = await getLETSBaseContext();

      // Check SC address
      expect(await lets.getSC()).to.not.equal(ethers.ZeroAddress);

      // Check metadata settings
      expect(await lets.getIsMetadataFixed()).to.be.true;
      expect(await lets.getBaseURI()).to.equal("https://example.com/metadata/");
      expect(await lets.getExtension()).to.equal(".json");

      // Check supply settings
      expect(await lets.getMaxSupply()).to.equal(2000);
      expect(await lets.getNextTokenId()).to.equal(0); // Before minting
    });

    it("should return correct token URI", async function () {
      const { deployer, borderlessProxy, lets, tokenMinter, executiveMember } = await getLETSBaseContext();

      await grantMinterRole(deployer, borderlessProxy, tokenMinter);

      // Mint a token
      await lets.connect(tokenMinter).mint(executiveMember.address);
      const tokenId = 1;

      // Check token URI
      expect(await lets.tokenURI(tokenId)).to.equal(
        "https://example.com/metadata/.json"
      );
    });
  });
}); 