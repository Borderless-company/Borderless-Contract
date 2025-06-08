import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import type {
  ServiceFactory,
  BorderlessAccessControl,
} from "../typechain-types";
import { deployJP_DAO_LLCFullFixture } from "./utils/DeployFixture";
import { ServiceType } from "./utils/Enum";

describe("ServiceFactory Test", function () {
  const getServiceFactoryContext = async () => {
    const { deployer, borderlessProxy, founder } = await loadFixture(
      deployJP_DAO_LLCFullFixture
    );

    // Get ServiceFactory contract instance
    const serviceFactory = (await ethers.getContractAt(
      "ServiceFactory",
      await borderlessProxy.getAddress()
    )) as ServiceFactory;

    return {
      deployer,
      borderlessProxy,
      founder,
      serviceFactory,
    };
  };

  describe("setService", function () {
    it("founder can set a service", async function () {
      const { deployer, serviceFactory } = await getServiceFactoryContext();

      // Set a service
      const tx = await serviceFactory
        .connect(deployer)
        .setService(
          await serviceFactory.getAddress(),
          "TestService",
          ServiceType.GOVERNANCE
        );
      const receipt = await tx.wait();
      const beacon = receipt?.logs[0].address;
      if (!beacon) throw new Error("Beacon address not found in logs");

      // Verify the beacon is set correctly
      expect(ethers.isAddress(beacon)).to.be.true;

      // Verify the service type is set correctly
      const serviceType = await serviceFactory.getServiceType(beacon);
      expect(serviceType).to.equal(ServiceType.GOVERNANCE);
    });

    it("non-founder cannot set a service", async function () {
      const { founder, serviceFactory } = await getServiceFactoryContext();

      // Non-founder cannot set a service
      await expect(
        serviceFactory
          .connect(founder)
          .setService(
            await serviceFactory.getAddress(),
            "TestService",
            ServiceType.GOVERNANCE
          )
      )
        .to.be.revertedWithCustomError(
          serviceFactory,
          "AccessControlUnauthorizedAccount"
        )
        .withArgs(
          await founder.getAddress(),
          "0x0000000000000000000000000000000000000000000000000000000000000000"
        );
    });
  });

  describe("setLetsSaleBeacon", function () {
    it("founder can set the LETS sale beacon", async function () {
      const { deployer, serviceFactory } = await getServiceFactoryContext();

      // Deploy a test beacon
      const LETS_JP_LLC_EXE = await ethers.getContractFactory(
        "LETS_JP_LLC_EXE"
      );
      const letsBeacon = await LETS_JP_LLC_EXE.deploy();
      const LETS_JP_LLC_SALE = await ethers.getContractFactory(
        "LETS_JP_LLC_SALE"
      );
      const letsSaleBeacon = await LETS_JP_LLC_SALE.deploy();

      // Set the LETS sale beacon
      await serviceFactory
        .connect(deployer)
        .setLetsSaleBeacon(
          await letsBeacon.getAddress(),
          await letsSaleBeacon.getAddress()
        );

      // Verify the LETS sale beacon is set correctly
      // Set a new service and verify the LETS sale beacon is set correctly
      const tx = await serviceFactory
        .connect(deployer)
        .setService(
          await letsBeacon.getAddress(),
          "TestService",
          ServiceType.LETS_EXE
        );
      const receipt = await tx.wait();
      const beacon = receipt?.logs[0].address;
      if (!beacon) throw new Error("Beacon address not found in logs");

      // Verify the service type
      const serviceType = await serviceFactory.getServiceType(beacon);
      expect(serviceType).to.equal(ServiceType.LETS_EXE);
    });

    it("non-founder cannot set the LETS sale beacon", async function () {
      const { founder, serviceFactory } = await getServiceFactoryContext();

      // Deploy a test beacon
      const LETS_JP_LLC_EXE = await ethers.getContractFactory(
        "LETS_JP_LLC_EXE"
      );
      const letsBeacon = await LETS_JP_LLC_EXE.deploy();
      const LETS_JP_LLC_SALE = await ethers.getContractFactory(
        "LETS_JP_LLC_SALE"
      );
      const letsSaleBeacon = await LETS_JP_LLC_SALE.deploy();

      // Non-founder cannot set the LETS sale beacon
      await expect(
        serviceFactory
          .connect(founder)
          .setLetsSaleBeacon(
            await letsBeacon.getAddress(),
            await letsSaleBeacon.getAddress()
          )
      )
        .to.be.revertedWithCustomError(
          serviceFactory,
          "AccessControlUnauthorizedAccount"
        )
        .withArgs(
          await founder.getAddress(),
          "0x0000000000000000000000000000000000000000000000000000000000000000"
        );
    });
  });

  describe("getServiceType", function () {
    it("can get the service type correctly", async function () {
      const { deployer, serviceFactory } = await getServiceFactoryContext();

      // Set a service
      const tx = await serviceFactory
        .connect(deployer)
        .setService(
          await serviceFactory.getAddress(),
          "TestService",
          ServiceType.LETS_EXE
        );
      const receipt = await tx.wait();
      const beacon = receipt?.logs[0].address;
      if (!beacon) throw new Error("Beacon address not found in logs");

      // Get the service type and verify
      const serviceType = await serviceFactory.getServiceType(beacon);
      expect(serviceType).to.equal(ServiceType.LETS_EXE);
    });

    it("cannot get the service type of a non-existent beacon", async function () {
      const { serviceFactory } = await getServiceFactoryContext();

      // Non-existent beacon address
      const nonExistentBeacon = "0x0000000000000000000000000000000000000001";

      // Get the service type and verify
      const serviceType = await serviceFactory.getServiceType(
        nonExistentBeacon
      );
      expect(serviceType).to.equal(0);
    });
  });

  describe("getFounderService", function () {
    it("can get the founder's service correctly", async function () {
      const { deployer, founder, serviceFactory } =
        await getServiceFactoryContext();

      // Set a service
      const tx = await serviceFactory
        .connect(deployer)
        .setService(
          await serviceFactory.getAddress(),
          "TestService",
          ServiceType.LETS_EXE
        );
      const receipt = await tx.wait();
      const beacon = receipt?.logs[0].address;
      if (!beacon) throw new Error("Beacon address not found in logs");

      // Get the founder's service
      const founderService = await serviceFactory.getFounderService(
        await founder.getAddress(),
        ServiceType.LETS_EXE
      );

      // Verify the service is set correctly
      expect(ethers.isAddress(founderService)).to.be.true;
    });

    it("cannot get the founder's service of a non-existent founder", async function () {
      const { serviceFactory } = await getServiceFactoryContext();

      // Non-existent founder address
      const nonExistentFounder = "0x0000000000000000000000000000000000000001";

      // Get the founder's service
      const founderService = await serviceFactory.getFounderService(
        nonExistentFounder,
        ServiceType.LETS_EXE
      );
      expect(founderService).to.equal(
        "0x0000000000000000000000000000000000000000"
      );
    });
  });
});
