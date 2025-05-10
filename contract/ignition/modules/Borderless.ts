import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export const BorderlessModule = buildModule("BorderlessModule", (m) => {
  // ────────────────────────────────────────────────
  // 必要に応じてオーナーアドレスなどをパラメータ　で受け取れます
  // hardhat.config.ts の ignition: { params: { OWNER: "0x…" } } などで指定
  // ────────────────────────────────────────────────
  const deployer = m.getParameter<string>(
    "Deployer",
    ""
  );

  // ────────────────────────────────────────────────
  // １）Facet 実装を先に宣言（まだデプロイは行われません）
  // ────────────────────────────────────────────────
  const accessControlFacet = m.contract("BorderlessAccessControl", []);
  console.log("ok accessControlFacet");
  const addressManagerFacet = m.contract("AddressManager", []);
  console.log("ok addressManagerFacet");
  const scrBeaconFacet = m.contract("SCRBeaconUpgradeable", []);
  console.log("ok scrBeaconFacet");
  const sfBeaconFacet = m.contract("ServiceFactoryBeaconUpgradeable", []);
  console.log("ok sfBeaconFacet");
  const serviceFactoryFacet = m.contract("ServiceFactory", []);
  console.log("ok serviceFactoryFacet");
  const initializeFacet = m.contract("Initialize", [], {
    id: "Borderless_Initialize"
  });
  console.log("ok initializeFacet");
  const scrFacet = m.contract("SCR", []);
  console.log("ok scrFacet");

  // ────────────────────────────────────────────────
  // ２）Dictionary をデプロイ
  //    （コンストラクタでオーナーアドレス等を渡す場合は引数に）
  // ────────────────────────────────────────────────
  const dictionary = m.contract("Dictionary", [deployer]);

  // ────────────────────────────────────────────────
  // ３）Proxy をデプロイ
  //    constructor に Dictionary アドレスを渡します
  //    必要があれば initializer 名・引数・value も指定可能
  // ────────────────────────────────────────────────
  const proxy = m.contract("SCRProxy", [dictionary, "0x"]);

  // ────────────────────────────────────────────────
  // 4）SCT をデプロイ
  // ────────────────────────────────────────────────
  const sct = m.contract("SC_JP_DAOLLC", []);

  // ────────────────────────────────────────────────
  // 5）Serviceをデプロイ
  // ────────────────────────────────────────────────
  const governance_jp_llc = m.contract("Governance_JP_LLC", []);
  const lets_jp_llc_exe = m.contract("LETS_JP_LLC_EXE", []);
  const lets_jp_llc_non_exe = m.contract("LETS_JP_LLC_NON_EXE", []);
  const lets_jp_llc_sale = m.contract("LETS_JP_LLC_SALE", []);

  console.log(`✅ Done deploy`);

  return {
    accessControlFacet,
    addressManagerFacet,
    scrBeaconFacet,
    sfBeaconFacet,
    serviceFactoryFacet,
    initializeFacet,
    scrFacet,
    dictionary,
    proxy,
    sct,
    governance_jp_llc,
    lets_jp_llc_exe,
    lets_jp_llc_non_exe,
    lets_jp_llc_sale,
  };
});

export const InitializeModule = buildModule("InitializeModule", (m) => {
  const deployer = m.getParameter<string>(
    "Deployer",
    ""
  );
  const { proxy } = m.useModule(BorderlessModule);
  const initializeConn = m.contractAt("Initialize", proxy);
  m.call(initializeConn, "initialize", [deployer]);
  return {
    proxy,
    initializeConn
  };
});

export const RegisterSCTModule = buildModule("RegisterSCTModule", (m) => {
  const sctAddress = m.getParameter<string>(
    "SCTAddress",
    "0x0000000000000000000000000000000000000000"
  );
  const { proxy } = m.useModule(BorderlessModule);
  const scrConn = m.contractAt("SCR", proxy, {
    id: "Borderless_RegisterSCTModule_SCR",
  });
  const setSCContractTx = m.call(scrConn, "setSCContract", [sctAddress, "SC_JP_DAOLLC"]);
  const sctBeaconAddress = m.readEventArgument(
    setSCContractTx,
    "DeployBeaconProxy",
    0
  );
  const sctBeaconConn = m.contractAt("UpgradeableBeacon", sctBeaconAddress, {
    id: "Borderless_RegisterSCTModule_SCT_Beacon",
  });
  console.log(`✅ Done set SCT`);
  return {
    proxy,
    sctBeaconConn
  };
});

export const RegisterGovernanceServiceModule = buildModule("RegisterGovernanceServiceModule", (m) => {
  const serviceAddress = m.getParameter<string>(
    "ServiceAddress",
    "0x0000000000000000000000000000000000000000"
  );
  const serviceName = m.getParameter<string>(
    "ServiceName",
    ""
  );
  const serviceType = m.getParameter<number>(
    "ServiceType",
    0
  );
  const { proxy } = m.useModule(BorderlessModule);
  const serviceFactoryConn = m.contractAt("ServiceFactory", proxy, {
    id: "Borderless_RegisterGovernanceServiceModule_ServiceFactory",
  });
  const setServiceTx = m.call(serviceFactoryConn, "setService", [serviceAddress, serviceName, serviceType]);
  const serviceBeaconAddress = m.readEventArgument(
    setServiceTx,
    "DeployBeaconProxy",
    0
  );
  const serviceBeaconConn = m.contractAt("UpgradeableBeacon", serviceBeaconAddress);
  console.log(`✅ Done set Service`);
  return {
    proxy,
    serviceBeaconConn
  };
});

export const RegisterLetsServiceModule = buildModule("RegisterLetsServiceModule", (m) => {
  const serviceAddress = m.getParameter<string>(
    "ServiceAddress",
    "0x0000000000000000000000000000000000000000"
  );
  const serviceName = m.getParameter<string>(
    "ServiceName",
    ""
  );
  const serviceType = m.getParameter<number>(
    "ServiceType",
    0
  );
  const { proxy } = m.useModule(BorderlessModule);
  const serviceFactoryConn = m.contractAt("ServiceFactory", proxy, {
    id: "Borderless_RegisterGovernanceServiceModule_ServiceFactory",
  });
  const setServiceTx = m.call(serviceFactoryConn, "setService", [serviceAddress, serviceName, serviceType]);
  const serviceBeaconAddress = m.readEventArgument(
    setServiceTx,
    "DeployBeaconProxy",
    0
  );
  const serviceBeaconConn = m.contractAt("UpgradeableBeacon", serviceBeaconAddress);
  console.log(`✅ Done set Service`);
  return {
    proxy,
    serviceBeaconConn
  };
});

export const RegisterLetsNonExeServiceModule = buildModule("RegisterLetsNonExeServiceModule", (m) => {
  const serviceAddress = m.getParameter<string>(
    "ServiceAddress",
    "0x0000000000000000000000000000000000000000"
  );
  const serviceName = m.getParameter<string>(
    "ServiceName",
    ""
  );
  const serviceType = m.getParameter<number>(
    "ServiceType",
    0
  );
  const { proxy } = m.useModule(BorderlessModule);
  const serviceFactoryConn = m.contractAt("ServiceFactory", proxy, {
    id: "Borderless_RegisterGovernanceServiceModule_ServiceFactory",
  });
  const setServiceTx = m.call(serviceFactoryConn, "setService", [serviceAddress, serviceName, serviceType]);
  const serviceBeaconAddress = m.readEventArgument(
    setServiceTx,
    "DeployBeaconProxy",
    0
  );
  const serviceBeaconConn = m.contractAt("UpgradeableBeacon", serviceBeaconAddress);
  console.log(`✅ Done set Service`);
  return {
    proxy,
    serviceBeaconConn
  };
});

export const RegisterLetsSaleServiceModule = buildModule("RegisterLetsSaleServiceModule", (m) => {
  const serviceAddress = m.getParameter<string>(
    "ServiceAddress",
    "0x0000000000000000000000000000000000000000"
  );
  const serviceName = m.getParameter<string>(
    "ServiceName",
    ""
  );
  const serviceType = m.getParameter<number>(
    "ServiceType",
    0
  );
  const { proxy } = m.useModule(BorderlessModule);
  const serviceFactoryConn = m.contractAt("ServiceFactory", proxy, {
    id: "Borderless_RegisterGovernanceServiceModule_ServiceFactory",
  });
  const setServiceTx = m.call(serviceFactoryConn, "setService", [serviceAddress, serviceName, serviceType]);
  const serviceBeaconAddress = m.readEventArgument(
    setServiceTx,
    "DeployBeaconProxy",
    0
  );
  const serviceBeaconConn = m.contractAt("UpgradeableBeacon", serviceBeaconAddress);
  console.log(`✅ Done set Service`);
  return {
    proxy,
    serviceBeaconConn
  };
});