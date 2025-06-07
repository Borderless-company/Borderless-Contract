import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import {
  BorderlessAccessControl,
  BorderlessProxy,
} from "../../typechain-types";
import { ethers } from "hardhat";

export const grantMinterRole = async (
  deployer: HardhatEthersSigner,
  borderlessProxy: BorderlessProxy,
  account: HardhatEthersSigner
) => {
  const scrAccessControlConn = (
    await ethers.getContractAt(
      "BorderlessAccessControl",
      await borderlessProxy.getAddress()
    )
  ).connect(deployer) as BorderlessAccessControl;

  const MINTER_ROLE =
    "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6";
  await scrAccessControlConn.grantRole(MINTER_ROLE, await account.getAddress());
};

export const grantFounderRole = async (
  deployer: HardhatEthersSigner,
  borderlessProxy: BorderlessProxy,
  account: HardhatEthersSigner
) => {
  const borderlessAccessControlConn = (
    await ethers.getContractAt(
      "BorderlessAccessControl",
      await borderlessProxy.getAddress()
    )
  ).connect(deployer) as BorderlessAccessControl;
  const founderRole =
    "0x7ed687a8f2955bd2ba7ca08227e1e364d132be747f42fb733165f923021b0225";
  await borderlessAccessControlConn.grantRole(
    founderRole,
    await account.getAddress()
  );
};
