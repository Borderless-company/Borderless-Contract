import hre from "hardhat";
import dotenv from "dotenv";
import {
  BorderlessModule,
  InitializeModule,
  BorderlessAccessControlInitializeModule,
  RegisterSCTModule,
  RegisterGovernanceServiceModule,
  RegisterLetsServiceModule,
  RegisterLetsNonExeServiceModule,
  RegisterLetsSaleServiceModule,
  DictionaryInitializeModule,
} from "../ignition/modules/Borderless";
import { parseDeployArgs } from "./utils/parseArgs";
import {
  getDeployerAddress,
  getFounderAddresses,
  getAdminAddresses,
} from "./utils/Deployer";
import { registerAllFacets } from "./utils/DictionaryHelper";
import { delay } from "./utils/Delay";

dotenv.config();

const { delayMs } = parseDeployArgs();

export default async function main() {
  const { deployer, deployerWallet } = await getDeployerAddress();
  console.log(`deployer: ${deployer}`);
  const adminAddresses = [...(await getAdminAddresses()), deployer];
  const founderAddresses = [...(await getFounderAddresses()), deployer];

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
    dictionaryInitializeFacet,
    proxy,
    sct,
  } = await hre.ignition.deploy(BorderlessModule, {
    parameters: parameters,
  });

  console.log(`✅ Done deploy BorderlessModule`);

  // ────────────────────────────────────────────────
  // 関数セレクタ登録権限の付与
  // ────────────────────────────────────────────────

  const dictionaryConn = await hre.ethers.getContractAt(
    "Dictionary",
    dictionary.target ?? ""
  );

  await delay(delayMs);

  await dictionaryConn
    .connect(deployerWallet)
    .setOnceInitialized(
      await accessControlFacet.getAddress(),
      await accessControlFacet.getAddress()
    );

  await delay(delayMs);

  await dictionaryConn
    .connect(deployerWallet)
    .setOnceInitialized(
      await dictionaryInitializeFacet.getAddress(),
      await dictionary.getAddress()
    );

  console.log("✅ Done setOnceInitialized");

  // ────────────────────────────────────────────────
  // Register all Facets in Dictionary
  // ────────────────────────────────────────────────

  await delay(delayMs);

  await registerAllFacets(
    dictionary,
    scrBeaconFacet,
    sfBeaconFacet,
    serviceFactoryFacet,
    scrInitializeFacet,
    scrFacet
  );

  // ────────────────────────────────────────────────
  // initializer を実行
  // ────────────────────────────────────────────────
  await delay(delayMs);

  // SCRInitialize
  await hre.ignition.deploy(InitializeModule, {
    parameters: parameters,
  });

  await delay(delayMs);

  // BorderlessAccessControlInitialize
  await hre.ignition.deploy(BorderlessAccessControlInitializeModule, {
    parameters: parameters,
  });

  await delay(delayMs);

  // DictionaryInitialize
  await hre.ignition.deploy(DictionaryInitializeModule, {
    parameters: parameters,
  });

  console.log(`✅ Done initialize`);

  // ────────────────────────────────────────────────
  // SCTを登録
  // ────────────────────────────────────────────────
  await delay(delayMs);

  const sctAddress = await sct.getAddress();
  console.log(`sctAddress: ${sctAddress}`);
  const { sctBeaconConn } = await hre.ignition.deploy(RegisterSCTModule, {
    parameters: {
      ...parameters,
      RegisterSCTModule: {
        SCTAddress: sctAddress,
        SCTName: "SC_JP_DAO_LLC",
      },
    },
  });

  console.log(`✅ Done set SCT`, sctBeaconConn.target);

  // ────────────────────────────────────────────────
  // 会社情報のフィールドを設定
  // ────────────────────────────────────────────────

  await delay(delayMs);
  const scrConn = await hre.ethers.getContractAt("SCR", proxy.target ?? "");

  await delay(delayMs);
  await scrConn.addCompanyInfoFields("SC_JP_DAO_LLC", "zip_code");

  await delay(delayMs);
  await scrConn.addCompanyInfoFields("SC_JP_DAO_LLC", "prefecture");

  await delay(delayMs);
  await scrConn.addCompanyInfoFields("SC_JP_DAO_LLC", "city");

  await delay(delayMs);
  await scrConn.addCompanyInfoFields("SC_JP_DAO_LLC", "address");

  console.log("✅ Set CompanyInfoFields");

  // ────────────────────────────────────────────────
  // Serviceを登録
  // ────────────────────────────────────────────────
  await delay(delayMs);
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

  await delay(delayMs);

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

  await delay(delayMs);

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

  await delay(delayMs);

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
  const serviceFactoryConn = await hre.ethers.getContractAt(
    "ServiceFactory",
    proxy
  );

  await delay(delayMs);
  await serviceFactoryConn.setLetsSaleBeacon(
    lets_jp_llc_exeBeacon.target ?? "",
    lets_jp_llc_saleBeacon.target ?? ""
  );

  await delay(delayMs);
  await serviceFactoryConn.setLetsSaleBeacon(
    lets_jp_llc_non_exeBeacon.target ?? "",
    lets_jp_llc_saleBeacon.target ?? ""
  );

  // ────────────────────────────────────────────────
  // FOUNDERロールの設定
  // ────────────────────────────────────────────────

  await delay(delayMs);

  // Set Role
  const adminRole =
    "0x0000000000000000000000000000000000000000000000000000000000000000";
  const founderRole =
    "0x7ed687a8f2955bd2ba7ca08227e1e364d132be747f42fb733165f923021b0225";
  const accessControlConn = await hre.ethers.getContractAt(
    "BorderlessAccessControl",
    proxy.target ?? ""
  );

  for (const adminAddress of adminAddresses) {
    await delay(delayMs);
    await accessControlConn
      .connect(deployerWallet)
      .grantRole(adminRole, adminAddress);
  }

  for (const founderAddress of founderAddresses) {
    await delay(delayMs);
    await accessControlConn
      .connect(deployerWallet)
      .grantRole(founderRole, founderAddress);
  }

  console.log("✅ Set Role");

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

  return {
    parameters,
    deployer,
    deployerWallet,
    proxy,
    dictionary,
    sct,
    sctBeaconConn,
    governanceBeacon,
    lets_jp_llc_exeBeacon,
    lets_jp_llc_non_exeBeacon,
    lets_jp_llc_saleBeacon,
  };
}

main().catch(console.error);
