import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { LETS_JP_LLC_EXE, LETS_JP_LLC_NON_EXE } from "../../typechain-types";
import { expect } from "chai";

export const tokenMintFromTokenMinter = async (
  lets: LETS_JP_LLC_EXE | LETS_JP_LLC_NON_EXE,
  tokenMinter: HardhatEthersSigner,
  to: string
) => {
  await lets.connect(tokenMinter).getFunction("mint(address)")(to);
  expect(await lets.balanceOf(to)).to.equal(1);
};
