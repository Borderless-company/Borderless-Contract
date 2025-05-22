import hre from "hardhat";
import dotenv from "dotenv";
import { FunctionFragment } from "ethers";
import {
  BorderlessModule,
  InitializeModule,
  BorderlessAccessControlInitializeModule,
  RegisterSCTModule,
  RegisterGovernanceServiceModule,
  RegisterLetsServiceModule,
  RegisterLetsNonExeServiceModule,
  RegisterLetsSaleServiceModule,
  CreateSmartCompanyModule,
} from "../ignition/modules/Borderless";

dotenv.config();

const getDeployerAddress = async () => {
  const deployerWallet = new hre.ethers.Wallet(
    process.env.DEPLOYER_PRIVATE_KEY!,
    hre.ethers.provider
  );
  const deployer =
    (await deployerWallet.getAddress()) ||
    "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
  return { deployer, deployerWallet };
};

const registerFunctions = async (name: string, implAddress: string) => {
  const factory = await hre.ethers.getContractFactory(name);
  const selectors = [];
  const implementations = [];
  for (const frag of factory.interface.fragments) {
    if (!(frag instanceof FunctionFragment)) continue;
    const selector = FunctionFragment.getSelector(
      frag.name,
      frag.inputs.map((i) => i.type)
    );
    selectors.push(selector);
    implementations.push(implAddress);
  }
  return { selectors, implementations };
};

const delay = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

async function main() {
  const { deployer, deployerWallet } = await getDeployerAddress();
  console.log(`deployer: ${deployer}`);

  const parameters = {
    BorderlessModule: { Deployer: deployer },
    InitializeModule: { Deployer: deployer },
  };

  const {
    accessControlFacet,
    scrBeaconFacet,
    sfBeaconFacet,
    serviceFactoryFacet,
    scrInitializeFacet,
    scrFacet,
    dictionary,
    proxy,
    sct,
    governance_jp_llc,
    lets_jp_llc_exe,
    lets_jp_llc_non_exe,
    lets_jp_llc_sale,
  } = await hre.ignition.deploy(BorderlessModule, {
    parameters: parameters,
  });

  console.log(`✅ Done deploy BorderlessModule`);
  await delay(10000); // 10秒待機

  // ────────────────────────────────────────────────
  // 関数セレクタ登録権限の付与
  // ────────────────────────────────────────────────

  const dictionaryConn = await hre.ethers.getContractAt(
    "Dictionary",
    dictionary.target ?? ""
  );
  await dictionaryConn
    .connect(deployerWallet)
    .setOnceInitialized(
      await accessControlFacet.getAddress(),
      await accessControlFacet.getAddress()
    );

  console.log("✅ Done setOnceInitialized");

  // ────────────────────────────────────────────────
  // Register all Facets in Dictionary
  // ────────────────────────────────────────────────

  await delay(10000); // 10秒待機

  const {
    selectors: scrBeaconSelectors,
    implementations: scrBeaconImplementations,
  } = await registerFunctions(
    "SCRBeaconUpgradeable",
    await scrBeaconFacet.getAddress()
  );

  const {
    selectors: sfBeaconSelectors,
    implementations: sfBeaconImplementations,
  } = await registerFunctions(
    "ServiceFactoryBeaconUpgradeable",
    await sfBeaconFacet.getAddress()
  );

  const {
    selectors: serviceFactorySelectors,
    implementations: serviceFactoryImplementations,
  } = await registerFunctions(
    "ServiceFactory",
    await serviceFactoryFacet.getAddress()
  );

  const {
    selectors: scrInitializeSelectors,
    implementations: scrInitializeImplementations,
  } = await registerFunctions(
    "SCRInitialize",
    await scrInitializeFacet.getAddress()
  );

  const { selectors: scrSelectors, implementations: scrImplementations } =
    await registerFunctions("SCR", await scrFacet.getAddress());

  const receipt = await dictionary.bulkSetImplementation(
    [
      ...scrBeaconSelectors,
      ...sfBeaconSelectors,
      ...serviceFactorySelectors,
      ...scrInitializeSelectors,
      ...scrSelectors,
    ],
    [
      ...scrBeaconImplementations,
      ...sfBeaconImplementations,
      ...serviceFactoryImplementations,
      ...scrInitializeImplementations,
      ...scrImplementations,
    ]
  );
  await receipt.wait();

  console.log("✅ Done register functions");

  // ────────────────────────────────────────────────
  // initializer を実行
  // ────────────────────────────────────────────────
  await delay(10000); // 10秒待機
  // SCRInitialize
  await hre.ignition.deploy(InitializeModule, {
    parameters: parameters,
  });

  await delay(10000); // 10秒待機

  // BorderlessAccessControlInitialize
  await hre.ignition.deploy(BorderlessAccessControlInitializeModule, {
    parameters: parameters,
  });

  console.log(`✅ Done initialize`);

  // ────────────────────────────────────────────────
  // SCTを登録
  // ────────────────────────────────────────────────
  await delay(10000); // 10秒待機
  const sctAddress = await sct.getAddress();
  console.log(`sctAddress: ${sctAddress}`);
  const { sctBeaconConn } = await hre.ignition.deploy(RegisterSCTModule, {
    parameters: {
      ...parameters,
    },
  });

  console.log(`✅ Done set SCT`, sctBeaconConn.target);

  // ============================================== //
  //              会社情報のフィールドを設定              //
  // ────────────────────────────────────────────────

  await delay(10000); // 10秒待機

  const scrConn = await hre.ethers.getContractAt("SCR", proxy.target ?? "");
  await scrConn.addCompanyInfoFields("SC_JP_DAOLLC", "zip_code");
  await scrConn.addCompanyInfoFields("SC_JP_DAOLLC", "prefecture");
  await scrConn.addCompanyInfoFields("SC_JP_DAOLLC", "city");
  await scrConn.addCompanyInfoFields("SC_JP_DAOLLC", "address");

  console.log("✅ Set CompanyInfoFields");

  // ────────────────────────────────────────────────
  // Serviceを登録
  // ────────────────────────────────────────────────
  await delay(10000); // 10秒待機
  // Governance_JP_LLC
  const { serviceBeaconConn: governanceBeacon } = await hre.ignition.deploy(
    RegisterGovernanceServiceModule,
    {
      parameters: {
        ...parameters,
        RegisterGovernanceServiceModule: {
          ServiceName: "Governance_JP_LLC",
          ServiceType: 2,
        },
      },
    }
  );

  await delay(10000); // 10秒待機

  // LETS_JP_LLC_EXE
  const { serviceBeaconConn: lets_jp_llc_exeBeacon } =
    await hre.ignition.deploy(RegisterLetsServiceModule, {
      parameters: {
        ...parameters,
        RegisterLetsServiceModule: {
          ServiceName: "LETS_JP_LLC_EXE",
          ServiceType: 3,
        },
      },
    });

  await delay(10000); // 10秒待機

  // LETS_JP_LLC_NON_EXE
  const { serviceBeaconConn: lets_jp_llc_non_exeBeacon } =
    await hre.ignition.deploy(RegisterLetsNonExeServiceModule, {
      parameters: {
        ...parameters,
        RegisterLetsNonExeServiceModule: {
          ServiceName: "LETS_JP_LLC_NON_EXE",
          ServiceType: 4,
        },
      },
    });

  await delay(10000); // 10秒待機

  // LETS_JP_LLC_SALE
  const { serviceBeaconConn: lets_jp_llc_saleBeacon } =
    await hre.ignition.deploy(RegisterLetsSaleServiceModule, {
      parameters: {
        ...parameters,
        RegisterLetsSaleServiceModule: {
          ServiceName: "LETS_JP_LLC_SALE",
          ServiceType: 5,
        },
      },
    });

  console.log(`✅ Done set Service`);

  // ────────────────────────────────────────────────
  // LETSとSaleコントラクトの紐付け
  // ────────────────────────────────────────────────
  await delay(10000); // 10秒待機
  const serviceFactoryConn = await hre.ethers.getContractAt(
    "ServiceFactory",
    proxy
  );
  await serviceFactoryConn.setLetsSaleBeacon(
    lets_jp_llc_exeBeacon.target ?? "",
    lets_jp_llc_saleBeacon.target ?? ""
  );
  await serviceFactoryConn.setLetsSaleBeacon(
    lets_jp_llc_non_exeBeacon.target ?? "",
    lets_jp_llc_saleBeacon.target ?? ""
  );

  // ────────────────────────────────────────────────
  // ログに出力
  // ────────────────────────────────────────────────

  console.table({
    proxy: await proxy.getAddress(),
    dictionary: await dictionary.getAddress(),
    sct: await sct.getAddress(),
    sctBeacon: await sctBeaconConn.getAddress(),
    governanceBeacon: await governanceBeacon.getAddress(),
    lets_jp_llc_exeBeacon: await lets_jp_llc_exeBeacon.getAddress(),
    lets_jp_llc_non_exeBeacon: await lets_jp_llc_non_exeBeacon.getAddress(),
    lets_jp_llc_saleBeacon: await lets_jp_llc_saleBeacon.getAddress(),
  });

  // ────────────────────────────────────────────────
  // FOUNDERロールの設定
  // ────────────────────────────────────────────────

  await delay(10000); // 10秒待機

  // Set Role
  const founderRole =
    "0x7ed687a8f2955bd2ba7ca08227e1e364d132be747f42fb733165f923021b0225";
  const accessControlConn = await hre.ethers.getContractAt(
    "BorderlessAccessControl",
    proxy.target ?? ""
  );
  await accessControlConn.grantRole(founderRole, deployer);

  console.log("✅ Set Role");

  // ────────────────────────────────────────────────
  // createSmartCompany の実行
  // ────────────────────────────────────────────────

  await delay(10000); // 10秒待機

  function encodeParams(
    name: string,
    symbol: string,
    baseURI: string,
    extension: string
  ): string {
    return hre.ethers.AbiCoder.defaultAbiCoder().encode(
      ["string", "string", "string", "string"],
      [name, symbol, baseURI, extension]
    );
  }

  const scsExtraParams = [
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

  const { scProxyConn } = await hre.ignition.deploy(CreateSmartCompanyModule, {
    parameters: {
      ...parameters,
      CreateSmartCompanyModule: {
        SCTBeaconAddress: await sctBeaconConn.getAddress(),
        GovernanceBeaconAddress: await governanceBeacon.getAddress(),
        LetsJpLlCExeBeaconAddress: await lets_jp_llc_exeBeacon.getAddress(),
        LetsJpLlCNonExeBeaconAddress:
          await lets_jp_llc_non_exeBeacon.getAddress(),
        LetsJpLlCExeParams: scsExtraParams[0],
        LetsJpLlCNonExeParams: scsExtraParams[1],
      },
    },
  });
  console.log(`scProxyConn: ${scProxyConn.target}`);

  // ────────────────────────────────────────────────
  // LETS_JP_LLC_EXEのmintを実行
  // ────────────────────────────────────────────────
  await delay(10000); // 10秒待機

  const executionMember = await hre.ethers.getSigner(
    "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"
  );

  const lets_jp_llc_exeConn = await hre.ethers.getContractAt(
    "LETS_JP_LLC_EXE",
    scProxyConn.target ?? ""
  );
  await lets_jp_llc_exeConn.initialMint([deployer, executionMember]);
  const deployerBalance = await lets_jp_llc_exeConn.balanceOf(deployer);
  console.log(`deployerBalance: ${deployerBalance}`);
  const executionMemberBalance = await lets_jp_llc_exeConn.balanceOf(
    executionMember
  );
  console.log(`executionMemberBalance: ${executionMemberBalance}`);

  // ============================================== //
  //                Saleコントラクトの設定               //
  // ============================================== //

  await delay(10000); // 10秒待機

  const executionMember2 = await hre.ethers.getSigner(
    "0x90F79bf6EB2c4f870365E785982E1f101E93b906"
  );

  // Saleコントラクトの設定
  const letsSaleConn = await hre.ethers.getContractAt(
    "LETS_JP_LLC_SALE",
    scProxyConn.target ?? ""
  );

  // Saleコントラクトの設定
  await letsSaleConn.getFunction(
    "setSaleInfo(uint256,uint256,uint256,uint256,uint256)"
  )(
    0,
    0,
    hre.ethers.parseEther("0.1"), // 1 ETH
    0,
    0
  );

  await letsSaleConn
    .connect(executionMember2)
    .getFunction("offerToken(address)")(
    executionMember2,
    { value: hre.ethers.parseEther("0.1") } // 1 ETHを送付
  );

  const executionMember2Balance = await lets_jp_llc_exeConn.balanceOf(
    executionMember2
  );
  console.log(`executionMember2Balance: ${executionMember2Balance}`);

  console.log("✅ Saleコントラクトの設定");
}

main().catch(console.error);
