import hre from "hardhat";
import { Contract, ContractRunner } from "ethers";

export const setBorderlessAccessControlOnceInitialized = async (
  dictionary: Contract,
  deployerWallet: ContractRunner,
  accessControlFacet: Contract
) => {
  const dictionaryConn = await hre.ethers.getContractAt(
    "Dictionary",
    dictionary.target ?? ""
  );
  await dictionaryConn
    .connect(deployerWallet)
    .setOnceInitialized(
      await accessControlFacet.getAddress(),
      await accessControlFacet.getAddress()
    );

  console.log("✅ Done setOnceInitialized");
};