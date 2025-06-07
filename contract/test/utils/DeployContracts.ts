import { ethers } from "hardhat";
import { Dictionary, SCT } from "../../typechain-types";
import { addresses } from "./DeployFixture";

export const deployContract = async (contractName: string) => {
  const Contract = await ethers.getContractFactory(contractName);
  const contract = await Contract.deploy();
  await contract.waitForDeployment();
  console.log("✅ Deployed", contractName, await contract.getAddress());
  return { contract, Contract };
};

export const deployContractWithArgs = async (contractName: string, args: any[]) => {
  const Contract = await ethers.getContractFactory(contractName);
  const contract = await Contract.deploy(...args);
  await contract.waitForDeployment();
  console.log("✅ Deployed", contractName, await contract.getAddress());
  return { contract, Contract };
};

export const deployDictionary = async () => {
  const { deployer } = await addresses();
  const { contract: dictionary, Contract: Dictionary } = await deployContractWithArgs("Dictionary", [await deployer.getAddress()]);
  return { contract: dictionary as Dictionary, Contract: Dictionary };
};

export const deploySCR = async () => {
  return await deployContract("SCR");
};

export const deployBorderlessAccessControl = async () => {
  return await deployContract("BorderlessAccessControl");
};

export const deploySCRBeaconUpgradeable = async () => {
  return await deployContract("SCRBeaconUpgradeable");
};

export const deployServiceFactoryBeaconUpgradeable = async () => {
  return await deployContract("ServiceFactoryBeaconUpgradeable");
};

export const deployServiceFactory = async () => {
  return await deployContract("ServiceFactory");
};

export const deploySCRInitialize = async () => {
  return await deployContract("SCRInitialize");
};

export const deployBorderlessProxy = async (dictionary: Dictionary) => {
  return await deployContractWithArgs("BorderlessProxy", [dictionary.getAddress(), "0x"]);
};

export const deploySCT = async () => {
  const { contract: sct } = await deployContract("SCT");
  return { contract: sct as SCT };
};

// Services
export const deployGovernanceBase = async () => {
  return await deployContract("GovernanceBase");
};

export const deployAOI = async () => {
  return await deployContract("AOI");
};

export const deployLETSBase = async () => {
  return await deployContract("LETSBase");
};

export const deployLETSSaleBase = async () => {
  return await deployContract("LETSSaleBase");
};

// LETS_JP_LLC
export const deploySC_JP_DAO_LLC = async () => {
  return await deployContract("SC_JP_DAO_LLC");
};

export const deployGovernance_JP_LLC = async () => {
  return await deployContract("Governance_JP_LLC");
};

export const deployLETS_JP_LLC_EXE = async () => {
  return await deployContract("LETS_JP_LLC_EXE");
};

export const deployLETS_JP_LLC_NON_EXE = async () => {
  return await deployContract("LETS_JP_LLC_NON_EXE");
};

export const deployLETSSale_JP_LLC = async () => {
  return await deployContract("LETS_JP_LLC_SALE");
};