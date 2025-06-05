import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";
import { expect } from "chai";
import { SCR, SCRBeaconUpgradeable } from "../../typechain-types";
import { getDeploySmartCompanyAddress } from "./Event";
import { letsEncodeParams } from "../../utils/Encode";
import { deployFullFixture } from "./DeployFixture";

export const createCompany = async () => {
  // ============================================== //
  const {
    founder,
    proxy,
    scrBeacon,
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

  // get company info from logs
  const scInfo = getDeploySmartCompanyAddress(receipt);
  const companyAddress = scInfo.beaconAddress;
  const services = scInfo.services;

  // get company info from contract
  const scId = await scrConn.getSmartCompanyId(founder.address);
  const scCompanyInfo = await scrConn.getCompanyInfo(scId);

  // Assertions
  expect(companyAddress).to.match(/^0x[0-9a-fA-F]{40}$/);
  expect(scCompanyInfo.companyAddress).to.equal(companyAddress);
  expect(scCompanyInfo.founder).to.equal(founder.address);
  expect(scCompanyInfo.companyName).to.equal(companyName);
  expect(scCompanyInfo.establishmentDate).to.equal(establishmentDate);
  expect(scCompanyInfo.jurisdiction).to.equal(jurisdiction);
  expect(scCompanyInfo.entityType).to.equal(entityType);
  if (!companyAddress) throw new Error("Company address not found in logs");

  // get beacon info from contract
  const scrBeaconUpgradeableConn = (
    await ethers.getContractAt("SCRBeaconUpgradeable", await proxy.getAddress())
  ).connect(founder) as SCRBeaconUpgradeable;
  const beaconInfo = await scrBeaconUpgradeableConn.getSCRBeacon(
    sctBeaconAddress ?? ""
  );

  console.log("beaconInfo name", beaconInfo.name);
  console.log("beaconInfo isOnline", beaconInfo.isOnline);
  console.log("beaconInfo implementation", beaconInfo.implementation);

  // Assertions
  expect(beaconInfo.name).to.equal("SC_JP_DAOLLC");
  expect(beaconInfo.isOnline).to.be.true;
  expect(beaconInfo.implementation).to.not.equal(
    "0x0000000000000000000000000000000000000000"
  );

  console.log("✅ createSmartCompany が成功");

  return {
    companyAddress,
    services,
  };
};
