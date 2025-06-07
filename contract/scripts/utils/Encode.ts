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

export const kibotchaLetsEncodeParams = (
  name: string,
  symbol: string,
  baseURI: string,
  extension: string,
  isMetadataFixed: boolean,
  maxSupply: number,
  baseTokenId: number
): string => {
  return ethers.AbiCoder.defaultAbiCoder().encode(
    ["string", "string", "string", "string", "bool", "uint256", "uint256"],
    [name, symbol, baseURI, extension, isMetadataFixed, maxSupply, baseTokenId]
  );
};