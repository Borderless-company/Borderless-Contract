import "@openzeppelin/hardhat-upgrades";
import { printTable } from "console-table-printer";
import { BytesLike, ethers } from "ethers";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { deploy, deployUUPS, verify } from "../scripts/common";

function encodeParams(
  _name: string,
  _symbol: string,
  _baseURI: string,
  _extension: string,
  _governance: string,
): BytesLike {
  return ethers.AbiCoder.defaultAbiCoder().encode(
    ["string", "string", "string", "string", "address"],
    [_name, _symbol, _baseURI, _extension, _governance],
  );
}

const deployBorderlessCompanyContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  // -- ServiceFactory -- //
  const { proxyContractAddress: serviceFactoryAddress } = await deployUUPS(hre, "ServiceFactory");
  const serviceFactory = await hre.ethers.getContractAt("ServiceFactory", serviceFactoryAddress);

  // -- SCR -- //
  const { proxyContractAddress: scrContractAddress } = await deployUUPS(hre, "SCR", [serviceFactoryAddress]);
  const scr = await hre.ethers.getContractAt("SCR", scrContractAddress);

  // Set SCR contract in ServiceFactory
  await serviceFactory.setSCR(scrContractAddress);

  // -- SC_JP_DAOLLC -- //
  const { contractAddress: scJpDaollcContractAddress } = await deploy(hre, "SC_JP_DAOLLC");
  await hre.ethers.getContractAt("SC_JP_DAOLLC", scJpDaollcContractAddress);

  // -- LETS_JP_LLC_EXE -- //
  const { contractAddress: letsJpLlcExeContractAddress } = await deploy(hre, "LETS_JP_LLC_EXE");
  await hre.ethers.getContractAt("LETS_JP_LLC_EXE", letsJpLlcExeContractAddress);

  // -- LETS_JP_LLC_NON_EXE -- //
  const { contractAddress: letsJpLlcNonExeContractAddress } = await deploy(hre, "LETS_JP_LLC_NON_EXE");
  await hre.ethers.getContractAt("LETS_JP_LLC_NON_EXE", letsJpLlcNonExeContractAddress);

  // -- Governance_JP_LLC -- //
  const { contractAddress: governanceJpLlcContractAddress } = await deploy(hre, "Governance_JP_LLC");
  await hre.ethers.getContractAt("Governance_JP_LLC", governanceJpLlcContractAddress);

  // Set Services in ServiceFactory
  await serviceFactory.setService(
    letsJpLlcExeContractAddress,
    "LETS_JP_LLC_EXE",
    2, // LETS_EXE = 2
  );
  await serviceFactory.setService(
    letsJpLlcNonExeContractAddress,
    "LETS_JP_LLC_NON_EXE",
    3, // LETS_NON_EXE = 3
  );
  await serviceFactory.setService(
    governanceJpLlcContractAddress,
    "Governance_JP_LLC",
    1, // GOVERNANCE = 1
  );

  // -- SCR functions -- //
  await scr.setSCContract(scJpDaollcContractAddress, "SC_JP_DAOLLC");
  await scr.addCompanyInfoFields("SC_JP_DAOLLC", "zip_code");
  await scr.addCompanyInfoFields("SC_JP_DAOLLC", "prefecture");
  await scr.addCompanyInfoFields("SC_JP_DAOLLC", "city");
  await scr.addCompanyInfoFields("SC_JP_DAOLLC", "address");

  const founderRole = await scr.FOUNDER_ROLE();
  await scr.grantRole(founderRole, "0x9caafedf5cd9d889694291211015617058280a36");
  await scr.grantRole(founderRole, "0xb69cb3efbadb1b30f6d88020e1fa1fc84b8804d4");
  await scr.grantRole(founderRole, "0x086e86a04f0fe7c50c60e4bc0dcb8e50bbbefcbf");
  await scr.grantRole(founderRole, "0xAe451f1873B4C4D7263631Bf0ea141D54Ba39eEa");
  const deployer = (await hre.getNamedAccounts())["deployer"];
  await scr.grantRole(founderRole, deployer);

  const scid = ethers.toUtf8Bytes("TEST_DAO");
  const legalEntityCode = "SC_JP_DAOLLC";
  const companyName = "Test DAO Company";
  const establishmentDate = "2024-01-01";
  const jurisdiction = "JP";
  const entityType = "LLC";
  const scExtraParams = ethers.toUtf8Bytes("");
  const otherInfo = ["100-0001", "Tokyo", "Shinjuku-ku", "Shinjuku 1-1-1"];
  const scsAddresses = [governanceJpLlcContractAddress, letsJpLlcExeContractAddress, letsJpLlcNonExeContractAddress];
  const scsExtraParams = [
    "0x",
    encodeParams(
      "LETS_JP_LLC_EXE",
      "LETS_JP_LLC_EXE",
      "https://example.com/metadata/",
      ".json",
      governanceJpLlcContractAddress,
    ),
    encodeParams(
      "LETS_JP_LLC_NON_EXE",
      "LETS_JP_LLC_NON_EXE",
      "https://example.com/metadata/",
      ".json",
      governanceJpLlcContractAddress,
    ),
  ];

  await scr.createSmartCompany(
    scid,
    scJpDaollcContractAddress,
    legalEntityCode,
    companyName,
    establishmentDate,
    jurisdiction,
    entityType,
    scExtraParams,
    otherInfo,
    scsAddresses,
    scsExtraParams,
  );

  // Log contract addresses
  printTable([
    { ContractName: "ServiceFactory", Address: serviceFactoryAddress },
    { ContractName: "SCR", Address: scrContractAddress },
    { ContractName: "SC_JP_DAOLLC", Address: scJpDaollcContractAddress },
    { ContractName: "LETS_JP_LLC_EXE", Address: letsJpLlcExeContractAddress },
    { ContractName: "LETS_JP_LLC_NON_EXE", Address: letsJpLlcNonExeContractAddress },
    { ContractName: "Governance_JP_LLC", Address: governanceJpLlcContractAddress },
  ]);

  // -- Verify Contracts -- //
  if (hre.network.name !== "localhost") {
    await verify(hre, serviceFactoryAddress, []);
    await verify(hre, scrContractAddress, []);
    await verify(hre, scJpDaollcContractAddress, []);
    await verify(hre, letsJpLlcExeContractAddress, []);
    await verify(hre, letsJpLlcNonExeContractAddress, []);
    await verify(hre, governanceJpLlcContractAddress, []);
  }
};

export default deployBorderlessCompanyContract;

deployBorderlessCompanyContract.tags = ["DeployBorderlessCompanyContract"];
