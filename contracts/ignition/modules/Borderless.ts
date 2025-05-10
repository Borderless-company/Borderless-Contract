import { buildModule, } from "@nomicfoundation/hardhat-ignition/modules";
import { FunctionFragment, Interface } from "ethers";
import BorderlessAccessControlArtifact from "../../artifacts/contracts/BorderlessAccessControl/functions/BorderlessAccessControl.sol/BorderlessAccessControl.json";
import AddressManagerArtifact from "../../artifacts/contracts/AddressManager/functions/AddressManager.sol/AddressManager.json";
import SCRBeaconUpgradeableArtifact from "../../artifacts/contracts/BeaconUpgradeableBase/functions/SCRBeaconUpgradeable.sol/SCRBeaconUpgradeable.json";
import ServiceFactoryBeaconUpgradeableArtifact from "../../artifacts/contracts/BeaconUpgradeableBase/functions/ServiceFactoryBeaconUpgradeable.sol/ServiceFactoryBeaconUpgradeable.json";
import ServiceFactoryArtifact from "../../artifacts/contracts/Factory/functions/ServiceFactory.sol/ServiceFactory.json";
import InitializeArtifact from "../../artifacts/contracts/Initialize/functions/Initialize.sol/Initialize.json";
import SCRArtifact from "../../artifacts/contracts/SCR/functions/SCR.sol/SCR.json";

export default buildModule("Borderless", (m) => {
  // ────────────────────────────────────────────────
  // 必要に応じてオーナーアドレスなどをパラメータ　で受け取れます
  // hardhat.config.ts の ignition: { params: { OWNER: "0x…" } } などで指定
  // ────────────────────────────────────────────────
  const owner = m.getParameter<string>(
    "OWNER",
    "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
  );

  // ────────────────────────────────────────────────
  // １）Facet 実装を先に宣言（まだデプロイは行われません）
  // ────────────────────────────────────────────────
  const accessControlFacet = m.contract("BorderlessAccessControl", []);
  const addressManagerFacet = m.contract("AddressManager", []);
  const scrBeaconFacet = m.contract("SCRBeaconUpgradeable", []);
  const sfBeaconFacet = m.contract("ServiceFactoryBeaconUpgradeable", []);
  const serviceFactoryFacet = m.contract("ServiceFactory", []);
  const initializeFacet = m.contract("Initialize", []);
  const scrFacet = m.contract("SCR", []);

  // ────────────────────────────────────────────────
  // ２）Dictionary をデプロイ
  //    （コンストラクタでオーナーアドレス等を渡す場合は引数に）
  // ────────────────────────────────────────────────
  const dictionary = m.contract("Dictionary", [owner]);

  // ────────────────────────────────────────────────
  // ３）Proxy をデプロイ
  //    constructor に Dictionary アドレスを渡します
  //    必要があれば initializer 名・引数・value も指定可能
  // ────────────────────────────────────────────────
  const proxy = m.contract("SCRProxy", [dictionary, "0x"]);

  // ────────────────────────────────────────────────
  // ４）Register all Facets in Dictionary
  // ────────────────────────────────────────────────
  // async function registerFunctions(
  //   m: any,
  //   dictionary: any,
  //   factory: any,
  //   implAddress: any
  // ) {
  //   for (const frag of factory.interface.fragments) {
  //     if (!(frag instanceof FunctionFragment)) continue;
  //     const selector = FunctionFragment.getSelector(
  //       frag.name,
  //       frag.inputs.map((i) => i.type)
  //     );
  //     await dictionary.setImplementation(selector, implAddress);
  //     m.call(dictionary, "registerFunctions", [selector, implAddress]);
  //   }
  // }
  function registerFunctions(
    dict: any,
    artifact: { abi: readonly any[] },
    facet: any,
    prefix: string
  ) {
    // ABI 配列から type === "function" の要素だけ抽出し、セレクターを計算して呼び出し
    artifact.abi
      .filter(
        (
          item
        ): item is {
          type: "function";
          name: string;
          inputs: { type: string }[];
        } => item.type === "function"
      )
      .forEach((item, i) => {
        const selector = FunctionFragment.getSelector(
          item.name,
          item.inputs.map((inp) => inp.type)
        );
        console.log(
          `${prefix}_${item.name}_${i}`,
          selector,
          facet
        );
        m.call(dict, "setImplementation", [selector, facet.getAddress()], {
          id: `${prefix}_${item.name}_${i}`,
        });
      });
  }

  // Facetごとにプレフィックスを分けて登録
  registerFunctions(
    dictionary,
    BorderlessAccessControlArtifact,
    accessControlFacet,
    "ACF"
  );
  registerFunctions(
    dictionary,
    AddressManagerArtifact,
    addressManagerFacet,
    "AMF"
  );
  registerFunctions(
    dictionary,
    SCRBeaconUpgradeableArtifact,
    scrBeaconFacet,
    "SBF"
  );
  registerFunctions(
    dictionary,
    ServiceFactoryBeaconUpgradeableArtifact,
    sfBeaconFacet,
    "SFBF"
  );
  registerFunctions(
    dictionary,
    ServiceFactoryArtifact,
    serviceFactoryFacet,
    "SFF"
  );
  registerFunctions(dictionary, InitializeArtifact, initializeFacet, "IF");
  registerFunctions(dictionary, SCRArtifact, scrFacet, "SCRF");

  // ────────────────────────────────────────────────
  // ５）initializer を実行
  // ────────────────────────────────────────────────
  m.call(initializeFacet, "initialize", [owner]);

  // ────────────────────────────────────────────────
  // ６）SCT をデプロイ
  // ────────────────────────────────────────────────
  const sct = m.contract("SC_JP_DAOLLC", []);
  const sctSetSCContract = m.call(
    proxy,
    "setSCContract",
    [sct, "SC_JP_DAOLLC"],
    { id: "Borderless_setSCContract_SC_JP_DAOLLC" }
  );
  const sctBeacon = m.readEventArgument(
    sctSetSCContract,
    "DeploySmartCompany",
    0,
    { id: "Borderless_read_SCT_DeploySmartCompany_0" }
  ) as any;

  // ────────────────────────────────────────────────
  // ７）Serviceをデプロイ
  // ────────────────────────────────────────────────
  const governance_jp_llc = m.contract("Governance_JP_LLC", []);
  const governanceSetService = m.call(
    proxy,
    "setService",
    [governance_jp_llc, "Governance_JP_LLC", 2],
    {
      id: "Borderless_setService_GovernanceJPLLC",
    }
  );
  const governance_jp_llcBeacon = m.readEventArgument(
    governanceSetService,
    "DeployBeaconProxy",
    0,
    { id: "Borderless_read_GovernanceJPLLC_DeployBeaconProxy_0" }
  ) as any;

  const lets_jp_llc_exe = m.contract("LETS_JP_LLC_EXE", []);
  const lets_jp_llc_exeSetService = m.call(
    proxy,
    "setService",
    [lets_jp_llc_exe, "LETS_JP_LLC_EXE", 3],
    {
      id: "Borderless_setService_LETS_JP_LLC_EXE",
    }
  );
  const lets_jp_llc_exeBeacon = m.readEventArgument(
    lets_jp_llc_exeSetService,
    "DeployBeaconProxy",
    0,
    { id: "Borderless_read_LETSJPLLCEXE_DeployBeaconProxy_0" }
  ) as any;

  const lets_jp_llc_non_exe = m.contract("LETS_JP_LLC_NON_EXE", []);
  const lets_jp_llc_non_exeSetService = m.call(
    proxy,
    "setService",
    [lets_jp_llc_non_exe, "LETS_JP_LLC_NON_EXE", 4],
    {
      id: "Borderless_setService_LETS_JP_LLC_NON_EXE",
    }
  );
  const lets_jp_llc_non_exeBeacon = m.readEventArgument(
    lets_jp_llc_non_exeSetService,
    "DeployBeaconProxy",
    0,
    { id: "Borderless_read_LETSJPLLCNONEXE_DeployBeaconProxy_0" }
  ) as any;

  const lets_jp_llc_sale = m.contract("LETS_JP_LLC_SALE", []);
  const lets_jp_llc_saleSetService = m.call(
    proxy,
    "setService",
    [lets_jp_llc_sale, "LETS_JP_LLC_SALE", 5],
    {
      id: "Borderless_setService_LETS_JP_LLC_Sale",
    }
  );
  const lets_jp_llc_saleBeacon = m.readEventArgument(
    lets_jp_llc_saleSetService,
    "DeployBeaconProxy",
    0,
    { id: "Borderless_read_LETSJPLLCSale_DeployBeaconProxy_0" }
  ) as any;

  // ────────────────────────────────────────────────
  // アドレスの出力
  // ────────────────────────────────────────────────
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
    lets_jp_llc_saleBeacon,
    lets_jp_llc_non_exeBeacon,
    lets_jp_llc_exeBeacon,
    governance_jp_llcBeacon,
    sctBeacon,
  };
});
