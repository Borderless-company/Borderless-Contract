import { ethers } from "hardhat";

export const encodeParams = (
  name: string,
  symbol: string,
  baseURI: string,
  extension: string
): string => {
  return ethers.AbiCoder.defaultAbiCoder().encode(
    ["string", "string", "string", "string"],
    [name, symbol, baseURI, extension]
  );
};
