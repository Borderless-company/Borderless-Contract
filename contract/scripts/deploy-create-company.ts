import hre from "hardhat";
import dotenv from "dotenv";
import { CreateSmartCompanyModule } from "../ignition/modules/Borderless";
import { BorderlessAccessControl } from "../typechain-types";
import { letsEncodeParams } from "../utils/Encode";
import { parseDeployArgs } from "../utils/parseArgs";
import { delay } from "../utils/Delay";
import deploy from "./deploy";

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
  } = await deploy();

  // ────────────────────────────────────────────────
  // FOUNDERロールの設定
  // ────────────────────────────────────────────────

  await delay(delayMs);

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

  await delay(delayMs);

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

  await delay(delayMs);

  const serviceFactoryConn = await hre.ethers.getContractAt(
    "ServiceFactory",
    await proxy.getAddress()
  );

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
  // LETS_JP_LLC_EXEの購入を実行
  // ────────────────────────────────────────────────

  // await delay(20000); // 10秒待機

  // // Saleコントラクトの設定
  // await letsExeSaleConn.getFunction(
  //   "setSaleInfo(uint256,uint256,uint256,uint256,uint256)"
  // )(
  //   0,
  //   0,
  //   hre.ethers.parseEther("0.001"), // 1 ETH
  //   0,
  //   0
  // );

  // await letsExeSaleConn
  //   .connect(deployerWallet)
  //   .getFunction("offerToken(address)")(
  //   deployer,
  //   { value: hre.ethers.parseEther("0.001") } // 1 ETHを送付
  // );

  // const executiveMember2Balance = await letsExeConn.balanceOf(deployer);
  // console.log(`executiveMember2Balance: ${executiveMember2Balance}`);

  // console.log("✅ LETS_JP_LLC_EXEの購入");

  // ────────────────────────────────────────────────
  // LETS_JP_LLC_NON_EXEの購入を実行
  // ────────────────────────────────────────────────

  // await delay(20000); // 10秒待機

  // // Saleコントラクトの設定
  // await letsNonExeSaleConn.getFunction(
  //   "setSaleInfo(uint256,uint256,uint256,uint256,uint256)"
  // )(
  //   0,
  //   0,
  //   hre.ethers.parseEther("0.001"), // 1 ETH
  //   0,
  //   0
  // );

  // await letsNonExeSaleConn
  //   .connect(deployerWallet)
  //   .getFunction("offerToken(address)")(
  //   deployer,
  //   { value: hre.ethers.parseEther("0.001") } // 1 ETHを送付
  // );

  // const letsNonExeExecutionMember2Balance = await letsNonExeConn.balanceOf(
  //   deployer
  // );
  // console.log(
  //   `letsNonExeExecutionMember2Balance: ${letsNonExeExecutionMember2Balance}`
  // );

  // console.log("✅ LETS_JP_LLC_NON_EXEの購入");

  // ────────────────────────────────────────────────
  // MINTER_ROLEからLETS_JP_LLC_EXEのmintを実行
  // ────────────────────────────────────────────────
  await delay(delayMs);

  // minter roleの付与
  const scrAccessControlConn = (
    await hre.ethers.getContractAt(
      "BorderlessAccessControl",
      await proxy.getAddress()
    )
  ).connect(deployerWallet) as BorderlessAccessControl;

  const MINTER_ROLE =
    "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6";
  await scrAccessControlConn.grantRole(MINTER_ROLE, deployer);

  await delay(delayMs);

  // mint を実行
  await letsExeConn.connect(deployerWallet).getFunction("mint(address)")(
    deployer
  );
  await delay(delayMs);
  const tokenMinterBalance = await letsExeConn.balanceOf(deployer);
  console.log(`tokenMinterBalance: ${tokenMinterBalance}`);

  console.log("✅ Done mint LETS_JP_LLC_EXE");

  // ────────────────────────────────────────────────
  // MINTER_ROLEからLETS_JP_LLC_NON_EXEのmintを実行
  // ────────────────────────────────────────────────
  await delay(delayMs);

  // mint を実行
  await letsNonExeConn.connect(deployerWallet).getFunction("mint(address)")(
    deployer
  );
  await delay(delayMs);
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
    letsNonExeProxy: await letsNonExeConn.getAddress(),
  });
}

main().catch(console.error);
