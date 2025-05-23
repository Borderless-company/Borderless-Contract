import { ethers } from "hardhat";
import { Dictionary } from "../../typechain-types";
import { FunctionFragment } from "ethers";

export const registerFunctions = async (
  dictionary: Dictionary,
  factory: Awaited<ReturnType<typeof ethers.getContractFactory>>,
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
