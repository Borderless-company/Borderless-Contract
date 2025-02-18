import "@openzeppelin/hardhat-upgrades";
import { printTable } from "console-table-printer";
import { BytesLike, ethers } from "ethers";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { deploy, deployUUPS, verify } from "../scripts/common";

const upgradeExeNft: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  // deploy new implementation
  const { contractAddress: exeNftContractAddress } = await deploy(hre, "LETS_JP_LLC_EXE");

  const beaconAddress = "0xecf9332d1cde6162fd30b8a397d6e73d8b6c67ae";

  // upgrade
  const beacon = await hre.ethers.getContractAt("UpgradeableBeacon", beaconAddress);
  const tx = await beacon.upgradeTo(exeNftContractAddress);
  await tx.wait();

  // Log contract addresses
  printTable([{ ContractName: "LETS_JP_LLC_EXE", Address: exeNftContractAddress }]);
  printTable([{ ContractName: "UpgradeableBeacon", Address: beaconAddress }]);

  // -- Verify Contracts -- //
  if (hre.network.name !== "localhost") {
    await verify(hre, exeNftContractAddress, []);
    await verify(hre, beaconAddress, []);
  }
};

export default upgradeExeNft;

upgradeExeNft.tags = ["UpgradeExeNft"];
