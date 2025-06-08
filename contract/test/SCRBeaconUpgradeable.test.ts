import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import type { SCRBeaconUpgradeable, SCR } from "../typechain-types";
import { deployJP_DAO_LLCFullFixture } from "./utils/DeployFixture";
import { createCompany } from "./utils/CreateCompany";

describe("SCRBeaconUpgradeable Test", function () {
  const getSCRBeaconUpgradeableContext = async () => {
    const {
      deployer,
      borderlessProxy,
      founder,
      sctBeacon,
      sc_jp_dao_llcBeacon,
    } = await loadFixture(deployJP_DAO_LLCFullFixture);

    // Get SCRBeaconUpgradeable contract instance through borderlessProxy
    const scrBeaconUpgradeable = (await ethers.getContractAt(
      "SCRBeaconUpgradeable",
      await borderlessProxy.getAddress()
    )) as SCRBeaconUpgradeable;

    // Get SCR instance through borderlessProxy
    const scr = (await ethers.getContractAt(
      "SCR",
      await borderlessProxy.getAddress()
    )) as SCR;

    return {
      deployer,
      borderlessProxy,
      founder,
      scrBeaconUpgradeable,
      scr,
      sctBeacon,
      sc_jp_dao_llcBeacon,
    };
  };

  describe("updateSCRBeaconName", function () {
    it("founder can update the beacon name", async function () {
      const { deployer, scrBeaconUpgradeable, sctBeacon } =
        await getSCRBeaconUpgradeableContext();

      // Update the beacon name
      const newName = "UpdatedBeaconName";
      const tx = await scrBeaconUpgradeable
        .connect(deployer)
        .updateSCRBeaconName(sctBeacon, newName);

      console.log("ok updateSCRBeaconName");

      // Verify the event is emitted
      await expect(tx)
        .to.emit(scrBeaconUpgradeable, "BeaconNameUpdated")
        .withArgs(sctBeacon, newName);

      console.log("ok emit event");

      // Get the beacon information and verify
      const beaconInfo = await scrBeaconUpgradeable.getSCRBeacon(sctBeacon);
      expect(beaconInfo.name).to.equal(newName);

    });

    it("non-founder cannot update the beacon name", async function () {
      const { founder, scrBeaconUpgradeable } =
        await getSCRBeaconUpgradeableContext();

      // Create a company and get the beacon address
      const { companyAddress } = await createCompany();

      // Non-founder cannot update the beacon name
      await expect(
        scrBeaconUpgradeable
          .connect(founder)
          .updateSCRBeaconName(companyAddress, "NewName")
      ).to.be.revertedWithCustomError(
        scrBeaconUpgradeable,
        "AccessControlUnauthorizedAccount"
      );
    });

    it("cannot update the name of a non-existent beacon", async function () {
      const { deployer, scrBeaconUpgradeable } =
        await getSCRBeaconUpgradeableContext();

      // Non-existent beacon address
      const nonExistentBeacon = "0x0000000000000000000000000000000000000001";

      // Cannot update the name of a non-existent beacon
      await expect(
        scrBeaconUpgradeable
          .connect(deployer)
          .updateSCRBeaconName(nonExistentBeacon, "NewName")
      ).to.be.revertedWithCustomError(scrBeaconUpgradeable, "InvalidBeacon");
    });
  });

  describe("changeSCRBeaconOnline", function () {
    it("founder can change the beacon online status", async function () {
      const { deployer, scrBeaconUpgradeable, sctBeacon } =
        await getSCRBeaconUpgradeableContext();

      // Change the beacon online status to offline
      const changeOfflineTx = await scrBeaconUpgradeable
        .connect(deployer)
        .changeSCRBeaconOnline(sctBeacon, false);

      // Verify the event is emitted
      await expect(changeOfflineTx)
        .to.emit(scrBeaconUpgradeable, "BeaconOffline")
        .withArgs(sctBeacon);

      // Get the beacon information and verify
      const beaconInfoOffline = await scrBeaconUpgradeable.getSCRBeacon(
        sctBeacon
      );

      // Change the beacon online status to online
      const changeOnlineTx = await scrBeaconUpgradeable
        .connect(deployer)
        .changeSCRBeaconOnline(sctBeacon, true);

      // Verify the event is emitted
      await expect(changeOnlineTx)
        .to.emit(scrBeaconUpgradeable, "BeaconOnline")
        .withArgs(sctBeacon);

      // Get the beacon information and verify
      const beaconInfoOnline = await scrBeaconUpgradeable.getSCRBeacon(
        sctBeacon
      );
      expect(beaconInfoOnline.isOnline).to.be.true;
      expect(beaconInfoOffline.isOnline).to.be.false;
    });

    it("non-founder cannot change the beacon online status", async function () {
      const { founder, scrBeaconUpgradeable } =
        await getSCRBeaconUpgradeableContext();

      // Create a company and get the beacon address
      const { companyAddress } = await createCompany();

      // Non-founder cannot change the beacon online status
      await expect(
        scrBeaconUpgradeable
          .connect(founder)
          .changeSCRBeaconOnline(companyAddress, true)
      ).to.be.revertedWithCustomError(
        scrBeaconUpgradeable,
        "AccessControlUnauthorizedAccount"
      );
    });

    it("cannot change the online status of a non-existent beacon", async function () {
      const { deployer, scrBeaconUpgradeable } =
        await getSCRBeaconUpgradeableContext();

      // Non-existent beacon address
      const nonExistentBeacon = "0x0000000000000000000000000000000000000001";

      // Cannot change the online status of a non-existent beacon
      await expect(
        scrBeaconUpgradeable
          .connect(deployer)
          .changeSCRBeaconOnline(nonExistentBeacon, true)
      ).to.be.revertedWithCustomError(scrBeaconUpgradeable, "InvalidBeacon");
    });

    it("cannot change the online status of a beacon that is already online", async function () {
      const { deployer, scrBeaconUpgradeable, sctBeacon } =
        await getSCRBeaconUpgradeableContext();

      // Cannot change the online status of a beacon that is already online
      await expect(
        scrBeaconUpgradeable
          .connect(deployer)
          .changeSCRBeaconOnline(sctBeacon, true)
      )
        .to.be.revertedWithCustomError(
          scrBeaconUpgradeable,
          "BeaconAlreadyOnlineOrOffline"
        )
        .withArgs(sctBeacon);
    });
  });

  describe("getSCRBeacon", function () {
    it("can get the beacon information correctly", async function () {
      const { deployer, scrBeaconUpgradeable, sctBeacon } =
        await getSCRBeaconUpgradeableContext();

      // Set the beacon information
      const name = "TestBeacon";
      await scrBeaconUpgradeable
        .connect(deployer)
        .updateSCRBeaconName(sctBeacon, name);

      // Get the beacon information and verify
      const beaconInfo = await scrBeaconUpgradeable.getSCRBeacon(sctBeacon);
      expect(beaconInfo.name).to.equal(name);
      expect(beaconInfo.isOnline).to.be.true;
    });

    it("cannot get the information of a non-existent beacon", async function () {
      const { scrBeaconUpgradeable } = await getSCRBeaconUpgradeableContext();

      // Non-existent beacon address
      const nonExistentBeacon = "0x0000000000000000000000000000000000000001";

      // Cannot get the information of a non-existent beacon
      const beaconInfo = await scrBeaconUpgradeable.getSCRBeacon(
        nonExistentBeacon
      );
      expect(beaconInfo.name).to.equal("");
      expect(beaconInfo.isOnline).to.be.false;
    });
  });

  describe("getSCRProxy", function () {
    it("can get the proxy information correctly", async function () {
      const { sc_jp_dao_llcBeacon, scrBeaconUpgradeable } =
        await getSCRBeaconUpgradeableContext();

      const { companyAddress } = await createCompany();

      const scBeacon = await scrBeaconUpgradeable.getScProxyBeacon(
        companyAddress
      );
      expect(scBeacon).to.equal(sc_jp_dao_llcBeacon);
    });

    it("cannot get the information of a non-existent proxy", async function () {
      const { scrBeaconUpgradeable } = await getSCRBeaconUpgradeableContext();

      // Non-existent proxy address
      const nonExistentProxy = "0x0000000000000000000000000000000000000001";

      // Cannot get the information of a non-existent proxy
      const borderlessProxy = await scrBeaconUpgradeable.getSCRProxy(
        nonExistentProxy
      );
      expect(borderlessProxy.beacon).to.equal(ethers.ZeroAddress);
    });
  });

  describe("updateSCRProxyName", function () {
    it("founder can update the proxy name", async function () {
      const { founder, scrBeaconUpgradeable } =
        await getSCRBeaconUpgradeableContext();

      // Create a company
      const { companyAddress } = await createCompany();

      // Update the proxy name
      const newName = "UpdatedProxyName";
      const tx = await scrBeaconUpgradeable
        .connect(founder)
        .updateSCRProxyName(companyAddress, newName);

      // Verify the event is emitted
      await expect(tx)
        .to.emit(scrBeaconUpgradeable, "ProxyNameUpdated")
        .withArgs(companyAddress, newName);

      // Get the proxy information and verify
      const proxyInfo = await scrBeaconUpgradeable.getSCRProxy(companyAddress);
      expect(proxyInfo.name).to.equal(newName);
    });

    it("non-founder cannot update the proxy name", async function () {
      const { deployer, scrBeaconUpgradeable } =
        await getSCRBeaconUpgradeableContext();

      // Create a company
      const { companyAddress } = await createCompany();

      // Non-founder cannot update the proxy name
      await expect(
        scrBeaconUpgradeable
          .connect(deployer)
          .updateSCRProxyName(companyAddress, "NewName")
      ).to.be.revertedWithCustomError(
        scrBeaconUpgradeable,
        "SmartCompanyIdNotFound"
      );
    });

    it("cannot update the name of a non-existent proxy", async function () {
      const { founder, scrBeaconUpgradeable } =
        await getSCRBeaconUpgradeableContext();

      // Non-existent proxy address
      const nonExistentProxy = "0x0000000000000000000000000000000000000001";

      // Cannot update the name of a non-existent proxy
      await expect(
        scrBeaconUpgradeable
          .connect(founder)
          .updateSCRProxyName(nonExistentProxy, "NewName")
      ).to.be.revertedWithCustomError(
        scrBeaconUpgradeable,
        "SmartCompanyIdNotFound"
      );
    });
  });
});
