import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export const BorderlessModule = buildModule("BorderlessModule", (m) => {
  // ────────────────────────────────────────────────
  // 必要に応じてオーナーアドレスなどをパラメータ　で受け取れます
  // hardhat.config.ts の ignition: { params: { OWNER: "0x…" } } などで指定
  // ────────────────────────────────────────────────
  const deployer = m.getParameter<string>("Deployer", "");

  // ────────────────────────────────────────────────
  // １）Facet 実装を先に宣言（まだデプロイは行われません）
  // ────────────────────────────────────────────────
  const accessControlFacet = m.contract("BorderlessAccessControl", []);
  const scrBeaconFacet = m.contract("SCRBeaconUpgradeable", []);
  const sfBeaconFacet = m.contract("ServiceFactoryBeaconUpgradeable", []);
  const serviceFactoryFacet = m.contract("ServiceFactory", []);
  const scrInitializeFacet = m.contract("SCRInitialize", [], {
    id: "Borderless_SCRInitialize",
  });
  const scrFacet = m.contract("SCR", []);

  // ────────────────────────────────────────────────
  // ２）Dictionary をデプロイ
  //    （コンストラクタでオーナーアドレス等を渡す場合は引数に）
  // ────────────────────────────────────────────────
  const dictionary = m.contract("Dictionary", [deployer]);
  const dictionaryInitializeFacet = m.contract("DictionaryInitialize", []);

  // ────────────────────────────────────────────────
  // ３）Proxy をデプロイ
  //    constructor に Dictionary アドレスを渡します
  //    必要があれば initializer 名・引数・value も指定可能
  // ────────────────────────────────────────────────
  const proxy = m.contract("BorderlessProxy", [dictionary, "0x"]);

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
    scrBeaconFacet,
    sfBeaconFacet,
    serviceFactoryFacet,
    scrInitializeFacet,
    scrFacet,
    dictionary,
    dictionaryInitializeFacet,
    proxy,
    sct,
    governance_jp_llc,
    lets_jp_llc_exe,
    lets_jp_llc_non_exe,
    lets_jp_llc_sale,
  };
});

export const InitializeModule = buildModule("InitializeModule", (m) => {
  const deployer = m.getParameter<string>("Deployer", "");
  const { proxy } = m.useModule(BorderlessModule);
  const scrInitializeConn = m.contractAt("SCRInitialize", proxy);
  m.call(scrInitializeConn, "initialize", [deployer]);
  return {
    proxy,
  };
});

export const BorderlessAccessControlInitializeModule = buildModule(
  "BorderlessAccessControlInitializeModule",
  (m) => {
    const { accessControlFacet, dictionary } = m.useModule(BorderlessModule);
    const accessControlConn = m.contractAt(
      "BorderlessAccessControl",
      accessControlFacet
    );
    m.call(accessControlConn, "initialize", [dictionary]);
    return {
      dictionary,
      accessControlFacet,
    };
  }
);

export const DictionaryInitializeModule = buildModule(
  "DictionaryInitializeModule",
  (m) => {
    const { dictionaryInitializeFacet, dictionary } = m.useModule(
      BorderlessModule
    );
    const dictionaryInitializeConn = m.contractAt(
      "DictionaryInitialize",
      dictionaryInitializeFacet
    );
    m.call(dictionaryInitializeConn, "initialize", [dictionary]);
    return {
      dictionary,
      dictionaryInitializeFacet,
    };
  }
);

export const RegisterSCTModule = buildModule("RegisterSCTModule", (m) => {
  const { sct, proxy } = m.useModule(BorderlessModule);
  const scrConn = m.contractAt("SCR", proxy);
  const setSCContractTx = m.call(scrConn, "setSCContract", [
    sct,
    "SC_JP_DAOLLC",
  ]);
  const sctBeaconAddress = m.readEventArgument(
    setSCContractTx,
    "DeployBeaconProxy",
    0
  );
  const sctBeaconConn = m.contractAt("UpgradeableBeacon", sctBeaconAddress);
  return {
    proxy,
    sctBeaconConn,
  };
});

export const RegisterGovernanceServiceModule = buildModule(
  "RegisterGovernanceServiceModule",
  (m) => {
    const serviceName = m.getParameter<string>("ServiceName", "");
    const serviceType = m.getParameter<number>("ServiceType", 0);
    const { proxy, governance_jp_llc } = m.useModule(BorderlessModule);
    const serviceFactoryConn = m.contractAt("ServiceFactory", proxy);
    const setServiceTx = m.call(serviceFactoryConn, "setService", [
      governance_jp_llc,
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

export const RegisterLetsServiceModule = buildModule(
  "RegisterLetsServiceModule",
  (m) => {
    const serviceName = m.getParameter<string>("ServiceName", "");
    const serviceType = m.getParameter<number>("ServiceType", 0);
    const { proxy, lets_jp_llc_exe } = m.useModule(BorderlessModule);
    const serviceFactoryConn = m.contractAt("ServiceFactory", proxy);
    const setServiceTx = m.call(serviceFactoryConn, "setService", [
      lets_jp_llc_exe,
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

export const RegisterLetsNonExeServiceModule = buildModule(
  "RegisterLetsNonExeServiceModule",
  (m) => {
    const serviceName = m.getParameter<string>("ServiceName", "");
    const serviceType = m.getParameter<number>("ServiceType", 0);
    const { proxy, lets_jp_llc_non_exe } = m.useModule(BorderlessModule);
    const serviceFactoryConn = m.contractAt("ServiceFactory", proxy);
    const setServiceTx = m.call(serviceFactoryConn, "setService", [
      lets_jp_llc_non_exe,
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

export const RegisterLetsSaleServiceModule = buildModule(
  "RegisterLetsSaleServiceModule",
  (m) => {
    const serviceName = m.getParameter<string>("ServiceName", "");
    const serviceType = m.getParameter<number>("ServiceType", 0);
    const { proxy, lets_jp_llc_sale } = m.useModule(BorderlessModule);
    const serviceFactoryConn = m.contractAt("ServiceFactory", proxy);
    const setServiceTx = m.call(serviceFactoryConn, "setService", [
      lets_jp_llc_sale,
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

export const CreateSmartCompanyModule = buildModule(
  "CreateSmartCompanyModule",
  (m) => {
    const sctBeaconAddress = m.getParameter<string>("SCTBeaconAddress", "");
    const governanceBeaconAddress = m.getParameter<string>(
      "GovernanceBeaconAddress",
      ""
    );
    const lets_jp_llc_exeBeaconAddress = m.getParameter<string>(
      "LetsJpLlCExeBeaconAddress",
      ""
    );
    const lets_jp_llc_non_exeBeaconAddress = m.getParameter<string>(
      "LetsJpLlCNonExeBeaconAddress",
      ""
    );
    const lets_jp_llc_exeParams = m.getParameter<string>(
      "LetsJpLlCExeParams",
      ""
    );
    const lets_jp_llc_non_exeParams = m.getParameter<string>(
      "LetsJpLlCNonExeParams",
      ""
    );
    const { proxy } = m.useModule(BorderlessModule);
    const scrConn = m.contractAt("SCR", proxy);
    const scid = "1234567890";
    const legalEntityCode = "SC_JP_DAOLLC";
    const companyName = "Test DAO Company";
    const establishmentDate = "2024-01-01";
    const jurisdiction = "JP";
    const entityType = "LLC";
    const scDeployParam = "0x"; // 空の bytes
    const companyInfo = ["100-0001", "Tokyo", "Shinjuku-ku", "Shinjuku 1-1-1"];
    const scsBeaconProxy = [
      governanceBeaconAddress,
      lets_jp_llc_exeBeaconAddress,
      lets_jp_llc_non_exeBeaconAddress,
    ];
    const scsExtraParams = [
      "0x",
      lets_jp_llc_exeParams,
      lets_jp_llc_non_exeParams,
    ];

    const createSmartCompanyTx = m.call(scrConn, "createSmartCompany", [
      scid,
      sctBeaconAddress,
      legalEntityCode,
      companyName,
      establishmentDate,
      jurisdiction,
      entityType,
      scDeployParam,
      companyInfo,
      scsBeaconProxy,
      scsExtraParams,
    ]);
    const scProxyAddress = m.readEventArgument(
      createSmartCompanyTx,
      "DeploySmartCompany",
      1
    );
    const scProxyConn = m.contractAt("SCT", scProxyAddress);
    return {
      proxy,
      scProxyConn,
    };
  }
);
