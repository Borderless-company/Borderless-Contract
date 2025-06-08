import { network } from "hardhat";

// set time
export const setTime = async (timestamp: number) => {
  await network.provider.send("evm_setNextBlockTimestamp", [timestamp]);
  await network.provider.send("evm_mine");
};
