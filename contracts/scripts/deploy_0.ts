import dotenv from "dotenv";
import { FunctionFragment, Interface } from "ethers";
import { ethers, upgrades } from "hardhat";
import {
  Initialize,
  SCR__factory,
  SCR,
  ServiceFactory,
} from "../typechain-types";

dotenv.config();

const iface = new Interface(SCR__factory.abi);

function getSCTBeaconAddress(receipt: any | null) {
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

function getServiceBeaconAddress(receipt: any | null) {
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

async function main() {
  // デプロイヤーのアドレスを取得
  //   const [deployer] = await ethers.getSigners();
  const deployerPrivateKey = process.env.DEPLOYER_PRIVATE_KEY;
  const deployer = new ethers.Wallet(
    deployerPrivateKey as string,
    ethers.provider
  );

  console.log("Deploying contracts with:", deployer);

  // 1. Dictionary コントラクトをデプロイ
  const Dictionary = await ethers.getContractFactory("Dictionary");
  const dictionary = await Dictionary.deploy(deployer.address);
  await dictionary.waitForDeployment();
  console.log("✅ Dictionary deployed at:", await dictionary.getAddress());

  // 2. 各コントラクトをデプロイ

  // BorderlessAccessControl
  const BorderlessAccessControl = (await ethers.getContractFactory(
    "BorderlessAccessControl"
  )) as any;
  const borderlessAccessControl = await BorderlessAccessControl.deploy();
  await borderlessAccessControl.waitForDeployment();
  console.log(
    "✅ BorderlessAccessControl at:",
    await borderlessAccessControl.getAddress()
  );

  // AddressManager
  const AddressManager = (await ethers.getContractFactory(
    "AddressManager"
  )) as any;
  const addressManager = await AddressManager.deploy();
  await addressManager.waitForDeployment();
  console.log("✅ AddressManager at:", await addressManager.getAddress());

  // SCRBeacon
  const SCRBeacon = await ethers.getContractFactory("SCRBeaconUpgradeable");
  const scrBeacon = await SCRBeacon.deploy();
  await scrBeacon.waitForDeployment();
  console.log("✅ SCRBeacon at:", await scrBeacon.getAddress());

  // ServiceFactoryBeaconUpgradeable
  const ServiceFactoryBeacon = await ethers.getContractFactory(
    "ServiceFactoryBeaconUpgradeable"
  );
  const serviceFactoryBeacon = await ServiceFactoryBeacon.deploy();
  await serviceFactoryBeacon.waitForDeployment();
  console.log(
    "✅ ServiceFactoryBeacon at:",
    await serviceFactoryBeacon.getAddress()
  );

  // ServiceFactory
  const ServiceFactory = await ethers.getContractFactory("ServiceFactory");
  const serviceFactory = await ServiceFactory.deploy();
  await serviceFactory.waitForDeployment();
  console.log("✅ ServiceFactory at:", await serviceFactory.getAddress());

  // SCR
  const SCR = await ethers.getContractFactory("SCR");
  const scr = await SCR.deploy();
  await scr.waitForDeployment();
  console.log("SCR at:", await scr.getAddress());

  // Initialize
  const Initialize = await ethers.getContractFactory("Initialize");
  const initialize = await Initialize.deploy();
  await initialize.waitForDeployment();
  console.log("Initialize at:", await initialize.getAddress());

  // 3. Dictionary に  実装アドレスを登録
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

  // Register all functions for each contract
  console.log("\n✅ Registering BorderlessAccessControl functions:");
  await registerFunctions(
    BorderlessAccessControl,
    await borderlessAccessControl.getAddress()
  );

  console.log("\n✅ Registering AddressManager functions:");
  await registerFunctions(AddressManager, await addressManager.getAddress());

  console.log("\n✅ Registering SCRBeacon functions:");
  await registerFunctions(SCRBeacon, await scrBeacon.getAddress());

  console.log("\n✅ Registering ServiceFactoryBeacon functions:");
  await registerFunctions(
    ServiceFactoryBeacon,
    await serviceFactoryBeacon.getAddress()
  );

  console.log("\n✅ Registering ServiceFactory functions:");
  await registerFunctions(ServiceFactory, await serviceFactory.getAddress());

  console.log("\n✅ Registering SCR functions:");
  await registerFunctions(SCR, await scr.getAddress());

  console.log("\n✅ Registering Initialize functions:");
  await registerFunctions(Initialize, await initialize.getAddress());

  console.log("\n✅ All implementations registered in Dictionary");

  // 4. SCRProxy（プロキシ）をデプロイ
  const SCRProxy = await ethers.getContractFactory("SCRProxy");
  const proxy = await SCRProxy.deploy(await dictionary.getAddress(), "0x");
  await proxy.waitForDeployment();
  console.log("SCRProxy deployed at:", await proxy.getAddress());

  // 5. initializer を実行
  const initializeConn = (
    await ethers.getContractAt("Initialize", await proxy.getAddress())
  ).connect(deployer) as Initialize;
  await initializeConn.initialize(deployer.address);

  // 6. SCTをデプロイ
  const SCT = await ethers.getContractFactory("SC_JP_DAOLLC");
  const sct = await SCT.deploy();
  await sct.waitForDeployment();
  console.log("✅ SCT deployed at:", await sct.getAddress());

  // 7. Set SCT
  const scrConn = (
    await ethers.getContractAt("SCR", await proxy.getAddress())
  ).connect(deployer) as SCR;
  const sctBeacon = await scrConn.setSCContract(
    await sct.getAddress(),
    "SC_JP_DAOLLC"
  );
  const receipt = await sctBeacon.wait();
  const sctBeaconAddress = getSCTBeaconAddress(receipt);
  console.log("✅ Set SCT", sctBeaconAddress);

  await scrConn.addCompanyInfoFields("SC_JP_DAOLLC", "zip_code");
  await scrConn.addCompanyInfoFields("SC_JP_DAOLLC", "prefecture");
  await scrConn.addCompanyInfoFields("SC_JP_DAOLLC", "city");
  await scrConn.addCompanyInfoFields("SC_JP_DAOLLC", "address");

  // 8. Deploy Services

  const lets_jp_llc_exe = await ethers.getContractFactory("LETS_JP_LLC_EXE");
  const lets_jp_llc_exeContractAddress = await lets_jp_llc_exe.deploy();
  await lets_jp_llc_exeContractAddress.waitForDeployment();

  const lets_jp_llc_non_exe = await ethers.getContractFactory(
    "LETS_JP_LLC_NON_EXE"
  );
  const lets_jp_llc_non_exeContractAddress = await lets_jp_llc_non_exe.deploy();
  await lets_jp_llc_non_exeContractAddress.waitForDeployment();

  const governance_jp_llc =
    await ethers.getContractFactory("Governance_JP_LLC");
  const governance_jp_llcContractAddress = await governance_jp_llc.deploy();
  await governance_jp_llcContractAddress.waitForDeployment();

  const lets_jp_llc_sale = await ethers.getContractFactory("LETS_JP_LLC_SALE");
  const lets_jp_llc_saleContractAddress = await lets_jp_llc_sale.deploy();
  await lets_jp_llc_saleContractAddress.waitForDeployment();

  // 9. set Service
  const serviceFactoryConn = (
    await ethers.getContractAt("ServiceFactory", await proxy.getAddress())
  ).connect(deployer) as ServiceFactory;
  const lets_jp_llc_exeBeacon = await serviceFactoryConn.setService(
    lets_jp_llc_exeContractAddress,
    "LETS_JP_LLC_EXE",
    3
  );
  const lets_jp_llc_exeReceipt = await lets_jp_llc_exeBeacon.wait();
  const lets_jp_llc_exeBeaconAddress = getServiceBeaconAddress(
    lets_jp_llc_exeReceipt
  );
  console.log("✅ Set lets_jp_llc_exeBeacon", lets_jp_llc_exeBeaconAddress);

  const lets_jp_llc_non_exeBeacon = await serviceFactoryConn.setService(
    lets_jp_llc_non_exeContractAddress,
    "LETS_JP_LLC_NON_EXE",
    4
  );
  const lets_jp_llc_non_exeReceipt = await lets_jp_llc_non_exeBeacon.wait();
  const lets_jp_llc_non_exeBeaconAddress = getServiceBeaconAddress(
    lets_jp_llc_non_exeReceipt
  );
  const governance_jp_llcBeacon = await serviceFactoryConn.setService(
    governance_jp_llcContractAddress,
    "Governance_JP_LLC",
    2
  );
  const governance_jp_llcReceipt = await governance_jp_llcBeacon.wait();
  const governance_jp_llcBeaconAddress = getServiceBeaconAddress(
    governance_jp_llcReceipt
  );

  const lets_jp_llc_saleBeacon = await serviceFactoryConn.setService(
    lets_jp_llc_saleContractAddress,
    "LETS_JP_LLC_SALE",
    5
  );
  const lets_jp_llc_saleReceipt = await lets_jp_llc_saleBeacon.wait();
  const lets_jp_llc_saleBeaconAddress = getServiceBeaconAddress(
    lets_jp_llc_saleReceipt
  );

  // 10. output address (table format)
  console.log("✅ Deployment complete");
  console.table({
    SCRProxy: await proxy.getAddress(),
    LETS_JP_LLC_EXE: lets_jp_llc_exeBeaconAddress,
    LETS_JP_LLC_NON_EXE: lets_jp_llc_non_exeBeaconAddress,
    Governance_JP_LLC: governance_jp_llcBeaconAddress,
    LETS_JP_LLC_SALE: lets_jp_llc_saleBeaconAddress,
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
