import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Contract, ContractFactory } from "ethers";
import "@openzeppelin/hardhat-upgrades";

export const deploy = async function (
  hre: HardhatRuntimeEnvironment,
  contractName: string,
  args: object = {},
): Promise<{ ContractFactory: any; contract: Contract; contractAddress: string }> {
  const factory: any = (await hre.ethers.getContractFactory(contractName)) as ContractFactory;
  const contract = await factory.deploy(args);
  await contract.waitForDeployment();
  const contractAddress = await contract.getAddress();
  return { ContractFactory, contract, contractAddress };
};

export const deployUUPS = async function (
  hre: HardhatRuntimeEnvironment,
  contractName: string,
  args: Array<any> = [],
): Promise<{ ContractFactory: any; proxyContract: Contract; proxyContractAddress: string }> {
  const ContractFactory: any = await hre.ethers.getContractFactory(contractName);
  const proxyContract = await hre.upgrades.deployProxy(ContractFactory, args, {
    initializer: "initialize",
    kind: "uups",
  });
  await proxyContract.waitForDeployment();
  const proxyContractAddress = await proxyContract.getAddress();
  return { ContractFactory, proxyContract, proxyContractAddress };
};

export const deployBeacon = async function (
  hre: HardhatRuntimeEnvironment,
  contractName: string,
): Promise<{ ContractFactory: any; beacon: Contract; beaconAddress: string }> {
  const ContractFactory: any = await hre.ethers.getContractFactory(contractName);
  const beacon = await hre.upgrades.deployBeacon(ContractFactory);
  await beacon.waitForDeployment();
  const beaconAddress = await beacon.getAddress();
  return { ContractFactory, beacon, beaconAddress };
};

export const deployBeaconProxy = async function (
  hre: HardhatRuntimeEnvironment,
  beacon: Contract,
  contractFactory: ContractFactory,
  args: any[],
): Promise<{ proxy: Contract; proxyAddress: string }> {
  const proxy = await hre.upgrades.deployBeaconProxy(beacon, contractFactory, args);
  await proxy.waitForDeployment();
  const proxyAddress = await proxy.getAddress();
  return { proxy, proxyAddress };
};

export const verify = async function (hre: HardhatRuntimeEnvironment, address: string, args: any[]) {
  try {
    await hre.run("verify:verify", {
      address: address,
      constructorArguments: args,
    });
  } catch (error) {
    console.log("👾 verify:verify error:", error);
  }
};
