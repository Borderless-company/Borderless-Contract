import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";
import { expect } from "chai";
import { SCR } from "../../typechain-types";
import { getDeploySmartCompanyAddress } from "./Event";
import { letsEncodeParams } from "../../utils/Encode";
import { deployFullFixture } from "./DeployFixture";

export const createCompany = async () => {
  // ============================================== //
  const {
    proxy,
    founder,
    sctBeaconAddress,
    lets_jp_llc_exeBeaconAddress,
    lets_jp_llc_non_exeBeaconAddress,
    governance_jp_llcBeaconAddress,
  } = await loadFixture(deployFullFixture);
  // ============================================== //
  // パラメータの準備
  // ============================================== //

  const scid = 1234567890;
  const legalEntityCode = "SC_JP_DAOLLC";
  const companyName = "Test DAO Company";
  const establishmentDate = "2024-01-01";
  const jurisdiction = "JP";
  const entityType = "LLC";
  const scDeployParam = "0x";
  const companyInfo = ["100-0001", "Tokyo", "Shinjuku-ku", "Shinjuku 1-1-1"];
  const scsBeaconProxy = [
    governance_jp_llcBeaconAddress,
    lets_jp_llc_exeBeaconAddress,
    lets_jp_llc_non_exeBeaconAddress,
  ];

  const scsExtraParams = [
    "0x",
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
  // createSmartCompany の実行
  // ============================================== //

  const scrConn = (
    await ethers.getContractAt("SCR", await proxy.getAddress())
  ).connect(founder) as SCR;

  const call = await scrConn.createSmartCompany(
    scid.toString(),
    sctBeaconAddress,
    legalEntityCode,
    companyName,
    establishmentDate,
    jurisdiction,
    entityType,
    scDeployParam,
    companyInfo,
    scsBeaconProxy,
    scsExtraParams
  );
  const receipt = await call.wait();

  const scInfo = getDeploySmartCompanyAddress(receipt);
  const companyAddress = scInfo.beaconAddress;
  const services = scInfo.services;

  const scId = await scrConn.getSmartCompany(founder.address);
  const scCompanyInfo = await scrConn.getCompanyInfo(scId);

  // アサーション
  expect(companyAddress).to.match(/^0x[0-9a-fA-F]{40}$/);
  expect(scCompanyInfo.companyAddress).to.equal(companyAddress);
  if (!companyAddress) throw new Error("Company address not found in logs");

  console.log("✅ createSmartCompany が成功");

  return {
    companyAddress,
    services,
  };
};
