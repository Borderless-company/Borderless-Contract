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
import { BorderlessAccessControl } from "../typechain-types";
import { letsEncodeParams } from "../utils/Encode";
import { getDeployerAddress } from "../utils/Deployer";
import { registerAllFacets } from "../utils/DictionaryHelper";
import { delay } from "../utils/Delay";
import { setBorderlessAccessControlOnceInitialized } from "../utils/Initialize";
dotenv.config();

async function main() {
  const { deployer, deployerWallet } = await getDeployerAddress();

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
  } = await hre.ignition.deploy(BorderlessModule, {
    parameters: parameters,
  });

  console.log(`✅ Done deploy BorderlessModule`);

  // ────────────────────────────────────────────────
  // 関数セレクタ登録権限の付与
  // ────────────────────────────────────────────────

  await setBorderlessAccessControlOnceInitialized(
    dictionary,
    deployerWallet,
    accessControlFacet
  );

  // ────────────────────────────────────────────────
  // Register all Facets in Dictionary
  // ────────────────────────────────────────────────

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

  // SCRInitialize
  await hre.ignition.deploy(InitializeModule, {
    parameters: parameters,
  });

  // BorderlessAccessControlInitialize
  await hre.ignition.deploy(BorderlessAccessControlInitializeModule, {
    parameters: parameters,
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
    },
  });

  console.log(`✅ Done set SCT`, sctBeaconConn.target);

  // ────────────────────────────────────────────────
  // 会社情報のフィールドを設定
  // ────────────────────────────────────────────────

  const scrConn = await hre.ethers.getContractAt("SCR", proxy.target ?? "");
  await scrConn.addCompanyInfoFields("SC_JP_DAOLLC", "zip_code");
  await scrConn.addCompanyInfoFields("SC_JP_DAOLLC", "prefecture");
  await scrConn.addCompanyInfoFields("SC_JP_DAOLLC", "city");
  await scrConn.addCompanyInfoFields("SC_JP_DAOLLC", "address");

  console.log("✅ Set CompanyInfoFields");

  // ────────────────────────────────────────────────
  // Serviceを登録
  // ────────────────────────────────────────────────

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
  await serviceFactoryConn.setLetsSaleBeacon(
    lets_jp_llc_exeBeacon.target ?? "",
    lets_jp_llc_saleBeacon.target ?? ""
  );
  await serviceFactoryConn.setLetsSaleBeacon(
    lets_jp_llc_non_exeBeacon.target ?? "",
    lets_jp_llc_saleBeacon.target ?? ""
  );

  // ────────────────────────────────────────────────
  // FOUNDERロールの設定
  // ────────────────────────────────────────────────

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

  const scsExtraParams = [
    letsEncodeParams(
      "LETS_JP_LLC_EXE",
      "LETS_JP_LLC_EXE",
      "https://example.com/metadata/",
      ".json",
      true,
      2000
    ),
    letsEncodeParams(
      "LETS_JP_LLC_NON_EXE",
      "LETS_JP_LLC_NON_EXE",
      "https://example.com/metadata/",
      ".json",
      false,
      2000
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

  // ============================================== //
  //            ServiceFactoryからLETSを取得           //
  // ============================================== //

  await delay(1000); // 1秒待機

  const letsExeAddress = await serviceFactoryConn.getFounderService(
    deployer,
    3
  );
  const letsNonExeAddress = await serviceFactoryConn.getFounderService(
    deployer,
    4
  );
  const letsExeConn = await hre.ethers.getContractAt(
    "LETS_JP_LLC_EXE",
    letsExeAddress
  );
  const letsExeSaleConn = await hre.ethers.getContractAt(
    "LETS_JP_LLC_SALE",
    letsExeAddress
  );
  const letsNonExeConn = await hre.ethers.getContractAt(
    "LETS_JP_LLC_NON_EXE",
    letsNonExeAddress
  );
  const letsNonExeSaleConn = await hre.ethers.getContractAt(
    "LETS_JP_LLC_SALE",
    letsNonExeAddress
  );

  console.log("✅ Done get LETS");

  // ────────────────────────────────────────────────
  // LETS_JP_LLC_EXEのinitialMintを実行
  // ────────────────────────────────────────────────

  const executiveMember = await hre.ethers.getSigner(
    "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"
  );

  await letsExeConn
    .connect(deployerWallet)
    .initialMint([deployer, executiveMember]);
  const deployerBalance = await letsExeConn.balanceOf(deployer);
  console.log(`deployerBalance: ${deployerBalance}`);
  const executiveMemberBalance = await letsExeConn.balanceOf(executiveMember);
  console.log(`executiveMemberBalance: ${executiveMemberBalance}`);

  console.log("✅ LETS_JP_LLC_EXEのmint");

  // ────────────────────────────────────────────────
  // LETS_JP_LLC_EXEの購入を実行
  // ────────────────────────────────────────────────

  const executiveMember2 = await hre.ethers.getSigner(
    "0x90F79bf6EB2c4f870365E785982E1f101E93b906"
  );

  // Saleコントラクトの設定
  await letsExeSaleConn.getFunction(
    "setSaleInfo(uint256,uint256,uint256,uint256,uint256)"
  )(
    0,
    0,
    hre.ethers.parseEther("0.001"), // 1 ETH
    0,
    0
  );

  await letsExeSaleConn
    .connect(executiveMember2)
    .getFunction("offerToken(address)")(
    executiveMember2,
    { value: hre.ethers.parseEther("0.001") } // 1 ETHを送付
  );

  const executiveMember2Balance = await letsExeConn.balanceOf(executiveMember2);
  console.log(`executiveMember2Balance: ${executiveMember2Balance}`);

  console.log("✅ LETS_JP_LLC_EXEの購入");

  // ────────────────────────────────────────────────
  // LETS_JP_LLC_NON_EXEの購入を実行
  // ────────────────────────────────────────────────

  // Saleコントラクトの設定
  await letsNonExeSaleConn.getFunction(
    "setSaleInfo(uint256,uint256,uint256,uint256,uint256)"
  )(
    0,
    0,
    hre.ethers.parseEther("0.001"), // 1 ETH
    0,
    0
  );

  await letsNonExeSaleConn
    .connect(deployerWallet)
    .getFunction("offerToken(address)")(
    deployer,
    { value: hre.ethers.parseEther("0.001") } // 1 ETHを送付
  );

  const letsNonExeExecutionMember2Balance = await letsNonExeConn.balanceOf(
    deployer
  );
  console.log(
    `letsNonExeExecutionMember2Balance: ${letsNonExeExecutionMember2Balance}`
  );

  console.log("✅ LETS_JP_LLC_NON_EXEの購入");

  // ────────────────────────────────────────────────
  // MINTER_ROLEからLETS_JP_LLC_EXEのmintを実行
  // ────────────────────────────────────────────────

  const tokenMinter = await hre.ethers.getSigner(
    "0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65"
  );

  // minter roleの付与
  const scrAccessControlConn = (
    await hre.ethers.getContractAt(
      "BorderlessAccessControl",
      await proxy.getAddress()
    )
  ).connect(deployerWallet) as BorderlessAccessControl;

  const MINTER_ROLE =
    "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6";
  await scrAccessControlConn.grantRole(MINTER_ROLE, tokenMinter);

  // mint を実行
  await letsExeConn.connect(tokenMinter).getFunction("mint(address)")(
    tokenMinter
  );
  const tokenMinterBalance = await letsExeConn.balanceOf(tokenMinter);
  console.log(`tokenMinterBalance: ${tokenMinterBalance}`);

  // ────────────────────────────────────────────────
  // MINTER_ROLEからLETS_JP_LLC_NON_EXEのmintを実行
  // ────────────────────────────────────────────────

  // mint を実行
  await letsNonExeConn.connect(tokenMinter).getFunction("mint(address)")(
    tokenMinter
  );
  const tokenMinterBalance2 = await letsNonExeConn.balanceOf(tokenMinter);
  console.log(`tokenMinterBalance2: ${tokenMinterBalance2}`);

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
    letsExeProxy: await letsExeConn.getAddress(),
    letsNonExeProxy: await letsNonExeConn.getAddress(),
  });
}

main().catch(console.error);
