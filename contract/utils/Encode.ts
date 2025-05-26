import { ethers } from "hardhat";

export const letsEncodeParams = (
  name: string,
  symbol: string,
  baseURI: string,
  extension: string,
  isMetadataFixed: boolean,
  maxSupply: number
): string => {
  return ethers.AbiCoder.defaultAbiCoder().encode(
    ["string", "string", "string", "string", "bool", "uint256"],
    [name, symbol, baseURI, extension, isMetadataFixed, maxSupply]
  );
};
