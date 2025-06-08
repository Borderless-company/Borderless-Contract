import { ethers } from "hardhat";
import { registerFacets } from "./DictionaryHelper";
import {
  SCRInitialize,
  BorderlessAccessControl,
  BorderlessProxy,
} from "../../typechain-types";
import { setOnceInitialized } from "./DictionaryHelper";
import {
  deployDictionary,
  deployBorderlessAccessControl,
  deploySCRBeaconUpgradeable,
  deployServiceFactoryBeaconUpgradeable,
  deployServiceFactory,
  deploySCR,
  deploySCRInitialize,
  deployBorderlessProxy,
  deploySCT,
  deployGovernanceBase,
  deployAOI,
  deployLETSBase,
  deployLETSSaleBase,
  deploySC_JP_DAO_LLC,
  deployLETS_JP_LLC_EXE,
  deployLETS_JP_LLC_NON_EXE,
  deployGovernance_JP_LLC,
  deployLETSSale_JP_LLC,
} from "./DeployContracts";
import { setCompanyInfoFields, setSCT } from "./SCRHelper";
import { grantFounderRole } from "./Role";
import { setLetsSaleBeacon } from "./LETSHelpers";
import { setService } from "./ServiceFactory";

export const addresses = async () => {
  const [
    deployer,
    founder,
    executiveMember,
    executiveMember2,
    executiveMember3,
    tokenMinter,
  ] = await ethers.getSigners();

  console.log("🤖 deployer", deployer.address);
  console.log("🤖 founder", founder.address);
  console.log("🤖 executiveMember", executiveMember.address);
  console.log("🤖 executiveMember2", executiveMember2.address);
  console.log("🤖 executiveMember3", executiveMember3.address);
  console.log("🤖 tokenMinter", tokenMinter.address);

  return {
    deployer,
    founder,
    executiveMember,
    executiveMember2,
    executiveMember3,
    tokenMinter,
  };
};

export const deployBaseFixture = async () => {
  // ==============================================
  // Prepare addresses
  // ==============================================

  const {
    deployer,
    founder,
    executiveMember,
    executiveMember2,
    executiveMember3,
    tokenMinter,
  } = await addresses();

  // ==============================================
  // Deploy Dictionary
  // ==============================================

  const { contract: dictionary } = await deployDictionary();

  // ============================================== //
  // Deploy BorderlessAccessControl
  // ============================================== //

  const { contract: borderlessAccessControlImplementation } =
    await deployBorderlessAccessControl();

  // ============================================== //
  // Deploy SCRBeacon
  // ============================================== //

  const { contract: scrBeaconUpgradeable, Contract: SCRBeaconUpgradeable } =
    await deploySCRBeaconUpgradeable();

  // ============================================== //
  // Deploy ServiceFactoryBeacon
  // ============================================== //

  const {
    contract: serviceFactoryBeaconUpgradeableImplementation,
    Contract: ServiceFactoryBeaconUpgradeable,
  } = await deployServiceFactoryBeaconUpgradeable();

  // ============================================== //
  // Deploy ServiceFactory
  // ============================================== //

  const { contract: serviceFactoryImplementation, Contract: ServiceFactory } =
    await deployServiceFactory();

  // ============================================== //
  // Deploy SCR
  // ============================================== //

  const { contract: scrImplementation, Contract: SCR } = await deploySCR();

  // ============================================== //
  // Deploy SCRInitialize
  // ============================================== //

  const { contract: scrInitializeImplementation, Contract: SCRInitialize } =
    await deploySCRInitialize();

  // ============================================== //
  // setOnceInitialized
  // ============================================== //

  await setOnceInitialized(dictionary, deployer, await borderlessAccessControlImplementation.getAddress(), await borderlessAccessControlImplementation.getAddress());

  // ============================================== //
  // Register facets
  // ============================================== //

  await registerFacets(
    dictionary,
    SCRBeaconUpgradeable,
    await scrBeaconUpgradeable.getAddress()
  );
  await registerFacets(
    dictionary,
    ServiceFactoryBeaconUpgradeable,
    await serviceFactoryBeaconUpgradeableImplementation.getAddress()
  );
  await registerFacets(
    dictionary,
    ServiceFactory,
    await serviceFactoryImplementation.getAddress()
  );
  await registerFacets(dictionary, SCR, await scrImplementation.getAddress());
  await registerFacets(
    dictionary,
    SCRInitialize,
    await scrInitializeImplementation.getAddress()
  );

  console.log("✅ Registered functions in Dictionary");

  // ============================================== //
  // Deploy BorderlessProxy
  // ============================================== //

  const { contract: borderlessProxy } = await deployBorderlessProxy(dictionary);

  // ============================================== //
  // Initialize
  // ============================================== //

  // initialize SCRInitialize
  const initializeConn = (
    await ethers.getContractAt(
      "SCRInitialize",
      await borderlessProxy.getAddress()
    )
  ).connect(deployer) as SCRInitialize;
  await initializeConn.initialize(deployer.address);

  // initialize BorderlessAccessControl
  const borderlessAccessControlConn = (
    await ethers.getContractAt(
      "BorderlessAccessControl",
      await borderlessAccessControlImplementation.getAddress()
    )
  ).connect(deployer) as BorderlessAccessControl;
  await borderlessAccessControlConn.initialize(dictionary.getAddress());
  console.log("✅ Initialized BorderlessAccessControl");

  // ============================================== //
  // Set Founder Role
  // ============================================== //

  await grantFounderRole(deployer, borderlessProxy as BorderlessProxy, founder);

  return {
    deployer,
    founder,
    executiveMember,
    executiveMember2,
    executiveMember3,
    tokenMinter,
    borderlessProxy: borderlessProxy as BorderlessProxy,
    dictionary,
    scrImplementation,
    serviceFactoryImplementation,
    scrBeaconUpgradeable,
    serviceFactoryBeaconUpgradeableImplementation,
    scrInitializeImplementation,
    borderlessAccessControlImplementation,
  };
};

export const deployFixture = async () => {
  const {
    deployer,
    founder,
    executiveMember,
    executiveMember2,
    executiveMember3,
    tokenMinter,
    borderlessProxy,
    dictionary,
    scrImplementation,
    serviceFactoryImplementation,
    scrBeaconUpgradeable,
    serviceFactoryBeaconUpgradeableImplementation,
    scrInitializeImplementation,
    borderlessAccessControlImplementation,
  } = await deployBaseFixture();

  // ============================================== //
  // Deploy SCT
  // ============================================== //

  const { contract: sctImplementation } = await deploySCT();

  // ============================================== //
  // Set SCT
  // ============================================== //

  const sctBeacon = await setSCT(sctImplementation, borderlessProxy as BorderlessProxy, deployer, "SCT");

  // ============================================== //
  // Set CompanyInfoFields
  // ============================================== //

  await setCompanyInfoFields(
    borderlessProxy as BorderlessProxy,
    deployer,
    "SCT",
    ["zip_code", "prefecture", "city", "address"]
  );

  // ============================================== //
  // Deploy Service Contracts  //
  // ============================================== //

  // governanceBase
  const { contract: governanceBaseImplementation } = await deployGovernanceBase();

  // aoi
  const { contract: aoiImplementation } = await deployAOI();

  // letsBase
  const { contract: letsBaseImplementation } = await deployLETSBase();

  // letsSaleBase
  const { contract: letsSaleBaseImplementation } = await deployLETSSaleBase();

  // ============================================== //
  // Set Service Contracts
  // ============================================== //

  const aoiBeaconAddress = await setService(
    borderlessProxy as BorderlessProxy,
    deployer,
    await aoiImplementation.getAddress(),
    "AOI",
    1
  );
  const aoiBeacon = await ethers.getContractAt("SCRBeaconUpgradeable", aoiBeaconAddress);

  const governanceBaseBeaconAddress = await setService(
    borderlessProxy as BorderlessProxy,
    deployer,
    await governanceBaseImplementation.getAddress(),
    "GovernanceBase",
    2
  );
  const governanceBaseBeacon = await ethers.getContractAt("SCRBeaconUpgradeable", governanceBaseBeaconAddress);

  const letsBaseBeaconAddress = await setService(
    borderlessProxy as BorderlessProxy,
    deployer,
    await letsBaseImplementation.getAddress(),
    "LETSBase",
    3
  );
  const letsBaseBeacon = await ethers.getContractAt("SCRBeaconUpgradeable", letsBaseBeaconAddress);

  const letsNonExeBaseBeaconAddress = await setService(
    borderlessProxy as BorderlessProxy,
    deployer,
    await letsBaseImplementation.getAddress(),
    "LETSBase",
    4
  );
  const letsNonExeBaseBeacon = await ethers.getContractAt("SCRBeaconUpgradeable", letsNonExeBaseBeaconAddress);

  const letsSaleBaseBeaconAddress = await setService(
    borderlessProxy as BorderlessProxy,
    deployer,
    await letsSaleBaseImplementation.getAddress(),
    "LETSSaleBase",
    5
  );
  const letsSaleBaseBeacon = await ethers.getContractAt("SCRBeaconUpgradeable", letsSaleBaseBeaconAddress);

  // ============================================== //
  // Set LetsSaleBeacon
  // ============================================== //

  await setLetsSaleBeacon(
    borderlessProxy as BorderlessProxy,
    letsBaseBeaconAddress,
    letsSaleBaseBeaconAddress
  );

  await setLetsSaleBeacon(
    borderlessProxy as BorderlessProxy,
    letsNonExeBaseBeaconAddress,
    letsSaleBaseBeaconAddress
  );

  // ============================================== //
  // Return
  // ============================================== //

  return {
    deployer,
    founder,
    executiveMember,
    executiveMember2,
    executiveMember3,
    tokenMinter,
    borderlessProxy,
    dictionary,
    scrImplementation,
    sctBeacon,
    serviceFactoryImplementation,
    scrBeaconUpgradeable,
    serviceFactoryBeaconUpgradeableImplementation,
    scrInitializeImplementation,
    borderlessAccessControlImplementation,
    governanceBaseBeacon,
    aoiBeacon,
    letsBaseBeacon,
    letsNonExeBaseBeacon,
    letsSaleBaseBeacon,
  };
};

export const deployJP_DAO_LLCFullFixture = async () => {
  const {
    deployer,
    founder,
    executiveMember,
    executiveMember2,
    executiveMember3,
    tokenMinter,
    borderlessProxy,
    dictionary,
    scrImplementation,
    sctBeacon,
    serviceFactoryImplementation,
    scrBeaconUpgradeable,
    serviceFactoryBeaconUpgradeableImplementation,
    scrInitializeImplementation,
    borderlessAccessControlImplementation,
    governanceBaseBeacon,
    aoiBeacon,
    letsBaseBeacon,
    letsNonExeBaseBeacon,
    letsSaleBaseBeacon,
  } = await deployFixture();

  // ============================================== //
  // Deploy JP_DAO_LLC
  // ============================================== //

  // Deploy SCT
  const { contract: sc_jp_dao_llcImplementation } = await deploySC_JP_DAO_LLC();

  // ============================================== //
  // Set SCT
  // ============================================== //

  const sc_jp_dao_llcBeacon = await setSCT(
    sc_jp_dao_llcImplementation,
    borderlessProxy as BorderlessProxy,
    deployer,
    "SC_JP_DAO_LLC"
  );

  console.log("ok sc_jp_dao_llcBeacon", sc_jp_dao_llcBeacon);

  // ============================================== //
  // Set CompanyInfoFields
  // ============================================== //

  await setCompanyInfoFields(
    borderlessProxy as BorderlessProxy,
    deployer,
    "SC_JP_DAO_LLC",
    ["zip_code", "prefecture", "city", "address"]
  );

  // ============================================== //
  // Deploy Service Contracts
  // ============================================== //

  // Governance_JP_LLC
  const { contract: governance_jp_llcImplementation } = await deployGovernance_JP_LLC();

  // LETS_JP_LLC_EXE
  const { contract: lets_jp_llc_exeImplementation } = await deployLETS_JP_LLC_EXE();

  // LETS_JP_LLC_NON_EXE
  const { contract: lets_jp_llc_non_exeImplementation } =
    await deployLETS_JP_LLC_NON_EXE();

  // LETS_JP_LLC_SALE
  const { contract: lets_jp_llc_saleImplementation } = await deployLETSSale_JP_LLC();

  // ============================================== //
  // Set Service Contracts
  // ============================================== //

  const governance_jp_llcBeaconAddress = await setService(
    borderlessProxy as BorderlessProxy,
    deployer,
    await governance_jp_llcImplementation.getAddress(),
    "Governance_JP_LLC",
    2
  );
  const governance_jp_llcBeacon = await ethers.getContractAt("SCRBeaconUpgradeable", governance_jp_llcBeaconAddress);

  const lets_jp_llc_exeBeaconAddress = await setService(
    borderlessProxy as BorderlessProxy,
    deployer,
    await lets_jp_llc_exeImplementation.getAddress(),
    "LETS_JP_LLC_EXE",
    3
  );
  const lets_jp_llc_exeBeacon = await ethers.getContractAt("SCRBeaconUpgradeable", lets_jp_llc_exeBeaconAddress);

  const lets_jp_llc_non_exeBeaconAddress = await setService(
    borderlessProxy as BorderlessProxy,
    deployer,
    await lets_jp_llc_non_exeImplementation.getAddress(),
    "LETS_JP_LLC_NON_EXE",
    4
  );
  const lets_jp_llc_non_exeBeacon = await ethers.getContractAt("SCRBeaconUpgradeable", lets_jp_llc_non_exeBeaconAddress);

  const lets_jp_llc_saleBeaconAddress = await setService(
    borderlessProxy as BorderlessProxy,
    deployer,
    await lets_jp_llc_saleImplementation.getAddress(),
    "LETS_JP_LLC_SALE",
    5
  );
  const lets_jp_llc_saleBeacon = await ethers.getContractAt("SCRBeaconUpgradeable", lets_jp_llc_saleBeaconAddress);

  // ============================================== //
  //            LETS and Sale contract association             //
  // ============================================== //

  await setLetsSaleBeacon(
    borderlessProxy as BorderlessProxy,
    lets_jp_llc_exeBeaconAddress,
    lets_jp_llc_saleBeaconAddress
  );

  await setLetsSaleBeacon(
    borderlessProxy as BorderlessProxy,
    lets_jp_llc_non_exeBeaconAddress,
    lets_jp_llc_saleBeaconAddress
  );

  // ============================================== //
  // Return
  // ============================================== //

  return {
    deployer,
    founder,
    executiveMember,
    executiveMember2,
    executiveMember3,
    tokenMinter,
    borderlessProxy,
    dictionary,
    scrImplementation,
    sctBeacon,
    serviceFactoryImplementation,
    scrBeaconUpgradeable,
    serviceFactoryBeaconUpgradeableImplementation,
    scrInitializeImplementation,
    borderlessAccessControlImplementation,
    governanceBaseBeacon,
    aoiBeacon,
    letsBaseBeacon,
    letsNonExeBaseBeacon,
    letsSaleBaseBeacon,
    sc_jp_dao_llcBeacon,
    governance_jp_llcBeacon,
    lets_jp_llc_exeBeacon,
    lets_jp_llc_non_exeBeacon,
    lets_jp_llc_saleBeacon,
  };
};
