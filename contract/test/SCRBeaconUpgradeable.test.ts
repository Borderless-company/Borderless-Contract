import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import type { SCRBeaconUpgradeable, SCR } from "../typechain-types";
import {
  deployJP_DAO_LLCFullFixture,
} from "./utils/DeployFixture";
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
    it("管理者がビーコン名を更新できること", async function () {
      const { deployer, scrBeaconUpgradeable, sctBeacon } =
        await getSCRBeaconUpgradeableContext();
        console.log("ok sctBeacon", sctBeacon);

      console.log("ok deploy fixture");
      console.log("ok sctBeacon", sctBeacon);

      // ビーコン名を更新
      const newName = "UpdatedBeaconName";
      const tx = await scrBeaconUpgradeable
        .connect(deployer)
        .updateSCRBeaconName(sctBeacon, newName);

      console.log("ok updateSCRBeaconName");

      // イベントが発行されることを確認
      await expect(tx)
        .to.emit(scrBeaconUpgradeable, "BeaconNameUpdated")
        .withArgs(sctBeacon, newName);

      console.log("ok emit event");

      // ビーコン情報を取得して確認
      const beaconInfo = await scrBeaconUpgradeable.getSCRBeacon(sctBeacon);
      expect(beaconInfo.name).to.equal(newName);

      console.log("ok getSCRBeacon");
    });

    it("管理者以外がビーコン名を更新しようとすると失敗すること", async function () {
      const { founder, scrBeaconUpgradeable } =
        await getSCRBeaconUpgradeableContext();

      // 会社を作成してビーコンアドレスを取得
      const { companyAddress } = await createCompany();

      // 管理者以外がビーコン名を更新しようとする
      await expect(
        scrBeaconUpgradeable
          .connect(founder)
          .updateSCRBeaconName(companyAddress, "NewName")
      ).to.be.revertedWithCustomError(
        scrBeaconUpgradeable,
        "AccessControlUnauthorizedAccount"
      );
    });

    it("存在しないビーコンの名前を更新しようとすると失敗すること", async function () {
      const { deployer, scrBeaconUpgradeable } =
        await getSCRBeaconUpgradeableContext();

      // 存在しないビーコンのアドレス
      const nonExistentBeacon = "0x0000000000000000000000000000000000000001";

      // 存在しないビーコンの名前を更新しようとする
      await expect(
        scrBeaconUpgradeable
          .connect(deployer)
          .updateSCRBeaconName(nonExistentBeacon, "NewName")
      ).to.be.revertedWithCustomError(scrBeaconUpgradeable, "InvalidBeacon");
    });
  });

  describe("changeSCRBeaconOnline", function () {
    it("管理者がビーコンのオンライン状態を変更できること", async function () {
      const { deployer, scrBeaconUpgradeable, sctBeacon } =
        await getSCRBeaconUpgradeableContext();

      // ビーコンをオフラインに設定
      const changeOfflineTx = await scrBeaconUpgradeable
        .connect(deployer)
        .changeSCRBeaconOnline(sctBeacon, false);

      // イベントが発行されることを確認
      await expect(changeOfflineTx)
        .to.emit(scrBeaconUpgradeable, "BeaconOffline")
        .withArgs(sctBeacon);

      // ビーコン情報を取得して確認
      const beaconInfoOffline = await scrBeaconUpgradeable.getSCRBeacon(
        sctBeacon
      );

      // ビーコンをオンラインに設定
      const changeOnlineTx = await scrBeaconUpgradeable
        .connect(deployer)
        .changeSCRBeaconOnline(sctBeacon, true);

      // イベントが発行されることを確認
      await expect(changeOnlineTx)
        .to.emit(scrBeaconUpgradeable, "BeaconOnline")
        .withArgs(sctBeacon);

      // ビーコン情報を取得して確認
      const beaconInfoOnline = await scrBeaconUpgradeable.getSCRBeacon(
        sctBeacon
      );
      expect(beaconInfoOnline.isOnline).to.be.true;
      expect(beaconInfoOffline.isOnline).to.be.false;
    });

    it("管理者以外がビーコンのオンライン状態を変更しようとすると失敗すること", async function () {
      const { founder, scrBeaconUpgradeable } =
        await getSCRBeaconUpgradeableContext();

      // 会社を作成してビーコンアドレスを取得
      const { companyAddress } = await createCompany();

      // 管理者以外がビーコンのオンライン状態を変更しようとする
      await expect(
        scrBeaconUpgradeable
          .connect(founder)
          .changeSCRBeaconOnline(companyAddress, true)
      ).to.be.revertedWithCustomError(
        scrBeaconUpgradeable,
        "AccessControlUnauthorizedAccount"
      );
    });

    it("存在しないビーコンのオンライン状態を変更しようとすると失敗すること", async function () {
      const { deployer, scrBeaconUpgradeable } =
        await getSCRBeaconUpgradeableContext();

      // 存在しないビーコンのアドレス
      const nonExistentBeacon = "0x0000000000000000000000000000000000000001";

      // 存在しないビーコンのオンライン状態を変更しようとする
      await expect(
        scrBeaconUpgradeable
          .connect(deployer)
          .changeSCRBeaconOnline(nonExistentBeacon, true)
      ).to.be.revertedWithCustomError(scrBeaconUpgradeable, "InvalidBeacon");
    });

    it("既に同じ状態のビーコンのオンライン状態を変更しようとすると失敗すること", async function () {
      const { deployer, scrBeaconUpgradeable, sctBeacon } =
        await getSCRBeaconUpgradeableContext();

      // 同じ状態（オンライン）に設定しようとする
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
    it("ビーコン情報を正しく取得できること", async function () {
      const { deployer, scrBeaconUpgradeable, sctBeacon } =
        await getSCRBeaconUpgradeableContext();

      // ビーコン情報を設定
      const name = "TestBeacon";
      await scrBeaconUpgradeable
        .connect(deployer)
        .updateSCRBeaconName(sctBeacon, name);

      // ビーコン情報を取得して確認
      const beaconInfo = await scrBeaconUpgradeable.getSCRBeacon(sctBeacon);
      expect(beaconInfo.name).to.equal(name);
      expect(beaconInfo.isOnline).to.be.true;
    });

    it("存在しないビーコンの情報を取得すると0アドレスが返ること", async function () {
      const { scrBeaconUpgradeable } = await getSCRBeaconUpgradeableContext();

      // 存在しないビーコンのアドレス
      const nonExistentBeacon = "0x0000000000000000000000000000000000000001";

      // 存在しないビーコンの情報を取得
      const beaconInfo = await scrBeaconUpgradeable.getSCRBeacon(
        nonExistentBeacon
      );
      expect(beaconInfo.name).to.equal("");
      expect(beaconInfo.isOnline).to.be.false;
    });
  });

  describe("getSCRProxy", function () {
    it("プロキシ情報を正しく取得できること", async function () {
      const { sc_jp_dao_llcBeacon, scrBeaconUpgradeable } =
        await getSCRBeaconUpgradeableContext();

      const { companyAddress } = await createCompany();

      const scBeacon = await scrBeaconUpgradeable.getScProxyBeacon(
        companyAddress
      );
      expect(scBeacon).to.equal(sc_jp_dao_llcBeacon);
    });

    it("存在しないプロキシの情報を取得すると0アドレスが返ること", async function () {
      const { scrBeaconUpgradeable } = await getSCRBeaconUpgradeableContext();

      // 存在しないプロキシのアドレス
      const nonExistentProxy = "0x0000000000000000000000000000000000000001";

      // 存在しないプロキシの情報を取得
      const borderlessProxy = await scrBeaconUpgradeable.getSCRProxy(
        nonExistentProxy
      );
      expect(borderlessProxy.beacon).to.equal(ethers.ZeroAddress);
    });
  });

  describe("updateSCRProxyName", function () {
    it("founderがプロキシ名を更新できること", async function () {
      const { founder, scrBeaconUpgradeable } =
        await getSCRBeaconUpgradeableContext();

      // 会社を作成
      const { companyAddress } = await createCompany();

      // プロキシ名を更新
      const newName = "UpdatedProxyName";
      const tx = await scrBeaconUpgradeable
        .connect(founder)
        .updateSCRProxyName(companyAddress, newName);

      // イベントが発行されることを確認
      await expect(tx)
        .to.emit(scrBeaconUpgradeable, "ProxyNameUpdated")
        .withArgs(companyAddress, newName);

      // プロキシ情報を取得して確認
      const proxyInfo = await scrBeaconUpgradeable.getSCRProxy(companyAddress);
      expect(proxyInfo.name).to.equal(newName);
    });

    it("founder以外がプロキシ名を更新しようとすると失敗すること", async function () {
      const { deployer, scrBeaconUpgradeable } =
        await getSCRBeaconUpgradeableContext();

      // 会社を作成
      const { companyAddress } = await createCompany();

      // founder以外がプロキシ名を更新しようとする
      await expect(
        scrBeaconUpgradeable
          .connect(deployer)
          .updateSCRProxyName(companyAddress, "NewName")
      ).to.be.revertedWithCustomError(
        scrBeaconUpgradeable,
        "SmartCompanyIdNotFound"
      );
    });

    it("存在しないプロキシの名前を更新しようとすると失敗すること", async function () {
      const { founder, scrBeaconUpgradeable } =
        await getSCRBeaconUpgradeableContext();

      // 存在しないプロキシのアドレス
      const nonExistentProxy = "0x0000000000000000000000000000000000000001";

      // 存在しないプロキシの名前を更新しようとする
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
