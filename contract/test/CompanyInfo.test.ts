import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import type { CompanyInfo, BorderlessAccessControl } from "../typechain-types";
import { deployJP_DAO_LLCFullFixture } from "./utils/DeployFixture";
import { createCompany } from "./utils/CreateCompany";

describe("CompanyInfo", function () {
  const getCompanyInfoContext = async () => {
    const { deployer, founder, borderlessProxy } = await loadFixture(
      deployJP_DAO_LLCFullFixture
    );

    // Get CompanyInfo contract instance from borderlessProxy
    const companyInfo = (await ethers.getContractAt(
      "CompanyInfo",
      await borderlessProxy.getAddress()
    )) as CompanyInfo;

    // Get BorderlessAccessControl instance from borderlessProxy
    const accessControl = (await ethers.getContractAt(
      "BorderlessAccessControl",
      await borderlessProxy.getAddress()
    )) as BorderlessAccessControl;

    // Grant DEFAULT_ADMIN_ROLE to deployer
    const DEFAULT_ADMIN_ROLE =
      "0x0000000000000000000000000000000000000000000000000000000000000000";

    // Grant roles (only deployer has permission to grant roles in BorderlessProxy)
    await accessControl
      .connect(deployer)
      .grantRole(DEFAULT_ADMIN_ROLE, deployer.address);

    // Add initial company info fields
    await companyInfo
      .connect(deployer)
      .addCompanyInfoFields("JP_LLC", "postalCode");
    await companyInfo.connect(deployer).addCompanyInfoFields("JP_LLC", "city");
    await companyInfo
      .connect(deployer)
      .addCompanyInfoFields("JP_LLC", "address");

    return {
      deployer,
      founder,
      companyInfo,
      accessControl,
      borderlessProxy,
    };
  };

  const getFounderContext = async () => {
    const { deployer, founder, borderlessProxy } = await loadFixture(
      deployJP_DAO_LLCFullFixture
    );
    const { companyAddress } = await createCompany();

    // Get CompanyInfo contract instance from borderlessProxy
    const companyInfo = (await ethers.getContractAt(
      "CompanyInfo",
      await borderlessProxy.getAddress()
    )) as CompanyInfo;

    return {
      deployer,
      founder,
      companyInfo,
      companyAddress,
      borderlessProxy,
    };
  };

  describe("setCompanyInfo", function () {
    it("should allow founder to set company info", async function () {
      const { founder, companyInfo } = await getFounderContext();
      const scid = "1234567890"; // Use the same scid as in createCompany
      const field = "postalCode";
      const value = "100-0001";

      await expect(
        companyInfo.connect(founder).setCompanyInfo(scid, field, value)
      )
        .to.emit(companyInfo, "UpdateCompanyInfo")
        .withArgs(await founder.getAddress(), scid, field, value);

      const result = await companyInfo.getCompanyField(scid, field);
      expect(result).to.equal(value);
    });

    it("should fail when non-founder tries to set company info", async function () {
      const { deployer, companyInfo } = await getFounderContext();
      const scid = "1234567890"; // Use the same scid as in createCompany
      const field = "postalCode";
      const value = "100-0001";

      await expect(
        companyInfo.connect(deployer).setCompanyInfo(scid, field, value)
      ).to.be.revertedWithCustomError(companyInfo, "InvalidFounder");
    });
  });

  describe("addCompanyInfoFields", function () {
    it("should allow admin to add company info fields", async function () {
      const { deployer, companyInfo } = await getCompanyInfoContext();
      const legalEntityCode = "JP_LLC";
      const field = "newField";

      await expect(
        companyInfo
          .connect(deployer)
          .addCompanyInfoFields(legalEntityCode, field)
      )
        .to.emit(companyInfo, "AddCompanyInfoField")
        .withArgs(await deployer.getAddress(), legalEntityCode, field);

      const fields = await companyInfo.getCompanyInfoFields(legalEntityCode);
      expect(fields).to.include(field);
    });

    it("should fail when non-admin tries to add company info fields", async function () {
      const { founder, companyInfo } = await getCompanyInfoContext();
      const legalEntityCode = "JP_LLC";
      const field = "newField";

      await expect(
        companyInfo
          .connect(founder)
          .addCompanyInfoFields(legalEntityCode, field)
      ).to.be.revertedWithCustomError(
        companyInfo,
        "AccessControlUnauthorizedAccount"
      );
    });
  });

  describe("updateCompanyInfoFields", function () {
    it("should allow admin to update company info fields", async function () {
      const { deployer, companyInfo } = await getCompanyInfoContext();
      const legalEntityCode = "JP_LLC";
      const fieldIndex = 0;
      const newField = "updatedField";

      await expect(
        companyInfo
          .connect(deployer)
          .updateCompanyInfoFields(legalEntityCode, fieldIndex, newField)
      )
        .to.emit(companyInfo, "UpdateCompanyInfoField")
        .withArgs(
          await deployer.getAddress(),
          fieldIndex,
          legalEntityCode,
          newField
        );

      const fields = await companyInfo.getCompanyInfoFields(legalEntityCode);
      expect(fields[fieldIndex]).to.equal(newField);
    });

    it("should fail when non-admin tries to update company info fields", async function () {
      const { founder, companyInfo } = await getCompanyInfoContext();
      const legalEntityCode = "JP_LLC";
      const fieldIndex = 0;
      const newField = "updatedField";

      await expect(
        companyInfo
          .connect(founder)
          .updateCompanyInfoFields(legalEntityCode, fieldIndex, newField)
      ).to.be.revertedWithCustomError(
        companyInfo,
        "AccessControlUnauthorizedAccount"
      );
    });

    it("should fail when field index is out of bounds", async function () {
      const { deployer, companyInfo } = await getCompanyInfoContext();
      const legalEntityCode = "JP_LLC";
      const invalidFieldIndex = 999;
      const newField = "updatedField";

      await expect(
        companyInfo
          .connect(deployer)
          .updateCompanyInfoFields(legalEntityCode, invalidFieldIndex, newField)
      ).to.be.revertedWithCustomError(companyInfo, "InvalidLength");
    });
  });

  describe("deleteCompanyInfoFields", function () {
    it("should allow admin to delete company info fields", async function () {
      const { deployer, companyInfo } = await getCompanyInfoContext();
      const legalEntityCode = "JP_LLC";
      const fieldIndex = 0;

      // Get the field before deletion
      const fields = await companyInfo.getCompanyInfoFields(legalEntityCode);
      const fieldToDelete = fields[fieldIndex];

      await expect(
        companyInfo
          .connect(deployer)
          .deleteCompanyInfoFields(legalEntityCode, fieldIndex)
      )
        .to.emit(companyInfo, "DeleteCompanyInfoField")
        .withArgs(
          await deployer.getAddress(),
          fieldIndex,
          legalEntityCode,
          fieldToDelete
        );

      const updatedFields = await companyInfo.getCompanyInfoFields(
        legalEntityCode
      );
      expect(updatedFields).to.not.include(fieldToDelete);
    });

    it("should fail when non-admin tries to delete company info fields", async function () {
      const { founder, companyInfo } = await getCompanyInfoContext();
      const legalEntityCode = "JP_LLC";
      const fieldIndex = 0;

      await expect(
        companyInfo
          .connect(founder)
          .deleteCompanyInfoFields(legalEntityCode, fieldIndex)
      ).to.be.revertedWithCustomError(
        companyInfo,
        "AccessControlUnauthorizedAccount"
      );
    });
  });

  describe("getCompanyInfoFields", function () {
    it("should return all company info fields for a legal entity code", async function () {
      const { companyInfo } = await getCompanyInfoContext();
      const legalEntityCode = "JP_LLC";

      const fields = await companyInfo.getCompanyInfoFields(legalEntityCode);
      expect(fields).to.be.an("array");
      expect(fields.length).to.be.greaterThan(0);
    });
  });

  describe("getCompanyInfo", function () {
    it("should return company info for a valid scid", async function () {
      const { companyInfo } = await getFounderContext();
      const scid = "1234567890"; // Use the same scid as in createCompany

      const info = await companyInfo.getCompanyInfo(scid);
      expect(info.founder).to.not.equal(ethers.ZeroAddress);
      expect(info.companyAddress).to.not.equal(ethers.ZeroAddress);
    });
  });

  describe("getCompanyField", function () {
    it("should return specific field value for a company", async function () {
      const { founder, companyInfo } = await getFounderContext();
      const scid = "1234567890"; // Use the same scid as in createCompany
      const field = "postalCode";
      const value = "100-0001";

      // First set the field
      await companyInfo.connect(founder).setCompanyInfo(scid, field, value);

      // Then get it
      const result = await companyInfo.getCompanyField(scid, field);
      expect(result).to.equal(value);
    });

    it("should return empty string for non-existent field", async function () {
      const { companyInfo } = await getFounderContext();
      const scid = "1234567890"; // Use the same scid as in createCompany
      const nonExistentField = "nonExistentField";

      const result = await companyInfo.getCompanyField(scid, nonExistentField);
      expect(result).to.equal("");
    });
  });
});
