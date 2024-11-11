import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import "@openzeppelin/hardhat-upgrades";
import { deploy, deployUUPS, deployBeacon, deployBeaconProxy, verify } from "../scripts/common";

const deployBorderlessCompanyContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  // const { deployer } = await hre.getNamedAccounts();

  // -- Reserve -- //
  const { proxyContractAddress: reserveContractAddress } = await deployUUPS(hre, "Reserve");

  // -- Register -- //
  const { contractAddress: borderlessCompanyAddress } = await deploy(hre, "BorderlessCompany");
  const { proxyContract: registerBorderlessCompany, proxyContractAddress: registerBorderlessCompanyAddress } =
    await deployUUPS(hre, "RegisterBorderlessCompany", [borderlessCompanyAddress, reserveContractAddress]);

  // -- Service Factory Pool -- //
  const {
    beacon: factoryPoolBeacon,
    ContractFactory: FactoryPoolContractFactory,
    beaconAddress: factoryPoolBeaconAddress,
  } = await deployBeacon(hre, "FactoryPool");
  const { proxy: factoryPoolBeaconProxy, proxyAddress: factoryPoolBeaconProxyAddress } = await deployBeaconProxy(
    hre,
    factoryPoolBeacon,
    FactoryPoolContractFactory,
    [registerBorderlessCompanyAddress],
  );

  await registerBorderlessCompany.setFactoryPool(factoryPoolBeaconProxyAddress);

  // -- Governance Service -- //
  const { contractAddress: governanceServiceAddress } = await deploy(hre, "GovernanceService");
  const { proxyContractAddress: governanceServiceFactoryAddress } = await deployUUPS(hre, "GovernanceServiceFactory", [
    governanceServiceAddress,
    registerBorderlessCompanyAddress,
  ]);

  // -- Treasury Service -- //
  const { contractAddress: treasuryServiceAddress } = await deploy(hre, "TreasuryService");
  const { proxyContractAddress: treasuryServiceFactoryAddress } = await deployUUPS(hre, "TreasuryServiceFactory", [
    treasuryServiceAddress,
    registerBorderlessCompanyAddress,
  ]);

  // -- Token Service -- //
  const { contractAddress: tokenServiceAddress } = await deploy(hre, "TokenService");
  const { proxyContractAddress: tokenServiceFactoryAddress } = await deployUUPS(hre, "TokenServiceFactory", [
    tokenServiceAddress,
    registerBorderlessCompanyAddress,
  ]);

  await factoryPoolBeaconProxy.setService(governanceServiceFactoryAddress, 1); // index = 1 GovernanceService
  await factoryPoolBeaconProxy.setService(treasuryServiceFactoryAddress, 2); // index = 2 TreasuryService
  await factoryPoolBeaconProxy.setService(tokenServiceFactoryAddress, 3); // index = 3 TokenService

  // -- Activate Service Address -- //
  await factoryPoolBeaconProxy["updateService(address,uint256,bool)"](governanceServiceFactoryAddress, 1, true); // index = 1 GovernanceService
  await factoryPoolBeaconProxy["updateService(address,uint256,bool)"](treasuryServiceFactoryAddress, 2, true); // index = 2 TreasuryService
  await factoryPoolBeaconProxy["updateService(address,uint256,bool)"](tokenServiceFactoryAddress, 3, true); // index = 3 TokenService

  // -- Log -- //
  console.log("--------------------------------");
  const explorerBaseUrl = "https://sepolia-explorer.metisdevops.link/address/";

  console.log("|Service|Implementation Address|Proxy Address|Explorer Link|");
  console.log("|--------|----------------------|-------------|-------------|");

  console.log("|Reserve Contract|-|", reserveContractAddress, "|", explorerBaseUrl + reserveContractAddress, "|");
  console.log(
    "|Borderless Company|",
    borderlessCompanyAddress,
    "|",
    registerBorderlessCompanyAddress,
    "|",
    explorerBaseUrl + registerBorderlessCompanyAddress,
    "|",
  );
  console.log(
    "|Factory Pool Beacon|",
    factoryPoolBeaconAddress,
    "|",
    factoryPoolBeaconProxyAddress,
    "|",
    explorerBaseUrl + factoryPoolBeaconProxyAddress,
    "|",
  );
  console.log(
    "|Governance Service|",
    governanceServiceAddress,
    "|",
    governanceServiceFactoryAddress,
    "|",
    explorerBaseUrl + governanceServiceFactoryAddress,
    "|",
  );
  console.log(
    "|Treasury Service|",
    treasuryServiceAddress,
    "|",
    treasuryServiceFactoryAddress,
    "|",
    explorerBaseUrl + treasuryServiceFactoryAddress,
    "|",
  );
  console.log(
    "|Token Service|",
    tokenServiceAddress,
    "|",
    tokenServiceFactoryAddress,
    "|",
    explorerBaseUrl + tokenServiceFactoryAddress,
    "|",
  );
  console.log("--------------------------------");

  // -- Verify -- //
  console.log(`hre.network.name: ${hre.network.name}`);
  if (hre.network.name !== "localhost") {
    await verify(hre, reserveContractAddress, []);
    await verify(hre, registerBorderlessCompanyAddress, []);
    await verify(hre, factoryPoolBeaconProxyAddress, []);
    await verify(hre, governanceServiceFactoryAddress, []);
    await verify(hre, treasuryServiceFactoryAddress, []);
    await verify(hre, tokenServiceFactoryAddress, []);
  }
};

export default deployBorderlessCompanyContract;

deployBorderlessCompanyContract.tags = ["DeployBorderlessCompanyContract"];
