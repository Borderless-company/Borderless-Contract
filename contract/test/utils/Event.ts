import { Interface } from "ethers";
import { SCR__factory } from "../../typechain-types";

export const getBeaconAddress = (receipt: any | null) => {
  const iface = new Interface(SCR__factory.abi);
  let beaconAddress: string | undefined = undefined;

  for (const log of receipt?.logs ?? []) {
    try {
      const parsed = iface.parseLog(log);
      if (parsed?.name === "DeployBeaconProxy") {
        beaconAddress = parsed?.args[0]; // 例: address beacon
        break;
      }
    } catch (e) {
      // 対象外のイベントは無視
    }
  }

  return beaconAddress;
};

export const getDeploySmartCompanyAddress = (receipt: any | null) => {
  const iface = new Interface(SCR__factory.abi);
  let beaconAddress: string | undefined = undefined;
  let services: string[] = [];
  let serviceTypes: number[] = [];

  for (const log of receipt?.logs ?? []) {
    try {
      const parsed = iface.parseLog(log);
      if (parsed?.name === "DeploySmartCompany") {
        beaconAddress = parsed?.args[1]; // 例: address beacon
        services = parsed?.args[3];
        serviceTypes = parsed?.args[4];
        break;
      }
    } catch (e) {
      // 対象外のイベントは無視
    }
  }

  return { beaconAddress, services, serviceTypes };
};
