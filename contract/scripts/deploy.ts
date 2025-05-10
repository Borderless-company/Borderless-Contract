import hre from "hardhat";
import dotenv from "dotenv";
import { FunctionFragment } from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import {
  BorderlessModule,
  InitializeModule,
  RegisterSCTModule,
  RegisterGovernanceServiceModule,
  RegisterLetsServiceModule,
  RegisterLetsNonExeServiceModule,
  RegisterLetsSaleServiceModule,
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

const registerFunctions = async (
  dictionary: any,
  name: string,
  implAddress: string
) => {
  const factory = await hre.ethers.getContractFactory(name);
  for (const frag of factory.interface.fragments) {
    if (!(frag instanceof FunctionFragment)) continue;
    console.log(`registering function ${frag.name}`);
    console.log(
      `frag.inputs.map((i) => i.type): ${JSON.stringify(
        frag.inputs.map((i) => i.type)
      )}`
    );
    const selector = FunctionFragment.getSelector(
      frag.name,
      frag.inputs.map((i) => i.type)
    );
    const receipt = await dictionary.setImplementation(selector, implAddress);
    await receipt.wait();
    console.log(`✅ Done register function ${frag.name}`);
  }
};

async function main() {
  const { deployer, deployerWallet } = await getDeployerAddress();
  console.log(`deployer: ${deployer}`);

  const parameters = {
    BorderlessModule: { Deployer: deployer },
    InitializeModule: { Deployer: deployer },
  };

  const {
    accessControlFacet,
    addressManagerFacet,
    scrBeaconFacet,
    sfBeaconFacet,
    serviceFactoryFacet,
    initializeFacet,
    scrFacet,
    dictionary,
    proxy,
    sct,
    governance_jp_llc,
    lets_jp_llc_exe,
    lets_jp_llc_non_exe,
    lets_jp_llc_sale,
  } = await hre.ignition.deploy(BorderlessModule, {
    parameters: parameters
  });

  console.log(`✅ Done deploy BorderlessModule`);

  // ────────────────────────────────────────────────
  // Register all Facets in Dictionary
  // ────────────────────────────────────────────────

  // const dictAsOwner = await hre.ethers.getContractAt(
  //   "Dictionary",
  //   await dictionary.getAddress(),
  //   deployerWallet
  // );

  // console.log(`✅ Done get Dictionary`);

  // // Facetごとにプレフィックスを分けて登録
  // await registerFunctions(
  //   dictAsOwner,
  //   "BorderlessAccessControl",
  //   await accessControlFacet.getAddress()
  // );

  // console.log(`✅ Done register BorderlessAccessControl`);

  // await registerFunctions(
  //   dictAsOwner,
  //   "AddressManager",
  //   await addressManagerFacet.getAddress()
  // );

  // console.log(`✅ Done register AddressManager`);

  // await registerFunctions(
  //   dictAsOwner,
  //   "SCRBeaconUpgradeable",
  //   await scrBeaconFacet.getAddress()
  // );

  // console.log(`✅ Done register SCRBeaconUpgradeable`);

  // await registerFunctions(
  //   dictAsOwner,
  //   "ServiceFactoryBeaconUpgradeable",
  //   await sfBeaconFacet.getAddress()
  // );

  // console.log(`✅ Done register ServiceFactoryBeaconUpgradeable`);

  // await registerFunctions(
  //   dictAsOwner,
  //   "ServiceFactory",
  //   await serviceFactoryFacet.getAddress()
  // );

  // console.log(`✅ Done register ServiceFactory`);

  // await registerFunctions(
  //   dictAsOwner,
  //   "Initialize",
  //   await initializeFacet.getAddress()
  // );

  // console.log(`✅ Done register Initialize`);

  // await registerFunctions(dictAsOwner, "SCR", await scrFacet.getAddress());

  // console.log(`✅ Done register SCR`);

  // console.log("✅ Done register functions");

  // // ────────────────────────────────────────────────
  // // initializer を実行
  // // ────────────────────────────────────────────────
  await hre.ignition.deploy(InitializeModule, {
    parameters: parameters
  });

  console.log(`✅ Done initialize`);

  // ────────────────────────────────────────────────
  // SCTを登録
  // ────────────────────────────────────────────────
  const sctAddress = await sct.getAddress();
  console.log(`sctAddress: ${sctAddress}`);
  const { sctBeaconConn } = await hre.ignition.deploy(RegisterSCTModule, {
    parameters: {
      ...parameters,
      RegisterSCTModule: {
        SCTAddress: sctAddress,
      },
    },
  });

  console.log(`✅ Done set SCT`, sctBeaconConn.target);

  // ────────────────────────────────────────────────
  // Serviceを登録
  // ────────────────────────────────────────────────
  const governance_jp_llc_address = await governance_jp_llc.getAddress();
  const { serviceBeaconConn: governanceBeacon } = await hre.ignition.deploy(
    RegisterGovernanceServiceModule,
    {
      parameters: {
        ...parameters,
        RegisterGovernanceServiceModule: {
          ServiceAddress: governance_jp_llc_address,
          ServiceName: "Governance_JP_LLC",
          ServiceType: 2,
        },
      },
    }
  );

  const lets_jp_llc_exe_address = await lets_jp_llc_exe.getAddress();
  const { serviceBeaconConn: lets_jp_llc_exeBeacon } =
    await hre.ignition.deploy(RegisterLetsServiceModule, {
      parameters: {
        ...parameters,
        RegisterLetsServiceModule: {
          ServiceAddress: lets_jp_llc_exe_address,
          ServiceName: "LETS_JP_LLC_EXE",
          ServiceType: 3,
        },
      },
    });

  const lets_jp_llc_non_exe_address = await lets_jp_llc_non_exe.getAddress();
  const { serviceBeaconConn: lets_jp_llc_non_exeBeacon } =
    await hre.ignition.deploy(RegisterLetsNonExeServiceModule, {
      parameters: {
        ...parameters,
        RegisterLetsNonExeServiceModule: {
          ServiceAddress: lets_jp_llc_non_exe_address,
          ServiceName: "LETS_JP_LLC_NON_EXE",
          ServiceType: 4,
        },
      },
    });

  const lets_jp_llc_sale_address = await lets_jp_llc_sale.getAddress();
  const { serviceBeaconConn: lets_jp_llc_saleBeacon } =
    await hre.ignition.deploy(RegisterLetsSaleServiceModule, {
      parameters: {
        ...parameters,
        RegisterLetsSaleServiceModule: {
          ServiceAddress: lets_jp_llc_sale_address,
          ServiceName: "LETS_JP_LLC_SALE",
          ServiceType: 5,
        },
      },
    });

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
}

main().catch(console.error);
