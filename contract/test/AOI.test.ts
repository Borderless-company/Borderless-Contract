import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { keccak256, toBytes } from "viem";
import { createCompany } from "./utils/CreateCompany";
import { deployJP_DAO_LLCFullFixture } from "./utils/DeployFixture";
import { grantMinterRole } from "./utils/Role";

describe("AOI", function () {
  const getAOIContext = async () => {
    const { deployer, founder, executiveMember, tokenMinter, borderlessProxy } =
      await loadFixture(deployJP_DAO_LLCFullFixture);

    // Create company with AOI service
    const { companyAddress, services } = await createCompany();
    const aoi = await ethers.getContractAt("AOI", companyAddress);
    const letsExe = await ethers.getContractAt("LETSBase", services[2]);

    return {
      deployer,
      founder,
      user: executiveMember,
      tokenMinter,
      borderlessProxy,
      companyAddress,
      aoi,
      letsExe,
    };
  };

  describe("updateChapter", function () {
    it("should update chapter when called by founder", async function () {
      const { founder, aoi } = await getAOIContext();

      const items = [
        {
          location: {
            articleId: 1,
            paragraphId: 1,
            itemId: 1,
          },
          encryptedData: "0x1234",
          plaintextHash: ethers.keccak256(ethers.toUtf8Bytes("test")),
          masterSaltHash: ethers.keccak256(ethers.toUtf8Bytes("salt")),
        },
      ];

      const versionRoot = ethers.keccak256(ethers.toUtf8Bytes("version1"));
      const signers = [founder.address];
      const versionRootHash = keccak256(toBytes(versionRoot));
      const signatures = await Promise.all(
        signers.map(async (signer) => {
          return await founder.signMessage(ethers.getBytes(versionRootHash));
        })
      );

      // Generate meta signature
      const metaHash = keccak256(
        toBytes(
          JSON.stringify({
            versionRoot,
            signers,
            signatures,
          })
        )
      );
      const finalSignature = await founder.signMessage(
        ethers.getBytes(metaHash)
      );

      await expect(
        aoi
          .connect(founder)
          .updateChapter(
            versionRoot,
            signers,
            signatures,
            finalSignature,
            items
          )
      ).to.emit(aoi, "ChapterUpdated");
      // .withArgs(BigInt(versionRoot), versionRoot, await founder.getAddress(), signers, [
      //   items[0].location,
      // ]);

      // Verify item was set
      const item = await aoi.getEncryptedItem(items[0].location);
      expect(item.encryptedData).to.equal(items[0].encryptedData);
      expect(item.plaintextHash).to.equal(items[0].plaintextHash);
      expect(item.masterSaltHash).to.equal(items[0].masterSaltHash);

      //   // Verify version was set
      expect(await aoi.getVersionRoot(BigInt(versionRoot))).to.equal(
        versionRoot
      );
    });

    it("should revert when called by non-founder", async function () {
      const { user, aoi } = await getAOIContext();

      const items = [
        {
          location: {
            articleId: 1,
            paragraphId: 1,
            itemId: 1,
          },
          encryptedData: "0x1234",
          plaintextHash: ethers.keccak256(ethers.toUtf8Bytes("test")),
          masterSaltHash: ethers.keccak256(ethers.toUtf8Bytes("salt")),
        },
      ];

      const versionRoot = ethers.keccak256(ethers.toUtf8Bytes("version1"));
      const signers = [user.address];
      const versionRootHash = keccak256(toBytes(versionRoot));
      const signatures = await Promise.all(
        signers.map(async (signer) => {
          return await user.signMessage(ethers.getBytes(versionRootHash));
        })
      );

      // Generate meta signature
      const metaHash = keccak256(
        toBytes(
          JSON.stringify({
            versionRoot,
            signers,
            signatures,
          })
        )
      );
      const finalSignature = await user.signMessage(ethers.getBytes(metaHash));

      await expect(
        aoi
          .connect(user)
          .updateChapter(
            versionRoot,
            signers,
            signatures,
            finalSignature,
            items
          )
      ).to.be.revertedWithCustomError(aoi, "AccessControlUnauthorizedAccount");
    });

    it("should revert with invalid signature", async function () {
      const { founder, user, aoi } = await getAOIContext();

      const items = [
        {
          location: {
            articleId: 1,
            paragraphId: 1,
            itemId: 1,
          },
          encryptedData: "0x1234",
          plaintextHash: ethers.keccak256(ethers.toUtf8Bytes("test")),
          masterSaltHash: ethers.keccak256(ethers.toUtf8Bytes("salt")),
        },
      ];

      const versionRoot = ethers.keccak256(ethers.toUtf8Bytes("version1"));
      const signers = [founder.address];
      const versionRootHash = keccak256(toBytes(versionRoot));
      const signatures = await Promise.all(
        signers.map(async (signer) => {
          return await user.signMessage(ethers.getBytes(versionRootHash));
        })
      );

      // Generate meta signature
      const metaHash = keccak256(
        toBytes(
          JSON.stringify({
            versionRoot,
            signers,
            signatures,
          })
        )
      );
      const finalSignature = await user.signMessage(ethers.getBytes(metaHash));

      await expect(
        aoi
          .connect(founder)
          .updateChapter(
            versionRoot,
            signers,
            signatures,
            finalSignature,
            items
          )
      ).to.be.revertedWithCustomError(aoi, "InvalidSignature");
    });
  });

  describe("setEphemeralSalt", function () {
    it("should set ephemeral salt when called by founder", async function () {
      const { founder, aoi } = await getAOIContext();
      const salt = ethers.keccak256(ethers.toUtf8Bytes("test-salt"));

      await expect(aoi.connect(founder).setEphemeralSalt(salt))
        .to.emit(aoi, "EphemeralSaltMarkedUsed")
        .withArgs(salt);

      expect(await aoi.isEphemeralSaltUsed(salt)).to.be.true;
    });

    it("should revert when called by non-admin", async function () {
      const { user, aoi } = await getAOIContext();
      const salt = ethers.keccak256(ethers.toUtf8Bytes("test-salt"));

      await expect(
        aoi.connect(user).setEphemeralSalt(salt)
      ).to.be.revertedWithCustomError(aoi, "AccessControlUnauthorizedAccount");
    });

    it("should revert when salt is already used", async function () {
      const { founder, aoi } = await getAOIContext();
      const salt = ethers.keccak256(ethers.toUtf8Bytes("test-salt"));

      await aoi.connect(founder).setEphemeralSalt(salt);

      await expect(
        aoi.connect(founder).setEphemeralSalt(salt)
      ).to.be.revertedWithCustomError(aoi, "EphemeralSaltAlreadyUsed");
    });
  });

  describe("getEncryptedItem", function () {
    it("should return correct encrypted item", async function () {
      const { founder, aoi } = await getAOIContext();

      const items = [
        {
          location: {
            articleId: 1,
            paragraphId: 1,
            itemId: 1,
          },
          encryptedData: "0x1234",
          plaintextHash: ethers.keccak256(ethers.toUtf8Bytes("test")),
          masterSaltHash: ethers.keccak256(ethers.toUtf8Bytes("salt")),
        },
      ];

      const versionRoot = ethers.keccak256(ethers.toUtf8Bytes("version1"));
      const signers = [founder.address];
      const versionRootHash = keccak256(toBytes(versionRoot));
      const signatures = await Promise.all(
        signers.map(async (signer) => {
          return await founder.signMessage(ethers.getBytes(versionRootHash));
        })
      );

      // Generate meta signature
      const metaHash = keccak256(
        toBytes(
          JSON.stringify({
            versionRoot,
            signers,
            signatures,
          })
        )
      );
      const finalSignature = await founder.signMessage(
        ethers.getBytes(metaHash)
      );

      await aoi
        .connect(founder)
        .updateChapter(versionRoot, signers, signatures, finalSignature, items);

      const item = await aoi.getEncryptedItem(items[0].location);
      expect(item.encryptedData).to.equal(items[0].encryptedData);
      expect(item.plaintextHash).to.equal(items[0].plaintextHash);
      expect(item.masterSaltHash).to.equal(items[0].masterSaltHash);
    });
  });

  describe("verifyDecryptionKeyHash", function () {
    it("should return true for correct hash", async function () {
      const { founder, aoi } = await getAOIContext();

      const items = [
        {
          location: {
            articleId: 1,
            paragraphId: 1,
            itemId: 1,
          },
          encryptedData: "0x1234",
          plaintextHash: ethers.keccak256(ethers.toUtf8Bytes("test")),
          masterSaltHash: ethers.keccak256(ethers.toUtf8Bytes("salt")),
        },
      ];

      const versionRoot = ethers.keccak256(ethers.toUtf8Bytes("version1"));
      const signers = [founder.address];
      const versionRootHash = keccak256(toBytes(versionRoot));
      const signatures = await Promise.all(
        signers.map(async (signer) => {
          return await founder.signMessage(ethers.getBytes(versionRootHash));
        })
      );

      // Generate meta signature
      const metaHash = keccak256(
        toBytes(
          JSON.stringify({
            versionRoot,
            signers,
            signatures,
          })
        )
      );
      const finalSignature = await founder.signMessage(
        ethers.getBytes(metaHash)
      );

      await aoi
        .connect(founder)
        .updateChapter(versionRoot, signers, signatures, finalSignature, items);

      const result = await aoi.verifyDecryptionKeyHash(
        items[0].location,
        items[0].plaintextHash
      );
      expect(result).to.be.true;
    });

    it("should return false for incorrect hash", async function () {
      const { founder, aoi } = await getAOIContext();

      const items = [
        {
          location: {
            articleId: 1,
            paragraphId: 1,
            itemId: 1,
          },
          encryptedData: "0x1234",
          plaintextHash: ethers.keccak256(ethers.toUtf8Bytes("test")),
          masterSaltHash: ethers.keccak256(ethers.toUtf8Bytes("salt")),
        },
      ];

      const versionRoot = ethers.keccak256(ethers.toUtf8Bytes("version1"));
      const signers = [founder.address];
      const versionRootHash = keccak256(toBytes(versionRoot));
      const signatures = await Promise.all(
        signers.map(async (signer) => {
          return await founder.signMessage(ethers.getBytes(versionRootHash));
        })
      );

      // メタ署名の生成
      const metaHash = keccak256(
        toBytes(
          JSON.stringify({
            versionRoot,
            signers,
            signatures,
          })
        )
      );
      const finalSignature = await founder.signMessage(
        ethers.getBytes(metaHash)
      );

      await aoi
        .connect(founder)
        .updateChapter(versionRoot, signers, signatures, finalSignature, items);

      const result = await aoi.verifyDecryptionKeyHash(
        items[0].location,
        ethers.keccak256(ethers.toUtf8Bytes("wrong"))
      );
      expect(result).to.be.false;
    });
  });

  describe("verifyDecryptionKeyHashWithSaltHash", function () {
    it("should return true for valid verification", async function () {
      const {
        deployer,
        founder,
        user,
        aoi,
        letsExe,
        borderlessProxy,
        tokenMinter,
      } = await getAOIContext();

      const items = [
        {
          location: {
            articleId: 1,
            paragraphId: 1,
            itemId: 1,
          },
          encryptedData: "0x1234",
          plaintextHash: ethers.keccak256(ethers.toUtf8Bytes("test")),
          masterSaltHash: ethers.keccak256(ethers.toUtf8Bytes("salt")),
        },
      ];

      const versionRoot = ethers.keccak256(ethers.toUtf8Bytes("version1"));
      const signers = [founder.address];
      const versionRootHash = keccak256(toBytes(versionRoot));
      const signatures = await Promise.all(
        signers.map(async (signer) => {
          return await founder.signMessage(ethers.getBytes(versionRootHash));
        })
      );

      // Generate meta signature
      const metaHash = keccak256(
        toBytes(
          JSON.stringify({
            versionRoot,
            signers,
            signatures,
          })
        )
      );
      const finalSignature = await founder.signMessage(
        ethers.getBytes(metaHash)
      );

      await aoi
        .connect(founder)
        .updateChapter(versionRoot, signers, signatures, finalSignature, items);

      const ephemeralSalt = ethers.keccak256(ethers.toUtf8Bytes("ephemeral"));
      const masterSaltHash = items[0].masterSaltHash;

      // set minter role
      await grantMinterRole(deployer, borderlessProxy, tokenMinter);
      await letsExe.connect(tokenMinter).mint(user.address);

      const result = await aoi.verifyDecryptionKeyHashWithSaltHash(
        items[0].location,
        ephemeralSalt,
        masterSaltHash,
        user.address
      );
      expect(result).to.be.true;
    });

    it("should return false when ephemeral salt is used", async function () {
      const { founder, user, aoi } = await getAOIContext();

      const items = [
        {
          location: {
            articleId: 1,
            paragraphId: 1,
            itemId: 1,
          },
          encryptedData: "0x1234",
          plaintextHash: ethers.keccak256(ethers.toUtf8Bytes("test")),
          masterSaltHash: ethers.keccak256(ethers.toUtf8Bytes("salt")),
        },
      ];

      const versionRoot = ethers.keccak256(ethers.toUtf8Bytes("version1"));
      const signers = [founder.address];
      const versionRootHash = keccak256(toBytes(versionRoot));
      const signatures = await Promise.all(
        signers.map(async (signer) => {
          return await founder.signMessage(ethers.getBytes(versionRootHash));
        })
      );

      // Generate meta signature
      const metaHash = keccak256(
        toBytes(
          JSON.stringify({
            versionRoot,
            signers,
            signatures,
          })
        )
      );
      const finalSignature = await founder.signMessage(
        ethers.getBytes(metaHash)
      );

      await aoi
        .connect(founder)
        .updateChapter(versionRoot, signers, signatures, finalSignature, items);

      const ephemeralSalt = ethers.keccak256(ethers.toUtf8Bytes("ephemeral"));
      await aoi.connect(founder).setEphemeralSalt(ephemeralSalt);

      const masterSaltHash = items[0].masterSaltHash;

      const result = await aoi.verifyDecryptionKeyHashWithSaltHash(
        items[0].location,
        ephemeralSalt,
        masterSaltHash,
        user.address
      );
      expect(result).to.be.false;
    });

    it("should return false when master salt hash is incorrect", async function () {
      const { founder, user, aoi } = await getAOIContext();

      const items = [
        {
          location: {
            articleId: 1,
            paragraphId: 1,
            itemId: 1,
          },
          encryptedData: "0x1234",
          plaintextHash: ethers.keccak256(ethers.toUtf8Bytes("test")),
          masterSaltHash: ethers.keccak256(ethers.toUtf8Bytes("salt")),
        },
      ];

      const versionRoot = ethers.keccak256(ethers.toUtf8Bytes("version1"));
      const signers = [founder.address];
      const versionRootHash = keccak256(toBytes(versionRoot));
      const signatures = await Promise.all(
        signers.map(async (signer) => {
          return await founder.signMessage(ethers.getBytes(versionRootHash));
        })
      );

      // Generate meta signature
      const metaHash = keccak256(
        toBytes(
          JSON.stringify({
            versionRoot,
            signers,
            signatures,
          })
        )
      );
      const finalSignature = await founder.signMessage(
        ethers.getBytes(metaHash)
      );

      await aoi
        .connect(founder)
        .updateChapter(versionRoot, signers, signatures, finalSignature, items);

      const ephemeralSalt = ethers.keccak256(ethers.toUtf8Bytes("ephemeral"));
      const wrongMasterSaltHash = ethers.keccak256(
        ethers.toUtf8Bytes("wrong-salt")
      );

      const result = await aoi.verifyDecryptionKeyHashWithSaltHash(
        items[0].location,
        ephemeralSalt,
        wrongMasterSaltHash,
        user.address
      );
      expect(result).to.be.false;
    });
  });
});
