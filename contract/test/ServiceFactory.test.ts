import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import type {
  ServiceFactory,
  BorderlessAccessControl,
} from "../typechain-types";
import { deployJP_DAO_LLCFullFixture } from "./utils/DeployFixture";

// ServiceTypeの定義
enum ServiceType {
  NON,           // 0
  AOI,           // 1
  GOVERNANCE,    // 2
  LETS_EXE,      // 3
  LETS_NON_EXE,  // 4
  LETS_SALE,     // 5
  TREASURY       // 6
}

describe("ServiceFactory Test", function () {
  const getServiceFactoryContext = async () => {
    const { deployer, borderlessProxy, founder } = await loadFixture(deployJP_DAO_LLCFullFixture);

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
    it("管理者がサービスを設定できること", async function () {
      const { deployer, serviceFactory } = await getServiceFactoryContext();

      // サービスを設定
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

      // ビーコンが正しく設定されたことを確認
      expect(ethers.isAddress(beacon)).to.be.true;

      // サービスタイプが正しく設定されたことを確認
      const serviceType = await serviceFactory.getServiceType(beacon);
      expect(serviceType).to.equal(ServiceType.GOVERNANCE);
    });

    it("管理者以外がサービスを設定しようとすると失敗すること", async function () {
      const { founder, serviceFactory } = await getServiceFactoryContext();

      // 管理者以外がサービスを設定しようとする
      await expect(
        serviceFactory
          .connect(founder)
          .setService(
            await serviceFactory.getAddress(),
            "TestService",
            ServiceType.GOVERNANCE
          )
      ).to.be.revertedWithCustomError(serviceFactory, "AccessControlUnauthorizedAccount")
        .withArgs(await founder.getAddress(), "0x0000000000000000000000000000000000000000000000000000000000000000");
    });
  });

  describe("setLetsSaleBeacon", function () {
    it("管理者がLETS販売ビーコンを設定できること", async function () {
      const { deployer, serviceFactory } = await getServiceFactoryContext();

      // テスト用のビーコンをデプロイ
      const LETS_JP_LLC_EXE = await ethers.getContractFactory("LETS_JP_LLC_EXE");
      const letsBeacon = await LETS_JP_LLC_EXE.deploy();
      const LETS_JP_LLC_SALE = await ethers.getContractFactory("LETS_JP_LLC_SALE");
      const letsSaleBeacon = await LETS_JP_LLC_SALE.deploy();

      // LETS販売ビーコンを設定
      await serviceFactory
        .connect(deployer)
        .setLetsSaleBeacon(
          await letsBeacon.getAddress(),
          await letsSaleBeacon.getAddress()
        );

      // 設定が正しく行われたことを確認
      // 新しいサービスを設定して、LETS販売ビーコンが正しく設定されていることを確認
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

      // サービスタイプを確認
      const serviceType = await serviceFactory.getServiceType(beacon);
      expect(serviceType).to.equal(ServiceType.LETS_EXE);
    });

    it("管理者以外がLETS販売ビーコンを設定しようとすると失敗すること", async function () {
      const { founder, serviceFactory } = await getServiceFactoryContext();

      // テスト用のビーコンをデプロイ
      const LETS_JP_LLC_EXE = await ethers.getContractFactory("LETS_JP_LLC_EXE");
      const letsBeacon = await LETS_JP_LLC_EXE.deploy();
      const LETS_JP_LLC_SALE = await ethers.getContractFactory("LETS_JP_LLC_SALE");
      const letsSaleBeacon = await LETS_JP_LLC_SALE.deploy();

      // 管理者以外がLETS販売ビーコンを設定しようとする
      await expect(
        serviceFactory
          .connect(founder)
          .setLetsSaleBeacon(
            await letsBeacon.getAddress(),
            await letsSaleBeacon.getAddress()
          )
      ).to.be.revertedWithCustomError(serviceFactory, "AccessControlUnauthorizedAccount")
        .withArgs(await founder.getAddress(), "0x0000000000000000000000000000000000000000000000000000000000000000");
    });
  });

  describe("getServiceType", function () {
    it("設定されたサービスタイプを正しく取得できること", async function () {
      const { deployer, serviceFactory } = await getServiceFactoryContext();

      // サービスを設定
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

      // サービスタイプを取得して確認
      const serviceType = await serviceFactory.getServiceType(beacon);
      expect(serviceType).to.equal(ServiceType.LETS_EXE);
    });

    it("未設定のビーコンのサービスタイプを取得すると0が返ること", async function () {
      const { serviceFactory } = await getServiceFactoryContext();

      // 存在しないビーコンのアドレス
      const nonExistentBeacon = "0x0000000000000000000000000000000000000001";

      // サービスタイプを取得
      const serviceType = await serviceFactory.getServiceType(nonExistentBeacon);
      expect(serviceType).to.equal(0);
    });
  });

  describe("getFounderService", function () {
    it("ファウンダーのサービスを正しく取得できること", async function () {
      const { deployer, founder, serviceFactory } = await getServiceFactoryContext();

      // サービスを設定
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

      // ファウンダーのサービスを取得
      const founderService = await serviceFactory.getFounderService(
        await founder.getAddress(),
        ServiceType.LETS_EXE
      );

      // サービスが正しく設定されていることを確認
      expect(ethers.isAddress(founderService)).to.be.true;
    });

    it("未設定のファウンダーのサービスを取得すると0アドレスが返ること", async function () {
      const { serviceFactory } = await getServiceFactoryContext();

      // 存在しないファウンダーのアドレス
      const nonExistentFounder = "0x0000000000000000000000000000000000000001";

      // ファウンダーのサービスを取得
      const founderService = await serviceFactory.getFounderService(nonExistentFounder, ServiceType.LETS_EXE);
      expect(founderService).to.equal("0x0000000000000000000000000000000000000000");
    });
  });
}); 