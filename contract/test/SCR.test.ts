import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { FunctionFragment } from "ethers";
import type {
  SCR,
  ServiceFactory,
  LETS_JP_LLC_EXE,
  BorderlessAccessControl,
  LETS_JP_LLC_SALE,
  LETS_JP_LLC_NON_EXE,
} from "../typechain-types";
import { getDeploySmartCompanyAddress } from "./utils/Event";
import { deployFullFixture } from "./utils/DeployFixture";
import { letsEncodeParams } from "../utils/Encode";
import { createCompany } from "./utils/CreateCompany";

describe("SCR Test", function () {
  it("Dictionary のオーナーがデプロイヤーに設定されていること", async function () {
    const { deployer, dictionary } = await loadFixture(deployFullFixture);
    expect(await dictionary.owner()).to.equal(deployer.address);
  });

  it("SCRProxy が正常にデプロイされていること", async function () {
    const { proxy } = await loadFixture(deployFullFixture);
    expect(ethers.isAddress(await proxy.getAddress())).to.be.true;
  });

  it("Dictionary に SCT の getService 関数セレクタが登録されていること", async function () {
    const { dictionary, scr } = await loadFixture(deployFullFixture);
    const SCR = await ethers.getContractFactory("SCR");
    const frag = SCR.interface.getFunction("setSCContract")!;
    const selector = FunctionFragment.getSelector(
      frag.name,
      frag.inputs.map((i) => i.type)
    );
    expect(await dictionary.getImplementation(selector)).to.equal(
      await scr.getAddress()
    );
  });

  it("createSmartCompany が成功すること", async function () {
    const {
      deployer,
      proxy,
      founder,
      executiveMember,
      executiveMember2,
      executiveMember3,
      tokenMinter,
    } = await loadFixture(deployFullFixture);

    // ============================================== //
    // createSmartCompany の実行
    // ============================================== //

    const { companyAddress, services } = await createCompany();

    // ============================================== //
    // ロールの検証
    // ============================================== //

    const sct = (
      await ethers.getContractAt("BorderlessAccessControl", companyAddress)
    ).connect(founder) as BorderlessAccessControl;
    expect(
      await sct.hasRole(
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        await founder.getAddress()
      )
    ).to.be.true;

    console.log("✅ BorderlessAccessControl のロール検証");

    // ============================================== //
    // ServiceFactoryからLETSを取得
    // ============================================== //

    const serviceFactoryConn = (
      await ethers.getContractAt("ServiceFactory", await proxy.getAddress())
    ).connect(founder) as ServiceFactory;

    const letsExeAddress = await serviceFactoryConn.getFounderService(
      founder,
      3
    );

    const letsNonExeAddress = await serviceFactoryConn.getFounderService(
      founder,
      4
    );

    console.log("✅ ServiceFactoryからLETSを取得");

    // イベントからLETS_JP_LLC_EXEとLETS_JP_LLC_NON_EXEのアドレスを取得
    const letsExe = (
      await ethers.getContractAt("LETS_JP_LLC_EXE", services[2])
    ).connect(founder) as LETS_JP_LLC_EXE;

    const letsNonExe = (
      await ethers.getContractAt("LETS_JP_LLC_NON_EXE", services[4])
    ).connect(founder) as LETS_JP_LLC_NON_EXE;

    expect(await letsExe.getAddress()).to.equal(letsExeAddress);
    expect(await letsNonExe.getAddress()).to.equal(letsNonExeAddress);
    console.log("✅ LETS_JP_LLC_EXEとLETS_JP_LLC_NON_EXEのアドレスを取得");

    // ============================================== //
    // LETS_JP_LLC_EXEのinitialMintを実行
    // ============================================== //

    // initialMint を実行
    await letsExe.connect(founder).getFunction("initialMint(address[])")([
      await executiveMember.getAddress(),
      await executiveMember2.getAddress(),
    ]);

    // 残高確認
    expect(
      await letsExe.balanceOf(await executiveMember.getAddress())
    ).to.equal(1);
    expect(
      await letsExe.balanceOf(await executiveMember2.getAddress())
    ).to.equal(1);

    console.log("✅ LETS_JP_LLC_EXEのinitialMintを実行");

    // ============================================== //
    //    MINTER_ROLEからLETS_JP_LLC_EXEのmintを実行     //
    // ============================================== //

    // minter roleの付与
    const scrAccessControlConn = (
      await ethers.getContractAt(
        "BorderlessAccessControl",
        await proxy.getAddress()
      )
    ).connect(deployer) as BorderlessAccessControl;

    const MINTER_ROLE =
      "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6";
    await scrAccessControlConn.grantRole(MINTER_ROLE, tokenMinter);

    // mint を実行
    await letsExe.connect(tokenMinter).getFunction("mint(address)")(
      await tokenMinter.getAddress()
    );
    expect(await letsExe.balanceOf(await tokenMinter.getAddress())).to.equal(1);

    console.log("✅ MINTER_ROLEからLETS_JP_LLC_EXEのmintを実行");

    // ============================================== //
    //    MINTER_ROLEからLETS_JP_LLC_EXEのmintを実行     //
    // ============================================== //

    // mint を実行
    await letsNonExe.connect(tokenMinter).getFunction("mint(address)")(
      await tokenMinter.getAddress()
    );
    expect(await letsNonExe.balanceOf(await tokenMinter.getAddress())).to.equal(
      1
    );

    console.log("✅ MINTER_ROLEからLETS_JP_LLC_NON_EXEのmintを実行");

    // ============================================== //
    // Saleコントラクトの設定
    // ============================================== //

    // saleコントラクトのアドレスを取得
    const letsExeSale = (
      await ethers.getContractAt("LETS_JP_LLC_SALE", services[2])
    ).connect(founder) as LETS_JP_LLC_SALE;

    // saleコントラクトの販売情報設定
    await letsExeSale
      .connect(founder)
      .getFunction("setSaleInfo(uint256,uint256,uint256,uint256,uint256)")(
      0,
      0,
      ethers.parseEther("0.1"),
      0,
      0
    );

    // 購入
    await letsExeSale
      .connect(executiveMember3)
      .getFunction("offerToken(address)")(
      await executiveMember3.getAddress(),
      { value: ethers.parseEther("0.1") } // 0.1 ETHを送付
    );

    // 残高確認
    expect(
      await letsExe.balanceOf(await executiveMember3.getAddress())
    ).to.equal(1);

    console.log("✅ SaleコントラクトからLETS_JP_LLC_EXEを購入");

    // ============================================== //
    // LETS_JP_LLC_NON_EXEの購入
    // ============================================== //

    expect(await letsNonExe.getAddress()).to.equal(letsNonExeAddress);

    // saleコントラクトのアドレスを取得
    const letsNonExeSale = (
      await ethers.getContractAt("LETS_JP_LLC_SALE", services[4])
    ).connect(founder) as LETS_JP_LLC_SALE;

    // saleコントラクトの販売情報設定
    await letsNonExeSale
      .connect(founder)
      .getFunction("setSaleInfo(uint256,uint256,uint256,uint256,uint256)")(
      0,
      0,
      ethers.parseEther("0.01"),
      0,
      0
    );

    // 購入
    await letsNonExeSale
      .connect(executiveMember3)
      .getFunction("offerToken(address)")(
      await executiveMember3.getAddress(),
      { value: ethers.parseEther("0.01") } // 0.1 ETHを送付
    );

    // 残高確認
    expect(
      await letsNonExe.balanceOf(await executiveMember3.getAddress())
    ).to.equal(1);

    console.log("✅ LETS_JP_LLC_NON_EXEの購入");
  });
});
