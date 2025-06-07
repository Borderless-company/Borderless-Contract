import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { BorderlessProxy, LETS_JP_LLC_EXE, LETS_JP_LLC_NON_EXE } from "../../typechain-types";
import { ethers } from "hardhat";
import { expect } from "chai";

export const setLetsSaleBeacon = async (
  lets: BorderlessProxy,
  lets_jp_llc_exeBeaconAddress: string,
  lets_jp_llc_saleBeaconAddress: string
) => {
  const serviceFactory = await ethers.getContractAt(
    "ServiceFactory",
    await lets.getAddress()
  );
  await serviceFactory.setLetsSaleBeacon(
    lets_jp_llc_exeBeaconAddress ?? "",
    lets_jp_llc_saleBeaconAddress ?? ""
  );
};

export const tokenMintFromTokenMinter = async (
  lets: LETS_JP_LLC_EXE | LETS_JP_LLC_NON_EXE,
  tokenMinter: HardhatEthersSigner,
  to: string
) => {
  await lets.connect(tokenMinter).getFunction("mint(address)")(to);
  expect(await lets.balanceOf(to)).to.equal(1);
};
