import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import type { AOI, SCT } from "../typechain-types";
import { ServiceType } from "./utils/Enum";

import { deployJP_DAO_LLCFullFixture } from "./utils/DeployFixture";
import { grantFounderRole, grantTreasuryRole } from "./utils/Role";
import { createCompany } from "./utils/CreateCompany";

describe("SCT Service", function () {
  const getSCTContext = async () => {
    const {
      deployer,
      founder,
      executiveMember,
      executiveMember2,
      borderlessProxy,
      scrImplementation,
      serviceFactoryImplementation
    } = await loadFixture(deployJP_DAO_LLCFullFixture);

    // Grant role to founder
    await grantFounderRole(deployer, borderlessProxy, founder);

    // Create company and get SCT instance
    const { companyAddress, services } = await createCompany();

    const sct = (await ethers.getContractAt(
      "SCT",
      companyAddress
    )) as SCT;

    const aoi = await ethers.getContractAt("AOI", services[5]);

    return {
      deployer,
      founder,
      executiveMember,
      executiveMember2,
      borderlessProxy,
      scrImplementation,
      serviceFactoryImplementation,
      sct,
      companyAddress,
      aoi
    };
  };

  describe("Service Registration", function () {
    it("should register services by founder", async function () {
      const { sct, founder, executiveMember, borderlessProxy, deployer } =
        await getSCTContext();

      // Mock service address
      const mockServiceAddress = executiveMember.address;
      const serviceTypes = [ServiceType.LETS_EXE];
      const services = [mockServiceAddress];

      // Grant role to founder
      await grantFounderRole(deployer, borderlessProxy, founder);

      // Register service
      await expect(sct.connect(founder).registerService(serviceTypes, services))
        .to.emit(sct, "RegisterService")
        .withArgs(await sct.getAddress(), serviceTypes, services);

      // Verify registered service address
      const registeredService = await sct.getService(ServiceType.LETS_EXE);
      expect(registeredService).to.equal(mockServiceAddress);
    });

    it("should register services by SCR", async function () {
      const { sct, founder, executiveMember } = await getSCTContext();

      const mockServiceAddress = executiveMember.address;
      const serviceTypes = [ServiceType.LETS_EXE];
      const services = [mockServiceAddress];

      // Register service from SCR
      await expect(sct.connect(founder).registerService(serviceTypes, services))
        .to.emit(sct, "RegisterService")
        .withArgs(await sct.getAddress(), serviceTypes, services);

      // Verify registered service address
      const registeredService = await sct.getService(ServiceType.LETS_EXE);
      expect(registeredService).to.equal(mockServiceAddress);
    });

    it("should fail to register services by unauthorized user", async function () {
      const { sct, executiveMember, executiveMember2 } = await getSCTContext();

      const mockServiceAddress = executiveMember.address;
      const serviceTypes = [ServiceType.LETS_EXE];
      const services = [mockServiceAddress];

      // Attempt to register service from unauthorized user
      await expect(
        sct.connect(executiveMember2).registerService(serviceTypes, services)
      ).to.be.revertedWithCustomError(sct, "NotFounderOrSCR");
    });

    it("should fail to register service with zero address", async function () {
      const { sct, founder, borderlessProxy, deployer } = await getSCTContext();

      const zeroAddress = ethers.ZeroAddress;
      const serviceTypes = [ServiceType.LETS_EXE];
      const services = [zeroAddress];

      // Grant role to founder
      await grantFounderRole(deployer, borderlessProxy, founder);

      // Attempt to register service with zero address
      await expect(
        sct.connect(founder).registerService(serviceTypes, services)
      ).to.be.revertedWithCustomError(sct, "ZeroAddress");
    });
  });

  describe("Investment Amount Management", function () {
    it("should set investment amount by treasury role", async function () {
      const { sct, founder, executiveMember, companyAddress } = await getSCTContext();

      const investmentAmount = ethers.parseEther("1.0");

      // Grant TREASURY_ROLE to executiveMember
      await grantTreasuryRole(founder, companyAddress, executiveMember);

      // Set investment amount
      await sct
        .connect(executiveMember)
        .setInvestmentAmount(executiveMember.address, investmentAmount);

      // Verify set investment amount
      const amount = await sct.getInvestmentAmount(executiveMember.address);
      expect(amount).to.equal(investmentAmount);
    });

    it("should fail to set investment amount by unauthorized user", async function () {
      const { sct, executiveMember, executiveMember2 } = await getSCTContext();

      const investmentAmount = ethers.parseEther("1.0");

      // Attempt to set investment amount from unauthorized user
      await expect(
        sct.connect(executiveMember2).setInvestmentAmount(executiveMember.address, investmentAmount)
      ).to.be.revertedWithCustomError(sct, "AccessControlUnauthorizedAccount");
    });
  });

  describe("Information Retrieval", function () {
    it("should return correct SCR address", async function () {
      const { sct, borderlessProxy } = await getSCTContext();

      const scrAddress = await sct.getSCR();
      expect(scrAddress).to.equal(await borderlessProxy.getAddress());
    });

    it("should return zero address for unregistered service", async function () {
      const { sct, aoi } = await getSCTContext();

      const serviceAddress = await sct.getService(ServiceType.AOI);
      expect(serviceAddress).to.equal(await aoi.getAddress());
    });

    it("should return zero for unset investment amount", async function () {
      const { sct, executiveMember } = await getSCTContext();

      const amount = await sct.getInvestmentAmount(executiveMember.address);
      expect(amount).to.equal(0);
    });
  });
});
