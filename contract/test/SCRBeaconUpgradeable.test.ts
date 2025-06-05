import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import type {
  SCRBeaconUpgradeable,
  BorderlessAccessControl,
  SCR,
} from "../typechain-types";
import { deployFullFixture } from "./utils/DeployFixture";
import { createCompany } from "./utils/CreateCompany";

describe("SCRBeaconUpgradeable Test", function () {
  const getSCRBeaconUpgradeableContext = async () => {
    const { deployer, proxy, founder, sctBeaconAddress } = await loadFixture(
      deployFullFixture
    );

    // Get SCRBeaconUpgradeable contract instance through proxy
    const scrBeaconUpgradeable = (await ethers.getContractAt(
      "SCRBeaconUpgradeable",
      await proxy.getAddress()
    )) as SCRBeaconUpgradeable;

    // Get SCR instance through proxy
    const scr = (await ethers.getContractAt(
      "SCR",
      await proxy.getAddress()
    )) as SCR;

    return {
      deployer,
      proxy,
      founder,
      scrBeaconUpgradeable,
      scr,
      sctBeaconAddress,
    };
  };

  describe("updateSCRBeaconName", function () {
    it("管理者がビーコン名を更新できること", async function () {
      const { deployer, scrBeaconUpgradeable, sctBeaconAddress } =
        await getSCRBeaconUpgradeableContext();

      // ビーコン名を更新
      const newName = "UpdatedBeaconName";
      console.log("ok prepare name");
      const tx = await scrBeaconUpgradeable
        .connect(deployer)
        .updateSCRBeaconName(sctBeaconAddress, newName);

      console.log("ok update name");

      // イベントが発行されることを確認
      await expect(tx)
        .to.emit(scrBeaconUpgradeable, "BeaconNameUpdated")
        .withArgs(sctBeaconAddress, newName);

      // ビーコン情報を取得して確認
      const beaconInfo = await scrBeaconUpgradeable.getSCRBeacon(
        sctBeaconAddress
      );
      expect(beaconInfo.name).to.equal(newName);
    });

    it("管理者以外がビーコン名を更新しようとすると失敗すること", async function () {
      const { deployer, founder, scrBeaconUpgradeable } =
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
      const { deployer, scrBeaconUpgradeable, sctBeaconAddress } =
        await getSCRBeaconUpgradeableContext();

      // ビーコンをオフラインに設定
      const changeOfflineTx = await scrBeaconUpgradeable
        .connect(deployer)
        .changeSCRBeaconOnline(sctBeaconAddress, false);

      // イベントが発行されることを確認
      await expect(changeOfflineTx)
        .to.emit(scrBeaconUpgradeable, "BeaconOffline")
        .withArgs(sctBeaconAddress);

      // ビーコン情報を取得して確認
      const beaconInfoOffline = await scrBeaconUpgradeable.getSCRBeacon(
        sctBeaconAddress
      );

      // ビーコンをオンラインに設定
      const changeOnlineTx = await scrBeaconUpgradeable
        .connect(deployer)
        .changeSCRBeaconOnline(sctBeaconAddress, true);

      // イベントが発行されることを確認
      await expect(changeOnlineTx)
        .to.emit(scrBeaconUpgradeable, "BeaconOnline")
        .withArgs(sctBeaconAddress);

      // ビーコン情報を取得して確認
      const beaconInfoOnline = await scrBeaconUpgradeable.getSCRBeacon(
        sctBeaconAddress
      );
      expect(beaconInfoOnline.isOnline).to.be.true;
      expect(beaconInfoOffline.isOnline).to.be.false;
    });

    it("管理者以外がビーコンのオンライン状態を変更しようとすると失敗すること", async function () {
      const { deployer, founder, scrBeaconUpgradeable } =
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
      const { deployer, scrBeaconUpgradeable, sctBeaconAddress } =
        await getSCRBeaconUpgradeableContext();

      // 同じ状態（オンライン）に設定しようとする
      await expect(
        scrBeaconUpgradeable
          .connect(deployer)
          .changeSCRBeaconOnline(sctBeaconAddress, true)
      )
        .to.be.revertedWithCustomError(
          scrBeaconUpgradeable,
          "BeaconAlreadyOnlineOrOffline"
        )
        .withArgs(sctBeaconAddress);
    });
  });

  describe("getSCRBeacon", function () {
    it("ビーコン情報を正しく取得できること", async function () {
      const { deployer, scrBeaconUpgradeable, sctBeaconAddress } =
        await getSCRBeaconUpgradeableContext();

      // ビーコン情報を設定
      const name = "TestBeacon";
      await scrBeaconUpgradeable
        .connect(deployer)
        .updateSCRBeaconName(sctBeaconAddress, name);

      // ビーコン情報を取得して確認
      const beaconInfo = await scrBeaconUpgradeable.getSCRBeacon(
        sctBeaconAddress
      );
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
      const { scrBeaconUpgradeable } = await getSCRBeaconUpgradeableContext();

      // プロキシ情報を取得して確認
      const proxy = await scrBeaconUpgradeable.getSCRProxy(
        await scrBeaconUpgradeable.getAddress()
      );
      expect(proxy.beacon).to.equal(ethers.ZeroAddress);
    });

    it("存在しないプロキシの情報を取得すると0アドレスが返ること", async function () {
      const { scrBeaconUpgradeable } = await getSCRBeaconUpgradeableContext();

      // 存在しないプロキシのアドレス
      const nonExistentProxy = "0x0000000000000000000000000000000000000001";

      // 存在しないプロキシの情報を取得
      const proxy = await scrBeaconUpgradeable.getSCRProxy(nonExistentProxy);
      expect(proxy.beacon).to.equal(ethers.ZeroAddress);
    });
  });
});
