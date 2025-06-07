import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import type { SCT } from "../typechain-types";
import { ServiceType } from "./utils/Enum";

// テストユーティリティを必要に応じてインポート
import { deployFullFixture } from "./utils/DeployFixture";
import { grantFounderRole } from "./utils/Role";
import { createCompany } from "./utils/CreateCompany";

describe("SCT Service", function () {
  // --- フィクスチャを使ったコンテキスト構築関数 ---
  const getSCTContext = async () => {
    // 1) サインイン用アカウント取得
    const [deployer, founder, user1, user2] = await ethers.getSigners();

    // 2) deployFullFixture を呼び出してコントラクトをデプロイ・初期化
    const {
      proxy,     // BorderlessProxyのインスタンス
      scr,       // SCRのインスタンス
      serviceFactory, // ServiceFactoryのインスタンス
    } = await loadFixture(deployFullFixture);

    // 3) メインコントラクトのインスタンス化（proxy経由）
    const sct = (await ethers.getContractAt(
      "SCT",
      await proxy.getAddress()
    )) as SCT;

    return {
      deployer,
      founder,
      user1,
      user2,
      proxy,
      scr,
      serviceFactory,
      sct
    };
  };

  describe("Service Registration", function () {
    it("should register services by founder", async function () {
      const { sct, founder, user1, proxy, deployer } = await getSCTContext();
      
      // サービスアドレスをモック
      const mockServiceAddress = user1.address;
      const serviceTypes = [ServiceType.LETS_EXE];
      const services = [mockServiceAddress];

      // founderにロールを付与
      await grantFounderRole(deployer, proxy, founder);

      // サービス登録
      await expect(sct.connect(founder).registerService(serviceTypes, services))
        .to.emit(sct, "RegisterService")
        .withArgs(await sct.getAddress(), serviceTypes, services);

      // 登録されたサービスアドレスを確認
      const registeredService = await sct.getService(ServiceType.LETS_EXE);
      expect(registeredService).to.equal(mockServiceAddress);
    });

    it("should register services by SCR", async function () {
      const { sct, scr, user1 } = await getSCTContext();
      
      const mockServiceAddress = user1.address;
      const serviceTypes = [ServiceType.LETS_EXE];
      const services = [mockServiceAddress];

      // SCRからサービス登録
      await expect(sct.connect(scr).registerService(serviceTypes, services))
        .to.emit(sct, "RegisterService")
        .withArgs(await sct.getAddress(), serviceTypes, services);

      // 登録されたサービスアドレスを確認
      const registeredService = await sct.getService(ServiceType.LETS_EXE);
      expect(registeredService).to.equal(mockServiceAddress);
    });

    it("should fail to register services by unauthorized user", async function () {
      const { sct, user1, user2 } = await getSCTContext();
      
      const mockServiceAddress = user1.address;
      const serviceTypes = [ServiceType.LETS_EXE];
      const services = [mockServiceAddress];

      // 未認証ユーザーからのサービス登録を試みる
      await expect(
        sct.connect(user2).registerService(serviceTypes, services)
      ).to.be.revertedWithCustomError(sct, "NotFounderOrSCR");
    });

    it("should fail to register service with zero address", async function () {
      const { sct, founder, proxy, deployer } = await getSCTContext();
      
      const zeroAddress = ethers.ZeroAddress;
      const serviceTypes = [ServiceType.LETS_EXE];
      const services = [zeroAddress];

      // founderにロールを付与
      await grantFounderRole(deployer, proxy, founder);

      // ゼロアドレスでのサービス登録を試みる
      await expect(
        sct.connect(founder).registerService(serviceTypes, services)
      ).to.be.revertedWithCustomError(sct, "InvalidAddress");
    });
  });

  describe("Investment Amount Management", function () {
    it("should set investment amount by treasury role", async function () {
      const { sct, deployer, user1, proxy } = await getSCTContext();
      
      const investmentAmount = ethers.parseEther("1.0");

      // deployerにTREASURY_ROLEを付与
      await grantFounderRole(deployer, proxy, deployer);

      // 投資額を設定
      await sct.connect(deployer).setInvestmentAmount(user1.address, investmentAmount);

      // 設定された投資額を確認
      const amount = await sct.getInvestmentAmount(user1.address);
      expect(amount).to.equal(investmentAmount);
    });

    it("should fail to set investment amount by unauthorized user", async function () {
      const { sct, user1, user2 } = await getSCTContext();
      
      const investmentAmount = ethers.parseEther("1.0");

      // 未認証ユーザーからの投資額設定を試みる
      await expect(
        sct.connect(user2).setInvestmentAmount(user1.address, investmentAmount)
      ).to.be.revertedWithCustomError(sct, "NotAuthorized");
    });
  });

  describe("Information Retrieval", function () {
    it("should return correct SCR address", async function () {
      const { sct, scr } = await getSCTContext();
      
      const scrAddress = await sct.getSCR();
      expect(scrAddress).to.equal(await scr.getAddress());
    });

    it("should return zero address for unregistered service", async function () {
      const { sct } = await getSCTContext();
      
      const serviceAddress = await sct.getService(ServiceType.LETS_EXE);
      expect(serviceAddress).to.equal(ethers.ZeroAddress);
    });

    it("should return zero for unset investment amount", async function () {
      const { sct, user1 } = await getSCTContext();
      
      const amount = await sct.getInvestmentAmount(user1.address);
      expect(amount).to.equal(0);
    });
  });
}); 