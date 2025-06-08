import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";
import { expect } from "chai";
import { SCR, SCRBeaconUpgradeable } from "../../typechain-types";
import { getDeploySmartCompanyAddress } from "./Event";
import { letsEncodeParams } from "../../scripts/utils/Encode";
import { deployJP_DAO_LLCFullFixture } from "./DeployFixture";

export const createCompany = async (
  scsBeaconProxy?: string[]
) => {
  // ============================================== //
  const {
    founder,
    borderlessProxy,
    sc_jp_dao_llcBeacon,
    governance_jp_llcBeacon,
    aoiBeacon,
    lets_jp_llc_exeBeacon,
    lets_jp_llc_non_exeBeacon,
  } = await loadFixture(deployJP_DAO_LLCFullFixture);
  // ============================================== //
  // Prepare parameters
  // ============================================== //

  const scid = 1234567890;
  const legalEntityCode = "SC_JP_DAO_LLC";
  const companyName = "Test DAO Company";
  const establishmentDate = "2024-01-01";
  const jurisdiction = "JP";
  const entityType = "LLC";
  const scDeployParam = "0x";
  const companyInfo = ["100-0001", "Tokyo", "Shinjuku-ku", "Shinjuku 1-1-1"];
  const defaultScsBeaconProxy = [
    await governance_jp_llcBeacon.getAddress(),
    await lets_jp_llc_exeBeacon.getAddress(),
    await lets_jp_llc_non_exeBeacon.getAddress(),
    await aoiBeacon.getAddress(),
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
    "0x"
  ];

  console.log("✅ prepare params");

  // ============================================== //
  // Execute createSmartCompany
  // ============================================== //

  const scrConn = (
    await ethers.getContractAt("SCR", await borderlessProxy.getAddress())
  ).connect(founder) as SCR;

  const call = await scrConn.createSmartCompany(
    scid.toString(),
    sc_jp_dao_llcBeacon,
    legalEntityCode,
    companyName,
    establishmentDate,
    jurisdiction,
    entityType,
    scDeployParam,
    companyInfo,
    scsBeaconProxy || defaultScsBeaconProxy,
    scsExtraParams
  );
  const receipt = await call.wait();

  // get company info from logs
  const scInfo = getDeploySmartCompanyAddress(receipt);
  const companyAddress = scInfo.beaconAddress;
  console.log("✅ companyAddress", companyAddress);
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
    await ethers.getContractAt("SCRBeaconUpgradeable", await borderlessProxy.getAddress())
  ).connect(founder) as SCRBeaconUpgradeable;
  const beaconInfo = await scrBeaconUpgradeableConn.getSCRBeacon(
    sc_jp_dao_llcBeacon
  );

  // Assertions
  expect(beaconInfo.name).to.equal("SC_JP_DAO_LLC");
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
