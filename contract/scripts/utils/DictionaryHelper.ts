import hre from "hardhat";
import { Contract, FunctionFragment } from "ethers";

export const registerAllFacets = async (
  dictionary: Contract,
  scrBeaconFacet: Contract,
  sfBeaconFacet: Contract,
  serviceFactoryFacet: Contract,
  scrInitializeFacet: Contract,
  scrFacet: Contract
) => {
  const {
    selectors: scrBeaconSelectors,
    implementations: scrBeaconImplementations,
  } = await getSelectors(
    "SCRBeaconUpgradeable",
    await scrBeaconFacet.getAddress()
  );

  const {
    selectors: sfBeaconSelectors,
    implementations: sfBeaconImplementations,
  } = await getSelectors(
    "ServiceFactoryBeaconUpgradeable",
    await sfBeaconFacet.getAddress()
  );

  const {
    selectors: serviceFactorySelectors,
    implementations: serviceFactoryImplementations,
  } = await getSelectors(
    "ServiceFactory",
    await serviceFactoryFacet.getAddress()
  );

  const {
    selectors: scrInitializeSelectors,
    implementations: scrInitializeImplementations,
  } = await getSelectors(
    "SCRInitialize",
    await scrInitializeFacet.getAddress()
  );

  const { selectors: scrSelectors, implementations: scrImplementations } =
    await getSelectors("SCR", await scrFacet.getAddress());

  const receipt = await dictionary.getFunction(
    "bulkSetImplementation(bytes4[],address[])"
  )(
    [
      ...scrBeaconSelectors,
      ...sfBeaconSelectors,
      ...serviceFactorySelectors,
      ...scrInitializeSelectors,
      ...scrSelectors,
    ],
    [
      ...scrBeaconImplementations,
      ...sfBeaconImplementations,
      ...serviceFactoryImplementations,
      ...scrInitializeImplementations,
      ...scrImplementations,
    ]
  );
  await receipt.wait();

  console.log("✅ Done register functions");
};

export const getSelectors = async (name: string, implAddress: string) => {
  const factory = await hre.ethers.getContractFactory(name);
  const selectors = [];
  const implementations = [];
  for (const frag of factory.interface.fragments) {
    if (!(frag instanceof FunctionFragment)) continue;
    const selector = FunctionFragment.getSelector(
      frag.name,
      frag.inputs.map((i) => i.type)
    );
    selectors.push(selector);
    implementations.push(implAddress);
  }
  return { selectors, implementations };
};