import hre from "hardhat";
import { Contract } from "ethers";
import { SCR } from "../typechain-types";

export const addCompanyInfoFields = async (
  scr: Contract,
  companyName: string,
  field: string
) => {
  const scrConn = await hre.ethers.getContractAt("SCR", scr.target ?? "");
  await addCompanyInfoField(scrConn, companyName, "zip_code");
  await addCompanyInfoField(scrConn, companyName, "prefecture");
  await addCompanyInfoField(scrConn, companyName, "city");
  await addCompanyInfoField(scrConn, companyName, "address");

  console.log("✅ Set CompanyInfoFields");
};

export const addCompanyInfoField = async (
  scrConn: SCR,
  companyName: string,
  field: string
) => {
  await scrConn.addCompanyInfoFields(companyName, field);

  console.log("✅ Set CompanyInfoFields");
};
