import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import type { ServiceFactoryBeaconUpgradeable } from "../typechain-types";
import { deployJP_DAO_LLCFullFixture } from "./utils/DeployFixture";
import { createCompany } from "./utils/CreateCompany";

describe("ServiceFactoryBeaconUpgradeable", function () {
  const getServiceFactoryBeaconUpgradeableContext = async () => {
    const {
      deployer,
      borderlessProxy,
      founder,
      executiveMember,
      lets_jp_llc_exeBeacon,
      lets_jp_llc_non_exeBeacon,
      governance_jp_llcBeacon,
      lets_jp_llc_saleBeacon,
    } = await loadFixture(deployJP_DAO_LLCFullFixture);

    // Get ServiceFactoryBeaconUpgradeable contract instance
    const serviceFactoryBeaconUpgradeable = (await ethers.getContractAt(
      "ServiceFactoryBeaconUpgradeable",
      await borderlessProxy.getAddress()
    )) as ServiceFactoryBeaconUpgradeable;

    return {
      deployer,
      borderlessProxy,
      founder,
      executiveMember,
      serviceFactoryBeaconUpgradeable,
      lets_jp_llc_exeBeacon,
      lets_jp_llc_non_exeBeacon,
      governance_jp_llcBeacon,
      lets_jp_llc_saleBeacon,
    };
  };

  describe("updateServiceFactoryBeaconName", function () {
    it("should update beacon name when called by admin", async function () {
      const {
        deployer,
        serviceFactoryBeaconUpgradeable,
        lets_jp_llc_exeBeacon,
      } = await getServiceFactoryBeaconUpgradeableContext();

      const newName = "New Beacon Name";

      const tx = await serviceFactoryBeaconUpgradeable
        .connect(deployer)
        .updateServiceFactoryBeaconName(lets_jp_llc_exeBeacon, newName);

      const receipt = await tx.wait();
      expect(receipt)
        .to.emit(serviceFactoryBeaconUpgradeable, "BeaconNameUpdated")
        .withArgs(lets_jp_llc_exeBeacon, newName);

      const beaconInfo =
        await serviceFactoryBeaconUpgradeable.getServiceFactoryBeacon(
          lets_jp_llc_exeBeacon
        );
      expect(beaconInfo.name).to.equal(newName);
    });

    it("should fail to update beacon name when called by non-admin", async function () {
      const {
        founder,
        serviceFactoryBeaconUpgradeable,
        lets_jp_llc_exeBeacon,
      } = await getServiceFactoryBeaconUpgradeableContext();

      const newName = "New Beacon Name";

      await expect(
        serviceFactoryBeaconUpgradeable
          .connect(founder)
          .updateServiceFactoryBeaconName(lets_jp_llc_exeBeacon, newName)
      ).to.be.revertedWithCustomError(
        serviceFactoryBeaconUpgradeable,
        "AccessControlUnauthorizedAccount"
      );
    });
  });

  describe("changeServiceFactoryBeaconOnline", function () {
    it("should fail to change beacon online status when already online", async function () {
      const {
        deployer,
        serviceFactoryBeaconUpgradeable,
        lets_jp_llc_exeBeacon,
      } = await getServiceFactoryBeaconUpgradeableContext();

      const isOnline = true;

      await expect(
        serviceFactoryBeaconUpgradeable
          .connect(deployer)
          .changeServiceFactoryBeaconOnline(lets_jp_llc_exeBeacon, isOnline)
      ).to.be.revertedWithCustomError(
        serviceFactoryBeaconUpgradeable,
        "BeaconAlreadyOnlineOrOffline"
      );
    });

    it("should change beacon offline status when called by admin", async function () {
      const {
        deployer,
        serviceFactoryBeaconUpgradeable,
        lets_jp_llc_exeBeacon,
      } = await getServiceFactoryBeaconUpgradeableContext();

      const isOnline = false;

      const tx = await serviceFactoryBeaconUpgradeable
        .connect(deployer)
        .changeServiceFactoryBeaconOnline(lets_jp_llc_exeBeacon, isOnline);

      const receipt = await tx.wait();
      expect(receipt)
        .to.emit(serviceFactoryBeaconUpgradeable, "BeaconOffline")
        .withArgs(lets_jp_llc_exeBeacon);

      const beaconInfo =
        await serviceFactoryBeaconUpgradeable.getServiceFactoryBeacon(
          lets_jp_llc_exeBeacon
        );
      expect(beaconInfo.isOnline).to.equal(isOnline);
    });

    it("should fail to change beacon status when called by non-admin", async function () {
      const {
        founder,
        serviceFactoryBeaconUpgradeable,
        lets_jp_llc_exeBeacon,
      } = await getServiceFactoryBeaconUpgradeableContext();

      const isOnline = false;

      await expect(
        serviceFactoryBeaconUpgradeable
          .connect(founder)
          .changeServiceFactoryBeaconOnline(lets_jp_llc_exeBeacon, isOnline)
      ).to.be.revertedWithCustomError(
        serviceFactoryBeaconUpgradeable,
        "AccessControlUnauthorizedAccount"
      );
    });

    it("should fail to change beacon status when already in target state", async function () {
      const {
        deployer,
        serviceFactoryBeaconUpgradeable,
        lets_jp_llc_exeBeacon,
      } = await getServiceFactoryBeaconUpgradeableContext();

      // First change to offline
      await serviceFactoryBeaconUpgradeable
        .connect(deployer)
        .changeServiceFactoryBeaconOnline(lets_jp_llc_exeBeacon, false);

      // Try to change to offline again
      await expect(
        serviceFactoryBeaconUpgradeable
          .connect(deployer)
          .changeServiceFactoryBeaconOnline(lets_jp_llc_exeBeacon, false)
      ).to.be.revertedWithCustomError(
        serviceFactoryBeaconUpgradeable,
        "BeaconAlreadyOnlineOrOffline"
      );
    });
  });

  describe("getServiceFactoryBeacon", function () {
    it("should return correct beacon info", async function () {
      const {
        deployer,
        serviceFactoryBeaconUpgradeable,
        lets_jp_llc_exeBeacon,
      } = await getServiceFactoryBeaconUpgradeableContext();

      const name = "Test Beacon";

      // Set up beacon
      await serviceFactoryBeaconUpgradeable
        .connect(deployer)
        .updateServiceFactoryBeaconName(lets_jp_llc_exeBeacon, name);

      const beaconInfo =
        await serviceFactoryBeaconUpgradeable.getServiceFactoryBeacon(
          lets_jp_llc_exeBeacon
        );
      expect(beaconInfo.name).to.equal(name);
      expect(beaconInfo.isOnline).to.equal(true); // Initially online
      expect(beaconInfo.implementation).not.to.equal(lets_jp_llc_exeBeacon);
      expect(beaconInfo.proxyCount).to.equal(0);
    });
  });

  describe("getServiceFactoryProxy", function () {
    it("should return correct borderlessProxy info", async function () {
      const {
        founder,
        serviceFactoryBeaconUpgradeable,
        governance_jp_llcBeacon,
      } = await getServiceFactoryBeaconUpgradeableContext();
      const { services } = await createCompany();

      const name = "Test Proxy";

      // Set up borderlessProxy
      await serviceFactoryBeaconUpgradeable
        .connect(founder)
        .updateServiceFactoryProxyName(services[0], name);

      const proxyInfo =
        await serviceFactoryBeaconUpgradeable.getServiceFactoryProxy(
          services[0]
        );
      expect(proxyInfo.name).to.equal(name);
      expect(proxyInfo.beacon).to.equal(governance_jp_llcBeacon);
    });
  });
});
