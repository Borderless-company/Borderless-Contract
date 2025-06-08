import { Contract, FunctionFragment } from "ethers";
import { Dictionary } from "../../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import hre from "hardhat";

export const setOnceInitialized = async (
  dictionary: Dictionary,
  deployer: HardhatEthersSigner,
  caller: string,
  implementation: string
) => {
  await dictionary
    .connect(deployer)
    .setOnceInitialized(
      caller,
      implementation
    );
};

export const registerFacets = async (
    dictionary: Dictionary,
    factory: Awaited<ReturnType<typeof hre.ethers.getContractFactory>>,
    implAddress: string
  ) => {
    const selectors = [];
    for (const frag of factory.interface.fragments) {
      if (!(frag instanceof FunctionFragment)) continue;
      const selector = FunctionFragment.getSelector(
        frag.name,
        frag.inputs.map((i) => i.type)
      );
      selectors.push(selector);
    }
    await dictionary.getFunction("bulkSetImplementation(bytes4[],address)")(
      selectors,
      implAddress
    );
  };
