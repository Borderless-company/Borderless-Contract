import "@openzeppelin/hardhat-upgrades";
import { printTable } from "console-table-printer";
import { BytesLike, ethers } from "ethers";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { deploy, deployUUPS, verify } from "../scripts/common";

const deployVoteContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  // -- Vote -- //
  const { proxyContractAddress: voteContractAddress } = await deployUUPS(hre, "Vote");
  const vote = await hre.ethers.getContractAt("Vote", voteContractAddress);

  // Log contract addresses
  printTable([
    { ContractName: "Vote", Address: voteContractAddress },
  ]);

  // -- Verify Contracts -- //
  if (hre.network.name !== "localhost") {
    await verify(hre, voteContractAddress, []);
  }
};

export default deployVoteContract;

deployVoteContract.tags = ["DeployVoteContract"];
