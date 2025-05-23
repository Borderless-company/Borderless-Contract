import { ethers } from "hardhat";
import { registerFunctions } from "./DictionaryHelper";
import {
  SCRInitialize,
  BorderlessAccessControl,
  SCR,
  ServiceFactory,
} from "../../typechain-types";
import { expect } from "chai";
import { getBeaconAddress } from "./Event";

export const deployFullFixture = async () => {
  // ============================================== //
  //                   アドレスの準備                  //
  // ============================================== //
  const [
    deployer,
    founder,
    executionMember,
    executionMember2,
    executionMember3,
    tokenMinter,
  ] = await ethers.getSigners();

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

  console.log("✅ Deployed serviceFactory", await serviceFactory.getAddress());

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

  await registerFunctions(dictionary, SCRBeacon, await scrBeacon.getAddress());
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
  //            JP_DAO_LLCコントラクトのデプロイ           //
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
  const lets_jp_llc_non_exeContractAddress = await lets_jp_llc_non_exe.deploy();
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
  const lets_jp_llc_sale = await ethers.getContractFactory("LETS_JP_LLC_SALE");
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
  const lets_jp_llc_exeBeaconAddress = getBeaconAddress(lets_jp_llc_exeReceipt);
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
  console.log("✅ Set governance_jp_llcBeacon", governance_jp_llcBeaconAddress);

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
    executionMember3,
    tokenMinter,
    serviceFactory,
    sctBeaconAddress: sctBeaconAddress ?? "",
    lets_jp_llc_exeBeaconAddress: lets_jp_llc_exeBeaconAddress ?? "",
    lets_jp_llc_non_exeBeaconAddress: lets_jp_llc_non_exeBeaconAddress ?? "",
    governance_jp_llcBeaconAddress: governance_jp_llcBeaconAddress ?? "",
    lets_jp_llc_saleBeaconAddress: lets_jp_llc_saleBeaconAddress ?? "",
  };
};
