import { SCR, BorderlessProxy } from "../../typechain-types";
import { ethers } from "hardhat";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { getBeaconAddress } from "./Event";

export const setSCT = async (
  sct: any,
  proxy: BorderlessProxy,
  deployer: HardhatEthersSigner,
  scName: string
) => {
  const scrConn = (
    await ethers.getContractAt("SCR", await proxy.getAddress())
  ).connect(deployer) as SCR;
  const tx = await scrConn.setSCContract(await sct.getAddress(), scName);
  const receipt = await tx.wait();
  const sctBeacon = getBeaconAddress(receipt);
  return sctBeacon || "";
};

export const setCompanyInfoFields = async (
  proxy: BorderlessProxy,
  deployer: HardhatEthersSigner,
  scName: string,
  companyInfoFields: string[]
) => {
  const scrConn = (
    await ethers.getContractAt("SCR", await proxy.getAddress())
  ).connect(deployer);
  for (const companyInfoField of companyInfoFields) {
    await scrConn.addCompanyInfoFields(scName, companyInfoField);
  }

  console.log("✅ Set CompanyInfoFields");
};
