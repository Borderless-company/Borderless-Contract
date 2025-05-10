import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { FunctionFragment } from "ethers";
import { Interface } from "ethers";
import type {
  SCR,
  ServiceFactory,
  LETSBase,
  SCT,
  LETS_JP_LLC_EXE,
  BorderlessAccessControl,
  Initialize,
} from "../typechain-types";
import { SCR__factory } from "../typechain-types";

describe("Full Deployment and Registration", function () {
  async function deployFullFixture() {
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

    const AddressManager = await ethers.getContractFactory("AddressManager");
    const addressManager = await AddressManager.deploy();
    await addressManager.waitForDeployment();

    console.log(
      "✅ Deployed addressManager",
      await addressManager.getAddress()
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

    const InitializeContract = await ethers.getContractFactory("Initialize");
    const initializeContract = await InitializeContract.deploy();
    await initializeContract.waitForDeployment();

    console.log(
      "✅ Deployed initializeContract",
      await initializeContract.getAddress()
    );

    // ヘルパー：関数セレクタ登録
    async function registerFunctions(
      factory: Awaited<ReturnType<typeof ethers.getContractFactory>>,
      implAddress: string
    ) {
      for (const frag of factory.interface.fragments) {
        if (!(frag instanceof FunctionFragment)) continue;
        const selector = FunctionFragment.getSelector(
          frag.name,
          frag.inputs.map((i) => i.type)
        );
        await dictionary.setImplementation(selector, implAddress);
      }
    }

    await registerFunctions(
      BorderlessAccessControl,
      await borderlessAccessControl.getAddress()
    );
    await registerFunctions(AddressManager, await addressManager.getAddress());
    await registerFunctions(SCRBeacon, await scrBeacon.getAddress());
    await registerFunctions(
      ServiceFactoryBeacon,
      await serviceFactoryBeacon.getAddress()
    );
    await registerFunctions(ServiceFactory, await serviceFactory.getAddress());
    await registerFunctions(SCR, await scr.getAddress());
    await registerFunctions(
      InitializeContract,
      await initializeContract.getAddress()
    );

    console.log("✅ Registered functions in Dictionary");

    // SCRProxy
    const SCRProxy = await ethers.getContractFactory("SCRProxy");
    const proxy = await SCRProxy.deploy(dictionary.getAddress(), "0x");
    await proxy.waitForDeployment();

    console.log("✅ Deployed SCRProxy", await proxy.getAddress());

    // initialize
    const initializeConn = (
      await ethers.getContractAt("Initialize", await proxy.getAddress())
    ).connect(deployer) as Initialize;
    await initializeConn.initialize(deployer.address);

    // Deploy SCT
    const SCT = await ethers.getContractFactory("SC_JP_DAOLLC");
    const sct = await SCT.deploy();
    await sct.waitForDeployment();

    console.log("✅ Deployed SCT", await sct.getAddress());

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

    // get beacon address

    function getBeaconAddress(receipt: any | null) {
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
    }

    // Set SCT
    const scrConn = (
      await ethers.getContractAt("SCR", await proxy.getAddress())
    ).connect(deployer) as SCR;
    const sctBeacon = await scrConn.setSCContract(
      await sct.getAddress(),
      "SC_JP_DAOLLC"
    );
    const receipt = await sctBeacon.wait();
    const iface = new Interface(SCR__factory.abi);
    const sctBeaconAddress = getBeaconAddress(receipt);
    console.log("✅ Set SCT", sctBeaconAddress);

    await scrConn.addCompanyInfoFields("SC_JP_DAOLLC", "zip_code");
    await scrConn.addCompanyInfoFields("SC_JP_DAOLLC", "prefecture");
    await scrConn.addCompanyInfoFields("SC_JP_DAOLLC", "city");
    await scrConn.addCompanyInfoFields("SC_JP_DAOLLC", "address");

    console.log("✅ Set CompanyInfoFields");

    // Deploy Services

    const lets_jp_llc_exe = await ethers.getContractFactory("LETS_JP_LLC_EXE");
    const lets_jp_llc_exeContractAddress = await lets_jp_llc_exe.deploy();
    await lets_jp_llc_exeContractAddress.waitForDeployment();

    console.log(
      "✅ Deployed lets_jp_llc_exeContractAddress",
      await lets_jp_llc_exeContractAddress.getAddress()
    );

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

    const governance_jp_llc =
      await ethers.getContractFactory("Governance_JP_LLC");
    const governance_jp_llcContractAddress = await governance_jp_llc.deploy();
    await governance_jp_llcContractAddress.waitForDeployment();
    console.log(
      "✅ Deployed governance_jp_llcContractAddress",
      await governance_jp_llcContractAddress.getAddress()
    );

    const lets_jp_llc_sale = await ethers.getContractFactory("LETS_JP_LLC_SALE");
    const lets_jp_llc_saleContractAddress = await lets_jp_llc_sale.deploy();
    await lets_jp_llc_saleContractAddress.waitForDeployment();
    console.log(
      "✅ Deployed lets_jp_llc_saleContractAddress",
      await lets_jp_llc_saleContractAddress.getAddress()
    );

    // Set Role
    const founderRole =
      "0x7ed687a8f2955bd2ba7ca08227e1e364d132be747f42fb733165f923021b0225";
    await accessControlConn.grantRole(founderRole, founder.address);

    console.log("✅ Set Role");

    // set Service
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
      lets_jp_llc_saleBeaconAddress,
      lets_jp_llc_saleBeaconAddress,
      lets_jp_llc_exeBeaconAddress,
      lets_jp_llc_non_exeBeaconAddress,
    ];

    // Common から持ってくる各サービスの実装アドレス
    const serviceFactoryContract = await ethers.getContractAt(
      "ServiceFactory",
      await proxy.getAddress()
    );

    // Forge の encodeParams 相当を実装
    function encodeParams(
      name: string,
      symbol: string,
      baseURI: string,
      extension: string,
      letsSale: string,
      governance: string
    ): string {
      return ethers.AbiCoder.defaultAbiCoder().encode(
        ["string", "string", "string", "string", "address", "address"],
        [name, symbol, baseURI, extension, letsSale, governance]
      );
    }

    const scsExtraParams = [
      "0x",
      "0x",
      "0x",
      encodeParams(
        "LETS_JP_LLC_EXE",
        "LETS_JP_LLC_EXE",
        "https://example.com/metadata/",
        ".json",
        lets_jp_llc_saleBeaconAddress,
        governance_jp_llcBeaconAddress
      ),
      encodeParams(
        "LETS_JP_LLC_NON_EXE",
        "LETS_JP_LLC_NON_EXE",
        "https://example.com/metadata/",
        ".json",
        lets_jp_llc_saleBeaconAddress,
        governance_jp_llcBeaconAddress
      ),
    ];

    console.log("✅ prepare params");

    // コントラクト呼び出し（founder プリテンド）
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
    function getBeaconAddress(receipt: any | null) {
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
    }

    const companyAddress = getBeaconAddress(receipt);
    console.log(`companyAddress: ${companyAddress}`);

    // アサーション
    expect(companyAddress).to.match(/^0x[0-9a-fA-F]{40}$/);
    if (!companyAddress) throw new Error("Company address not found in logs");

    console.log(`companyAddress: ${companyAddress}`);

    // SCT プロキシ経由でのアクセス
    const sct = (await ethers.getContractAt("SCT", companyAddress)).connect(
      founder
    ) as SCT;
    console.log("founder", await founder.getAddress());
    expect(
      await sct.hasRole(
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        await founder.getAddress()
      )
    ).to.be.true;

    // EXEサービスの残高検証
    // const exeService = (await serviceFactoryContract.getFounderService(
    //   founder.address,
    //   3
    // )) as string;
    // const letsExe = (
    //   await ethers.getContractAt("LETSBase", exeService)
    // ).connect(founder) as LETSBase;

    // expect(await letsExe.balanceOf(await executionMember.getAddress())).to.equal(0);

    // // mint を実行
    // await letsExe.getFunction("mint(address)")(await executionMember.getAddress());
    // expect(await letsExe.balanceOf(await executionMember.getAddress())).to.equal(1);

    // // さらにまとめて mint
    // await letsExe.getFunction("mint(address)")(await executionMember.getAddress());
    // await letsExe.getFunction("mint(address)")(await executionMember.getAddress());
    // expect(await letsExe.balanceOf(await executionMember.getAddress())).to.equal(3);
  });
});
