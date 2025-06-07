import { ethers } from "hardhat";
import { BorderlessProxy } from "../../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { getBeaconAddress } from "./Event";

export const setService = async (
  borderlessProxy: BorderlessProxy,
  deployer: HardhatEthersSigner,
  serviceBeaconAddress: string,
  serviceName: string,
  serviceType: number
) => {
  const serviceFactoryConn = (
    await ethers.getContractAt(
      "ServiceFactory",
      await borderlessProxy.getAddress()
    )
  ).connect(deployer);
  const beacon = await serviceFactoryConn.setService(
    serviceBeaconAddress,
    serviceName,
    serviceType
  );
  const beaconReceipt = await beacon.wait();
  const beaconAddress = getBeaconAddress(beaconReceipt);
  console.log("✅ Set Service", beaconAddress);
  return beaconAddress || "";
};
