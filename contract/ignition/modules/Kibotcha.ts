import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { BorderlessModule } from "./Borderless";

export const KibotchaModule = buildModule("KibotchaModule", (m) => {
  const kibotcha = m.contract("KIBOTCHA_LETS_JP_LLC_NON_EXE", []);

  return {
    kibotcha,
  };
});

export const RegisterKibotchaModule = buildModule(
  "RegisterKibotchaModule",
  (m) => {
    const serviceName = m.getParameter<string>("ServiceName", "");
    const serviceType = m.getParameter<number>("ServiceType", 0);
    const { proxy } = m.useModule(BorderlessModule);
    const kibotcha = m.useModule(KibotchaModule);
    const serviceFactoryConn = m.contractAt("ServiceFactory", proxy);
    const setServiceTx = m.call(serviceFactoryConn, "setService", [
      kibotcha.kibotcha,
      serviceName,
      serviceType,
    ]);
    const serviceBeaconAddress = m.readEventArgument(
      setServiceTx,
      "DeployBeaconProxy",
      0
    );
    const serviceBeaconConn = m.contractAt(
      "UpgradeableBeacon",
      serviceBeaconAddress
    );
    return {
      proxy,
      serviceBeaconConn,
    };
  }
);
