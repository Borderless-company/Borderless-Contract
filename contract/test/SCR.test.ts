import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { FunctionFragment } from "ethers";
import { Interface } from "ethers";
import type {
  SCR,
  ServiceFactory,
  LETS_JP_LLC_EXE,
  BorderlessAccessControl,
  Dictionary,
  SCRInitialize,
} from "../typechain-types";
import { SCR__factory } from "../typechain-types";

// ヘルパー：関数セレクタ登録
const registerFunctions = async (
  dictionary: Dictionary,
  factory: Awaited<ReturnType<typeof ethers.getContractFactory>>,
  implAddress: string
) => {
  const selectors = [];
  for (const frag of factory.interface.fragments) {
    if (!(frag instanceof FunctionFragment)) continue;
    const selector = FunctionFragment.getSelector(
      frag.name,
      frag.inputs.map((i) => i.type)
    );
    selectors.push(selector);
  }
  const implAddresses = Array(selectors.length).fill(implAddress);
  await dictionary.bulkSetImplementation(selectors, implAddresses);
};

const getBeaconAddress = (receipt: any | null) => {
  const iface = new Interface(SCR__factory.abi);
  let beaconAddress: string | undefined = undefined;

  for (const log of receipt?.logs ?? []) {
    try {
      const parsed = iface.parseLog(log);
      if (parsed?.name === "DeployBeaconProxy") {
        beaconAddress = parsed?.args[0]; // 例: address beacon
        break;
      }
    } catch (e) {
      // 対象外のイベントは無視
    }
  }

  return beaconAddress;
};

const getDeploySmartCompanyAddress = (receipt: any | null) => {
  const iface = new Interface(SCR__factory.abi);
  let beaconAddress: string | undefined = undefined;

  for (const log of receipt?.logs ?? []) {
    try {
      const parsed = iface.parseLog(log);
      if (parsed?.name === "DeploySmartCompany") {
        beaconAddress = parsed?.args[1]; // 例: address beacon
        break;
      }
    } catch (e) {
      // 対象外のイベントは無視
    }
  }

  return beaconAddress;
};

describe("Full Deployment and Registration", function () {
  async function deployFullFixture() {
    // ============================================== //
    //                   アドレスの準備                  //
    // ============================================== //
    const [deployer, founder, executionMember, executionMember2] =
      await ethers.getSigners();

    console.log("🤖 deployer", deployer.address);

    console.log("🤖 founder", founder.address);
    console.log("🤖 executionMember", executionMember.address);
    console.log("🤖 executionMember2", executionMember2.address);

    // Dictionary
    const Dictionary = await ethers.getContractFactory("Dictionary");
    const dictionary = await Dictionary.deploy(deployer.address);
    await dictionary.waitForDeployment();

    // ============================================== //
    //             SCR関連のコントラクトのデプロイ            //
    // ============================================== //
    // 各コントラクト
    const BorderlessAccessControl = await ethers.getContractFactory(
      "BorderlessAccessControl"
    );
    const borderlessAccessControl = await BorderlessAccessControl.deploy();
    await borderlessAccessControl.waitForDeployment();

    console.log(
      "borderlessAccessControl",
      await borderlessAccessControl.getAddress()
    );

    const SCRBeacon = await ethers.getContractFactory("SCRBeaconUpgradeable");
    const scrBeacon = await SCRBeacon.deploy();
    await scrBeacon.waitForDeployment();

    console.log("✅ Deployed scrBeacon", await scrBeacon.getAddress());

    const ServiceFactoryBeacon = await ethers.getContractFactory(
      "ServiceFactoryBeaconUpgradeable"
    );
    const serviceFactoryBeacon = await ServiceFactoryBeacon.deploy();
    await serviceFactoryBeacon.waitForDeployment();

    console.log(
      "✅ Deployed serviceFactoryBeacon",
      await serviceFactoryBeacon.getAddress()
    );

    const ServiceFactory = await ethers.getContractFactory("ServiceFactory");
    const serviceFactory = await ServiceFactory.deploy();
    await serviceFactory.waitForDeployment();

    console.log(
      "✅ Deployed serviceFactory",
      await serviceFactory.getAddress()
    );

    const SCR = await ethers.getContractFactory("SCR");
    const scr = await SCR.deploy();
    await scr.waitForDeployment();

    console.log("✅ Deployed scr", await scr.getAddress());

    const SCRInitialize = await ethers.getContractFactory("SCRInitialize");
    const scrInitialize = await SCRInitialize.deploy();
    await scrInitialize.waitForDeployment();

    console.log("✅ Deployed scrInitialize", await scrInitialize.getAddress());

    // ============================================== //
    //             関数セレクタ登録権限の付与            //
    // ============================================== //

    await dictionary
      .connect(deployer)
      .setOnceInitialized(
        await borderlessAccessControl.getAddress(),
        await borderlessAccessControl.getAddress()
      );

    // ============================================== //
    //                  関数セレクタの登録                //
    // ============================================== //

    // await registerFunctions(
    //   dictionary,
    //   BorderlessAccessControl,
    //   await borderlessAccessControl.getAddress()
    // );

    await registerFunctions(
      dictionary,
      SCRBeacon,
      await scrBeacon.getAddress()
    );
    await registerFunctions(
      dictionary,
      ServiceFactoryBeacon,
      await serviceFactoryBeacon.getAddress()
    );
    await registerFunctions(
      dictionary,
      ServiceFactory,
      await serviceFactory.getAddress()
    );
    await registerFunctions(dictionary, SCR, await scr.getAddress());
    await registerFunctions(
      dictionary,
      SCRInitialize,
      await scrInitialize.getAddress()
    );

    console.log("✅ Registered functions in Dictionary");

    // ============================================== //
    //            BorderlessProxyのデプロイ         //
    // ============================================== //

    // SCRProxy
    const SCRProxy = await ethers.getContractFactory("BorderlessProxy");
    const proxy = await SCRProxy.deploy(dictionary.getAddress(), "0x");
    await proxy.waitForDeployment();

    console.log("✅ Deployed SCRProxy", await proxy.getAddress());

    // initialize
    const initializeConn = (
      await ethers.getContractAt("SCRInitialize", await proxy.getAddress())
    ).connect(deployer) as SCRInitialize;
    await initializeConn.initialize(deployer.address);

    const borderlessAccessControlConn = (
      await ethers.getContractAt(
        "BorderlessAccessControl",
        await borderlessAccessControl.getAddress()
      )
    ).connect(deployer) as BorderlessAccessControl;
    await borderlessAccessControlConn.initialize(dictionary.getAddress());
    console.log("✅ Initialized BorderlessAccessControl");

    // ============================================== //
    //            _JP_DAOLLCコントラクトのデプロイ           //
    // ============================================== //

    // Deploy SCT
    const SCT = await ethers.getContractFactory("SC_JP_DAOLLC");
    const sct = await SCT.deploy();
    await sct.waitForDeployment();

    console.log("✅ Deployed SCT", await sct.getAddress());

    // ============================================== //
    //                    ロールの確認                   //
    // ============================================== //

    // Check Role
    const accessControlConn = (
      await ethers.getContractAt(
        "BorderlessAccessControl",
        await proxy.getAddress()
      )
    ).connect(deployer) as BorderlessAccessControl;
    expect(
      await accessControlConn.hasRole(
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        deployer.address
      )
    ).to.be.true;

    // ============================================== //
    //            JP_DAOLLCコントラクトを設定           //
    // ============================================== //
    // Set SCT
    const scrConn = (
      await ethers.getContractAt("SCR", await proxy.getAddress())
    ).connect(deployer) as SCR;
    const sctBeacon = await scrConn.setSCContract(
      await sct.getAddress(),
      "SC_JP_DAOLLC"
    );
    const receipt = await sctBeacon.wait();
    const sctBeaconAddress = getBeaconAddress(receipt);
    console.log("✅ Set SCT", sctBeaconAddress);

    // ============================================== //
    //              会社情報のフィールドを設定              //
    // ============================================== //

    await scrConn.addCompanyInfoFields("SC_JP_DAOLLC", "zip_code");
    await scrConn.addCompanyInfoFields("SC_JP_DAOLLC", "prefecture");
    await scrConn.addCompanyInfoFields("SC_JP_DAOLLC", "city");
    await scrConn.addCompanyInfoFields("SC_JP_DAOLLC", "address");

    console.log("✅ Set CompanyInfoFields");

    // ============================================== //
    //            Serviceコントラクトのデプロイ              //
    // ============================================== //

    // LETS_JP_LLC_EXE
    const lets_jp_llc_exe = await ethers.getContractFactory("LETS_JP_LLC_EXE");
    const lets_jp_llc_exeContractAddress = await lets_jp_llc_exe.deploy();
    await lets_jp_llc_exeContractAddress.waitForDeployment();

    console.log(
      "✅ Deployed lets_jp_llc_exeContractAddress",
      await lets_jp_llc_exeContractAddress.getAddress()
    );

    // LETS_JP_LLC_NON_EXE
    const lets_jp_llc_non_exe = await ethers.getContractFactory(
      "LETS_JP_LLC_NON_EXE"
    );
    const lets_jp_llc_non_exeContractAddress =
      await lets_jp_llc_non_exe.deploy();
    await lets_jp_llc_non_exeContractAddress.waitForDeployment();
    console.log(
      "✅ Deployed lets_jp_llc_non_exeContractAddress",
      await lets_jp_llc_non_exeContractAddress.getAddress()
    );

    // Governance_JP_LLC
    const governance_jp_llc = await ethers.getContractFactory(
      "Governance_JP_LLC"
    );
    const governance_jp_llcContractAddress = await governance_jp_llc.deploy();
    await governance_jp_llcContractAddress.waitForDeployment();
    console.log(
      "✅ Deployed governance_jp_llcContractAddress",
      await governance_jp_llcContractAddress.getAddress()
    );

    // LETS_JP_LLC_SALE
    const lets_jp_llc_sale = await ethers.getContractFactory(
      "LETS_JP_LLC_SALE"
    );
    const lets_jp_llc_saleContractAddress = await lets_jp_llc_sale.deploy();
    await lets_jp_llc_saleContractAddress.waitForDeployment();
    console.log(
      "✅ Deployed lets_jp_llc_saleContractAddress",
      await lets_jp_llc_saleContractAddress.getAddress()
    );

    // ============================================== //
    //                 FOUNDERロールの設定               //
    // ============================================== //

    // Set Role
    const founderRole =
      "0x7ed687a8f2955bd2ba7ca08227e1e364d132be747f42fb733165f923021b0225";
    await accessControlConn.grantRole(founderRole, founder.address);

    console.log("✅ Set Role");

    // ============================================== //
    //        ServiceFactoryにServiceコントラクトを設定     //
    // ============================================== //

    const serviceFactoryConn = (
      await ethers.getContractAt("ServiceFactory", await proxy.getAddress())
    ).connect(deployer) as ServiceFactory;
    const lets_jp_llc_exeBeacon = await serviceFactoryConn.setService(
      lets_jp_llc_exeContractAddress,
      "LETS_JP_LLC_EXE",
      3
    );
    const lets_jp_llc_exeReceipt = await lets_jp_llc_exeBeacon.wait();
    const lets_jp_llc_exeBeaconAddress = getBeaconAddress(
      lets_jp_llc_exeReceipt
    );
    console.log("✅ Set lets_jp_llc_exeBeacon", lets_jp_llc_exeBeaconAddress);

    const lets_jp_llc_non_exeBeacon = await serviceFactoryConn.setService(
      lets_jp_llc_non_exeContractAddress,
      "LETS_JP_LLC_NON_EXE",
      4
    );
    const lets_jp_llc_non_exeReceipt = await lets_jp_llc_non_exeBeacon.wait();
    const lets_jp_llc_non_exeBeaconAddress = getBeaconAddress(
      lets_jp_llc_non_exeReceipt
    );
    console.log(
      "✅ Set lets_jp_llc_non_exeBeacon",
      lets_jp_llc_non_exeBeaconAddress
    );
    const governance_jp_llcBeacon = await serviceFactoryConn.setService(
      governance_jp_llcContractAddress,
      "Governance_JP_LLC",
      2
    );
    const governance_jp_llcReceipt = await governance_jp_llcBeacon.wait();
    const governance_jp_llcBeaconAddress = getBeaconAddress(
      governance_jp_llcReceipt
    );
    console.log(
      "✅ Set governance_jp_llcBeacon",
      governance_jp_llcBeaconAddress
    );

    const lets_jp_llc_saleBeacon = await serviceFactoryConn.setService(
      lets_jp_llc_saleContractAddress,
      "LETS_JP_LLC_SALE",
      5
    );
    const lets_jp_llc_saleReceipt = await lets_jp_llc_saleBeacon.wait();
    const lets_jp_llc_saleBeaconAddress = getBeaconAddress(
      lets_jp_llc_saleReceipt
    );
    console.log("✅ Set lets_jp_llc_saleBeacon", lets_jp_llc_saleBeaconAddress);

    // ============================================== //
    //            LETSとSaleコントラクトの紐付け             //
    // ============================================== //

    await serviceFactoryConn.setLetsSaleBeacon(
      lets_jp_llc_exeBeaconAddress ?? "",
      lets_jp_llc_saleBeaconAddress ?? ""
    );

    await serviceFactoryConn.setLetsSaleBeacon(
      lets_jp_llc_non_exeBeaconAddress ?? "",
      lets_jp_llc_saleBeaconAddress ?? ""
    );

    return {
      deployer,
      dictionary,
      scr,
      proxy,
      founder,
      executionMember,
      executionMember2,
      serviceFactory,
      sctBeaconAddress: sctBeaconAddress ?? "",
      lets_jp_llc_exeBeaconAddress: lets_jp_llc_exeBeaconAddress ?? "",
      lets_jp_llc_non_exeBeaconAddress: lets_jp_llc_non_exeBeaconAddress ?? "",
      governance_jp_llcBeaconAddress: governance_jp_llcBeaconAddress ?? "",
      lets_jp_llc_saleBeaconAddress: lets_jp_llc_saleBeaconAddress ?? "",
    };
  }

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
    console.log(`selector: ${selector}`);
    console.log(`expected: ${await scr.getAddress()}`);
    console.log(`actual: ${await dictionary.getImplementation(selector)}`);
    expect(await dictionary.getImplementation(selector)).to.equal(
      await scr.getAddress()
    );
  });

  it("createSmartCompany が成功すること", async function () {
    const {
      proxy,
      founder,
      executionMember,
      sctBeaconAddress,
      lets_jp_llc_exeBeaconAddress,
      lets_jp_llc_non_exeBeaconAddress,
      governance_jp_llcBeaconAddress,
      lets_jp_llc_saleBeaconAddress,
    } = await loadFixture(deployFullFixture);

    console.log(`SCTBeaconAddress: ${sctBeaconAddress}`);

    // パラメータの準備
    const scid = 1234567890;
    const legalEntityCode = "SC_JP_DAOLLC";
    const companyName = "Test DAO Company";
    const establishmentDate = "2024-01-01";
    const jurisdiction = "JP";
    const entityType = "LLC";
    const scDeployParam = "0x"; // 空の bytes
    const companyInfo = ["100-0001", "Tokyo", "Shinjuku-ku", "Shinjuku 1-1-1"];
    const scsBeaconProxy = [
      governance_jp_llcBeaconAddress,
      lets_jp_llc_exeBeaconAddress,
      lets_jp_llc_non_exeBeaconAddress,
    ];

    // Forge の encodeParams 相当を実装
    function encodeParams(
      name: string,
      symbol: string,
      baseURI: string,
      extension: string
    ): string {
      return ethers.AbiCoder.defaultAbiCoder().encode(
        ["string", "string", "string", "string"],
        [name, symbol, baseURI, extension]
      );
    }

    const scsExtraParams = [
      "0x",
      encodeParams(
        "LETS_JP_LLC_EXE",
        "LETS_JP_LLC_EXE",
        "https://example.com/metadata/",
        ".json"
      ),
      encodeParams(
        "LETS_JP_LLC_NON_EXE",
        "LETS_JP_LLC_NON_EXE",
        "https://example.com/metadata/",
        ".json"
      ),
    ];

    console.log("✅ prepare params");

    // ============================================== //
    //            createSmartCompany の実行             //
    // ============================================== //
    const scrConn = (
      await ethers.getContractAt("SCR", await proxy.getAddress())
    ).connect(founder) as SCR;
    console.log(`await scrConn.getAddress(): ${await scrConn.getAddress()}`);
    const call = await scrConn.createSmartCompany(
      scid.toString(),
      sctBeaconAddress,
      legalEntityCode,
      companyName,
      establishmentDate,
      jurisdiction,
      entityType,
      scDeployParam,
      companyInfo,
      scsBeaconProxy,
      scsExtraParams
    );
    const receipt = await call.wait();
    console.log(`receipt: ${receipt}`);

    const companyAddress = getDeploySmartCompanyAddress(receipt);
    console.log(`companyAddress: ${companyAddress}`);

    // アサーション
    expect(companyAddress).to.match(/^0x[0-9a-fA-F]{40}$/);
    if (!companyAddress) throw new Error("Company address not found in logs");

    // ============================================== //
    //            SCT プロキシ経由でのアクセス              //
    // ============================================== //
    const sct = (
      await ethers.getContractAt("BorderlessAccessControl", companyAddress)
    ).connect(founder) as BorderlessAccessControl;
    console.log("founder", await founder.getAddress());
    expect(
      await sct.hasRole(
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        await founder.getAddress()
      )
    ).to.be.true;

    console.log("✅ BorderlessAccessControl のロール検証");

    // ============================================== //
    //            LETS_JP_LLC_EXEの残高検証             //
    // ============================================== //

    // EXEサービスの残高検証
    const letsExe = (
      await ethers.getContractAt("LETS_JP_LLC_EXE", companyAddress)
    ).connect(founder) as LETS_JP_LLC_EXE;

    expect(
      await letsExe.balanceOf(await executionMember.getAddress())
    ).to.equal(0);

    console.log("✅ LETS_JP_LLC_EXEの残高検証");

    // ============================================== //
    //            LETS_JP_LLC_EXEのmint を実行             //
    // ============================================== //

    // // mint を実行
    await letsExe.getFunction("mint(address)")(
      await executionMember.getAddress()
    );
    expect(
      await letsExe.balanceOf(await executionMember.getAddress())
    ).to.equal(1);

    console.log("✅ LETS_JP_LLC_EXEのmint を実行");

    // // さらにまとめて mint
    await letsExe.getFunction("mint(address)")(
      await executionMember.getAddress()
    );
    await letsExe.getFunction("mint(address)")(
      await executionMember.getAddress()
    );
    expect(
      await letsExe.balanceOf(await executionMember.getAddress())
    ).to.equal(3);

    console.log("✅ LETS_JP_LLC_EXEのmint をさらに実行");
  });
});
