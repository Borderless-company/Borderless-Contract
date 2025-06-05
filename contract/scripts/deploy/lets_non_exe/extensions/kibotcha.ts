import hre from "hardhat";
import dotenv from "dotenv";
import { CreateSmartCompanyModule } from "../../../../ignition/modules/Borderless";
import { BorderlessAccessControl } from "../../../../typechain-types";
import {
  kibotchaLetsEncodeParams,
  letsEncodeParams,
} from "../../../utils/Encode";
import { parseDeployArgs } from "../../../utils/parseArgs";
import { delay } from "../../../utils/Delay";
import { getMinterAddresses } from "../../../utils/Deployer";
import { deployBorderless } from "../../../utils/Deploy";
import {
  KibotchaModule,
  RegisterKibotchaModule,
} from "../../../../ignition/modules/Kibotcha";

dotenv.config();

const { delayMs } = parseDeployArgs();

async function main() {
  const {
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
  } = await deployBorderless();

  // ────────────────────────────────────────────────
  // Kibotcha のデプロイ & 登録
  // ────────────────────────────────────────────────

  await delay(delayMs);

  const { kibotcha } = await hre.ignition.deploy(KibotchaModule, {
    parameters: {
      ...parameters,
    },
  });

  console.log(`kibotcha: ${kibotcha.target}`);

  console.log("✅ Done deploy Kibotcha");

  await delay(delayMs);

  const { serviceBeaconConn: kibotchaBeaconConn } = await hre.ignition.deploy(
    RegisterKibotchaModule,
    {
      parameters: {
        ...parameters,
        RegisterKibotchaModule: {
          ServiceName: "KIBOTCHA_LETS_JP_LLC_NON_EXE",
          ServiceType: 4,
        },
      },
    }
  );

  console.log("✅ Done register Kibotcha");

  await delay(delayMs);
  const serviceFactoryConn = await hre.ethers.getContractAt(
    "ServiceFactory",
    proxy
  );
  await serviceFactoryConn.setLetsSaleBeacon(
    kibotchaBeaconConn.target ?? "",
    lets_jp_llc_saleBeacon.target ?? ""
  );

  console.log("✅ Done set KibotchaBeacon");

  // ────────────────────────────────────────────────
  // createSmartCompany の実行
  // ────────────────────────────────────────────────

  await delay(delayMs);

  const scsExtraParams = [
    letsEncodeParams(
      "KIBOTCHA_LETS_JP_LLC_EXE",
      "KLETS",
      "https://example.com/metadata/",
      ".json",
      true,
      2000
    ),
    kibotchaLetsEncodeParams(
      "KIBOTCHA_LETS_JP_LLC_NON_EXE",
      "KLETS",
      "https://example.com/metadata/",
      ".json",
      false,
      2000,
      708
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
        LetsJpLlCNonExeBeaconAddress: await kibotchaBeaconConn.getAddress(),
        LetsJpLlCExeParams: scsExtraParams[0],
        LetsJpLlCNonExeParams: scsExtraParams[1],
      },
    },
  });
  console.log(`scProxyConn: ${scProxyConn.target}`);

  // ============================================== //
  //            ServiceFactoryからLETSを取得           //
  // ============================================== //

  await delay(delayMs);

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
  const letsNonExeConn = await hre.ethers.getContractAt(
    "KIBOTCHA_LETS_JP_LLC_NON_EXE",
    letsNonExeAddress
  );
  const letsNonExeSaleConn = await hre.ethers.getContractAt(
    "LETS_JP_LLC_SALE",
    letsNonExeAddress
  );

  console.log("✅ Done get LETS");

  // ────────────────────────────────────────────────
  // MINTER_ROLEからLETS_JP_LLC_EXEのmintを実行
  // ────────────────────────────────────────────────

  // minter roleの付与
  const scrAccessControlConn = (
    await hre.ethers.getContractAt(
      "BorderlessAccessControl",
      await proxy.getAddress()
    )
  ).connect(deployerWallet) as BorderlessAccessControl;

  const MINTER_ROLE =
    "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6";
  const minterAddresses = [...(await getMinterAddresses()), deployer];
  for (const minterAddress of minterAddresses) {
    await delay(delayMs);
    await scrAccessControlConn.grantRole(MINTER_ROLE, minterAddress);
  }

  // mint を実行
  await delay(delayMs);
  await letsExeConn.connect(deployerWallet).getFunction("mint(address)")(
    deployer
  );
  const tokenMinterBalance = await letsExeConn.balanceOf(deployer);
  console.log(`tokenMinterBalance: ${tokenMinterBalance}`);

  console.log("✅ Done mint LETS_JP_LLC_EXE");

  // ────────────────────────────────────────────────
  // MINTER_ROLEからLETS_JP_LLC_NON_EXEのmintを実行
  // ────────────────────────────────────────────────

  // mint を実行
  await delay(delayMs);
  await letsNonExeConn.connect(deployerWallet).getFunction("mint(address)")(
    deployer
  );
  const tokenMinterBalance2 = await letsNonExeConn.balanceOf(deployer);
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
    kibotchaLetsNonExeProxy: await letsNonExeConn.getAddress(),
  });
}

main().catch(console.error);
