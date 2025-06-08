import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { FunctionFragment } from "ethers";
import type {
  SCR,
  ServiceFactory,
  LETS_JP_LLC_EXE,
  BorderlessAccessControl,
  LETS_JP_LLC_SALE,
  LETS_JP_LLC_NON_EXE,
} from "../typechain-types";
import { deployJP_DAO_LLCFullFixture } from "./utils/DeployFixture";
import { letsEncodeParams } from "../scripts/utils/Encode";
import { createCompany } from "./utils/CreateCompany";

describe("SCR Test", function () {
  it("Dictionary owner is set to deployer", async function () {
    const { deployer, dictionary } = await loadFixture(
      deployJP_DAO_LLCFullFixture
    );
    expect(await dictionary.owner()).to.equal(deployer.address);
  });

  it("BorderlessProxyFacade is deployed correctly", async function () {
    const { borderlessProxy } = await loadFixture(deployJP_DAO_LLCFullFixture);
    expect(ethers.isAddress(await borderlessProxy.getAddress())).to.be.true;
  });

  it("Dictionary has the selector of SCT's getService function", async function () {
    const { dictionary, scrImplementation } = await loadFixture(
      deployJP_DAO_LLCFullFixture
    );
    const SCR = await ethers.getContractFactory("SCR");
    const frag = SCR.interface.getFunction("setSCContract")!;
    const selector = FunctionFragment.getSelector(
      frag.name,
      frag.inputs.map((i) => i.type)
    );
    expect(await dictionary.getImplementation(selector)).to.equal(
      await scrImplementation.getAddress()
    );
  });
});

describe("createSmartCompany", function () {
  it("createSmartCompany is successful", async function () {
    const {
      deployer,
      borderlessProxy,
      founder,
      executiveMember,
      executiveMember2,
      executiveMember3,
      tokenMinter,
    } = await loadFixture(deployJP_DAO_LLCFullFixture);

    // ============================================== //
    // execute createSmartCompany
    // ============================================== //

    const { companyAddress, services } = await createCompany();

    // ============================================== //
    // verify roles
    // ============================================== //

    const sct = (
      await ethers.getContractAt("BorderlessAccessControl", companyAddress)
    ).connect(founder) as BorderlessAccessControl;
    expect(
      await sct.hasRole(
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        await founder.getAddress()
      )
    ).to.be.true;

    console.log("✅ BorderlessAccessControl roles verification");

    // ============================================== //
    // Get LETS from ServiceFactory
    // ============================================== //

    const serviceFactoryConn = (
      await ethers.getContractAt(
        "ServiceFactory",
        await borderlessProxy.getAddress()
      )
    ).connect(founder) as ServiceFactory;

    const letsExeAddress = await serviceFactoryConn.getFounderService(
      founder,
      3
    );

    const letsNonExeAddress = await serviceFactoryConn.getFounderService(
      founder,
      4
    );

    console.log("✅ Get LETS from ServiceFactory");

    // Get LETS_JP_LLC_EXE and LETS_JP_LLC_NON_EXE addresses from events
    const letsExe = (
      await ethers.getContractAt("LETS_JP_LLC_EXE", services[2])
    ).connect(founder) as LETS_JP_LLC_EXE;

    const letsNonExe = (
      await ethers.getContractAt("LETS_JP_LLC_NON_EXE", services[4])
    ).connect(founder) as LETS_JP_LLC_NON_EXE;

    expect(await letsExe.getAddress()).to.equal(letsExeAddress);
    expect(await letsNonExe.getAddress()).to.equal(letsNonExeAddress);
    console.log("✅ Get LETS_JP_LLC_EXE and LETS_JP_LLC_NON_EXE addresses");

    // ============================================== //
    // Execute LETS_JP_LLC_EXE's initialMint
    // ============================================== //

    // Execute initialMint
    await letsExe.connect(founder).getFunction("initialMint(address[])")([
      await executiveMember.getAddress(),
      await executiveMember2.getAddress(),
    ]);

    // Check balances
    expect(
      await letsExe.balanceOf(await executiveMember.getAddress())
    ).to.equal(1);
    expect(
      await letsExe.balanceOf(await executiveMember2.getAddress())
    ).to.equal(1);

    console.log("✅ Execute LETS_JP_LLC_EXE's initialMint");

    // ============================================== //
    // Execute LETS_JP_LLC_EXE's mint from MINTER_ROLE
    // ============================================== //

    // Grant MINTER_ROLE
    const scrAccessControlConn = (
      await ethers.getContractAt(
        "BorderlessAccessControl",
        await borderlessProxy.getAddress()
      )
    ).connect(deployer) as BorderlessAccessControl;

    const MINTER_ROLE =
      "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6";
    await scrAccessControlConn.grantRole(MINTER_ROLE, tokenMinter);

    // Execute mint
    await letsExe.connect(tokenMinter).getFunction("mint(address)")(
      await tokenMinter.getAddress()
    );
    expect(await letsExe.balanceOf(await tokenMinter.getAddress())).to.equal(1);

    console.log("✅ Execute LETS_JP_LLC_EXE's mint from MINTER_ROLE");

    // ============================================== //
    // Execute LETS_JP_LLC_EXE's mint from MINTER_ROLE
    // ============================================== //

    // Execute mint
    await letsNonExe.connect(tokenMinter).getFunction("mint(address)")(
      await tokenMinter.getAddress()
    );
    expect(await letsNonExe.balanceOf(await tokenMinter.getAddress())).to.equal(
      1
    );

    console.log("✅ Execute LETS_JP_LLC_NON_EXE's mint from MINTER_ROLE");

    // ============================================== //
    // Set up Sale contract
    // ============================================== //

    // Get Sale contract address
    const letsExeSale = (
      await ethers.getContractAt("LETS_JP_LLC_SALE", services[2])
    ).connect(founder) as LETS_JP_LLC_SALE;

    // Set up Sale contract
    await letsExeSale
      .connect(founder)
      .getFunction("setSaleInfo(uint256,uint256,uint256,uint256,uint256)")(
      0,
      0,
      ethers.parseEther("0.1"),
      0,
      0
    );

    // Purchase
    await letsExeSale
      .connect(executiveMember3)
      .getFunction("offerToken(address)")(
      await executiveMember3.getAddress(),
      { value: ethers.parseEther("0.1") } // Send 0.1 ETH
    );

    // Check balances
    expect(
      await letsExe.balanceOf(await executiveMember3.getAddress())
    ).to.equal(1);

    console.log("✅ Purchase LETS_JP_LLC_EXE from Sale contract");

    // ============================================== //
    // Purchase LETS_JP_LLC_NON_EXE
    // ============================================== //

    expect(await letsNonExe.getAddress()).to.equal(letsNonExeAddress);

    // Get Sale contract address
    const letsNonExeSale = (
      await ethers.getContractAt("LETS_JP_LLC_SALE", services[4])
    ).connect(founder) as LETS_JP_LLC_SALE;

    // Set up Sale contract
    await letsNonExeSale
      .connect(founder)
      .getFunction("setSaleInfo(uint256,uint256,uint256,uint256,uint256)")(
      0,
      0,
      ethers.parseEther("0.01"),
      0,
      0
    );

    // Purchase
    await letsNonExeSale
      .connect(executiveMember3)
      .getFunction("offerToken(address)")(
      await executiveMember3.getAddress(),
      { value: ethers.parseEther("0.01") } // Send 0.1 ETH
    );

    // Check balances
    expect(
      await letsNonExe.balanceOf(await executiveMember3.getAddress())
    ).to.equal(1);

    console.log("✅ Purchase LETS_JP_LLC_NON_EXE");
  });

  it("createSmartCompany is successful from another founder", async function () {
    const {
      founder,
    } = await loadFixture(deployJP_DAO_LLCFullFixture);

    // Create a company with the first founder
    await createCompany();

    // Create a company with the second founder
    const { companyAddress: companyAddress2, services: services2 } =
      await createCompany();

    // Verify roles of the second company
    const sct2 = (
      await ethers.getContractAt("BorderlessAccessControl", companyAddress2)
    ).connect(founder) as BorderlessAccessControl;
    expect(
      await sct2.hasRole(
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        await founder.getAddress()
      )
    ).to.be.true;

    console.log("✅ Verify roles of the second company");
  });

  it("createSmartCompany fails with the same founder", async function () {
    const {
      borderlessProxy,
      founder,
    } = await loadFixture(deployJP_DAO_LLCFullFixture);

    // Create a company with the first founder
    await createCompany();

    // Try to create a company with the same founder
    const scrConn = (
      await ethers.getContractAt("SCR", await borderlessProxy.getAddress())
    ).connect(founder) as SCR;

    const scid = "9876543210";
    const legalEntityCode = "SC_JP_DAO_LLC";
    const companyName = "Test DAO Company 2";
    const establishmentDate = "2024-01-01";
    const jurisdiction = "JP";
    const entityType = "LLC";
    const scDeployParam = "0x";
    const companyInfo = ["100-0001", "Tokyo", "Shinjuku-ku", "Shinjuku 1-1-1"];
    const scsBeaconProxy = [
      await (
        await ethers.getContractAt(
          "ServiceFactory",
          await borderlessProxy.getAddress()
        )
      ).getFounderService(founder, 1),
      await (
        await ethers.getContractAt(
          "ServiceFactory",
          await borderlessProxy.getAddress()
        )
      ).getFounderService(founder, 3),
      await (
        await ethers.getContractAt(
          "ServiceFactory",
          await borderlessProxy.getAddress()
        )
      ).getFounderService(founder, 4),
    ];

    const scsExtraParams = [
      "0x",
      letsEncodeParams(
        "LETS_JP_LLC_EXE",
        "LETS_JP_LLC_EXE",
        "https://example.com/metadata/",
        ".json",
        true,
        2000
      ),
      letsEncodeParams(
        "LETS_JP_LLC_NON_EXE",
        "LETS_JP_LLC_NON_EXE",
        "https://example.com/metadata/",
        ".json",
        false,
        2000
      ),
    ];

    await expect(
      scrConn.createSmartCompany(
        scid.toString(),
        await (
          await ethers.getContractAt(
            "ServiceFactory",
            await borderlessProxy.getAddress()
          )
        ).getFounderService(founder, 0),
        legalEntityCode,
        companyName,
        establishmentDate,
        jurisdiction,
        entityType,
        scDeployParam,
        companyInfo,
        scsBeaconProxy,
        scsExtraParams
      )
    ).to.be.revertedWithCustomError(scrConn, "AlreadyEstablish");
  });

  it("createSmartCompany fails with invalid company information", async function () {
    const {
      borderlessProxy,
      founder,
    } = await loadFixture(deployJP_DAO_LLCFullFixture);

    const scrConn = (
      await ethers.getContractAt("SCR", await borderlessProxy.getAddress())
    ).connect(founder) as SCR;

    const scid = "9876543210";
    const legalEntityCode = "SC_JP_DAO_LLC";
    const companyName = ""; // Invalid company name
    const establishmentDate = ""; // Invalid establishment date
    const jurisdiction = ""; // Invalid jurisdiction
    const entityType = ""; // Invalid entity type
    const scDeployParam = "0x";
    const companyInfo = ["100-0001", "Tokyo", "Shinjuku-ku", "Shinjuku 1-1-1"];
    const scsBeaconProxy = [
      await (
        await ethers.getContractAt(
          "ServiceFactory",
          await borderlessProxy.getAddress()
        )
      ).getFounderService(founder, 1),
      await (
        await ethers.getContractAt(
          "ServiceFactory",
          await borderlessProxy.getAddress()
        )
      ).getFounderService(founder, 3),
      await (
        await ethers.getContractAt(
          "ServiceFactory",
          await borderlessProxy.getAddress()
        )
      ).getFounderService(founder, 4),
    ];

    const scsExtraParams = [
      "0x",
      letsEncodeParams(
        "LETS_JP_LLC_EXE",
        "LETS_JP_LLC_EXE",
        "https://example.com/metadata/",
        ".json",
        true,
        2000
      ),
      letsEncodeParams(
        "LETS_JP_LLC_NON_EXE",
        "LETS_JP_LLC_NON_EXE",
        "https://example.com/metadata/",
        ".json",
        false,
        2000
      ),
    ];

    await expect(
      scrConn.createSmartCompany(
        scid.toString(),
        await (
          await ethers.getContractAt(
            "ServiceFactory",
            await borderlessProxy.getAddress()
          )
        ).getFounderService(founder, 0),
        legalEntityCode,
        companyName,
        establishmentDate,
        jurisdiction,
        entityType,
        scDeployParam,
        companyInfo,
        scsBeaconProxy,
        scsExtraParams
      )
    ).to.be.revertedWithCustomError(scrConn, "InvalidCompanyInfo");
  });

  it("createSmartCompany fails with invalid company information field count", async function () {
    const {
      borderlessProxy,
      founder,
    } = await loadFixture(deployJP_DAO_LLCFullFixture);

    const scrConn = (
      await ethers.getContractAt("SCR", await borderlessProxy.getAddress())
    ).connect(founder) as SCR;

    const scid = "9876543210";
    const legalEntityCode = "SC_JP_DAO_LLC";
    const companyName = "Test DAO Company";
    const establishmentDate = "2024-01-01";
    const jurisdiction = "JP";
    const entityType = "LLC";
    const scDeployParam = "0x";
    const companyInfo = ["100-0001", "Tokyo"]; // Insufficient field count
    const scsBeaconProxy = [
      await (
        await ethers.getContractAt(
          "ServiceFactory",
          await borderlessProxy.getAddress()
        )
      ).getFounderService(founder, 1),
      await (
        await ethers.getContractAt(
          "ServiceFactory",
          await borderlessProxy.getAddress()
        )
      ).getFounderService(founder, 3),
      await (
        await ethers.getContractAt(
          "ServiceFactory",
          await borderlessProxy.getAddress()
        )
      ).getFounderService(founder, 4),
    ];

    const scsExtraParams = [
      "0x",
      letsEncodeParams(
        "LETS_JP_LLC_EXE",
        "LETS_JP_LLC_EXE",
        "https://example.com/metadata/",
        ".json",
        true,
        2000
      ),
      letsEncodeParams(
        "LETS_JP_LLC_NON_EXE",
        "LETS_JP_LLC_NON_EXE",
        "https://example.com/metadata/",
        ".json",
        false,
        2000
      ),
    ];

    await expect(
      scrConn.createSmartCompany(
        scid.toString(),
        await (
          await ethers.getContractAt(
            "ServiceFactory",
            await borderlessProxy.getAddress()
          )
        ).getFounderService(founder, 0),
        legalEntityCode,
        companyName,
        establishmentDate,
        jurisdiction,
        entityType,
        scDeployParam,
        companyInfo,
        scsBeaconProxy,
        scsExtraParams
      )
    ).to.be.revertedWithCustomError(scrConn, "InvalidCompanyInfoLength");
  });
});
