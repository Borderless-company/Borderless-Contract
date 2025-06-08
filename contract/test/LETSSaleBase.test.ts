import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers, network } from "hardhat";
import { createCompany } from "./utils/CreateCompany";
import { grantTreasuryRole } from "./utils/Role";
import { deployJP_DAO_LLCFullFixture } from "./utils/DeployFixture";
import { setTime } from "./utils/Time";

describe("LETSSaleBase", function () {
  const getLETSSaleBaseContext = async () => {
    const {
      deployer,
      founder,
      executiveMember,
      executiveMember2,
      executiveMember3,
      tokenMinter
    } = await loadFixture(deployJP_DAO_LLCFullFixture);

    // Create company with LETS service
    const { companyAddress, services } = await createCompany();
    const letsSale = await ethers.getContractAt("LETSSaleBase", services[2]);
    const lets = await ethers.getContractAt("LETSBase", services[2]);

    // Grant treasury role
    await grantTreasuryRole(founder, companyAddress, executiveMember);

    return {
      deployer,
      founder,
      treasury: executiveMember,
      buyer1: executiveMember2,
      buyer2: executiveMember3,
      companyAddress,
      letsSale,
      lets
    };
  };

  describe("setSaleInfo", function () {
    it("should set fixed price sale info when called by founder", async function () {
      const { founder, letsSale } = await getLETSSaleBaseContext();

      const saleStart = Date.now() + 3600; // 1 hour later
      const saleEnd = saleStart + 90000; // 24 hours later
      const fixedPrice = ethers.parseEther("1.0");
      const minPrice = 0;
      const maxPrice = 0;

      await expect(
        letsSale.connect(founder).setSaleInfo(
          saleStart,
          saleEnd,
          fixedPrice,
          minPrice,
          maxPrice
        )
      ).to.emit(letsSale, "SaleInfoUpdated")
        .withArgs(saleStart, saleEnd, fixedPrice, minPrice, maxPrice);
    });

    it("should set range price sale info when called by founder", async function () {
      const { founder, letsSale } = await getLETSSaleBaseContext();

      const saleStart = Date.now() + 3600;
      const saleEnd = saleStart + 90000;
      const fixedPrice = 0;
      const minPrice = ethers.parseEther("0.8");
      const maxPrice = ethers.parseEther("1.2");

      await expect(
        letsSale.connect(founder).setSaleInfo(
          saleStart,
          saleEnd,
          fixedPrice,
          minPrice,
          maxPrice
        )
      ).to.emit(letsSale, "SaleInfoUpdated")
        .withArgs(saleStart, saleEnd, fixedPrice, minPrice, maxPrice);
    });

    it("should revert when both fixed price and range prices are set", async function () {
      const { founder, letsSale } = await getLETSSaleBaseContext();

      const saleStart = Date.now() + 3600;
      const saleEnd = saleStart + 90000;
      const fixedPrice = ethers.parseEther("1.0");
      const minPrice = ethers.parseEther("0.8");
      const maxPrice = ethers.parseEther("1.2");

      await expect(
        letsSale.connect(founder).setSaleInfo(
          saleStart,
          saleEnd,
          fixedPrice,
          minPrice,
          maxPrice
        )
      ).to.be.revertedWithCustomError(letsSale, "InvalidPrice");
    });

    it("should revert when called by non-founder", async function () {
      const { buyer1, letsSale } = await getLETSSaleBaseContext();

      await expect(
        letsSale.connect(buyer1).setSaleInfo(
          Date.now(),
          Date.now() + 86400,
          ethers.parseEther("1.0"),
          0,
          0
        )
      ).to.be.revertedWithCustomError(letsSale, "NotFounder");
    });
  });

  describe("offerToken", function () {
    describe("Fixed Price Sale", function () {
      it("should allow token purchase with exact fixed price", async function () {
        const { founder, buyer1, letsSale, lets } = await getLETSSaleBaseContext();

        // Set up fixed price sale
        const saleStart = Date.now();
        const saleEnd = saleStart + 90000;
        const fixedPrice = ethers.parseEther("1.0");
        await letsSale.connect(founder).setSaleInfo(
          saleStart,
          saleEnd,
          fixedPrice,
          0,
          0
        );

        // set time
        await setTime(saleStart);

        // Purchase token
        await expect(
          letsSale.connect(buyer1).offerToken(buyer1.address, { value: fixedPrice })
        ).to.emit(letsSale, "TokenPurchased");

        // Verify token ownership
        const tokenId = 1;
        expect(await lets.ownerOf(tokenId)).to.equal(buyer1.address);
      });

      it("should revert when price is not exact fixed price", async function () {
        const { founder, buyer1, letsSale } = await getLETSSaleBaseContext();

        const saleStart = Date.now() + 3600;
        const saleEnd = saleStart + 90000;

        // Set up fixed price sale
        const fixedPrice = ethers.parseEther("1.0");
        await letsSale.connect(founder).setSaleInfo(
          saleStart,
          saleEnd,
          fixedPrice,
          0,
          0
        );

        // set time
        await setTime(saleStart);

        // Try to purchase with different price
        await expect(
          letsSale.connect(buyer1).offerToken(buyer1.address, { value: ethers.parseEther("1.1") })
        ).to.be.revertedWithCustomError(letsSale, "InsufficientFunds");
      });
    });

    describe("Range Price Sale", function () {
      it("should allow token purchase within price range", async function () {
        const { founder, buyer1, letsSale, lets } = await getLETSSaleBaseContext();

        // Set up range price sale
        const saleStart = Date.now();
        const saleEnd = saleStart + 90000;
        const minPrice = ethers.parseEther("0.8");
        const maxPrice = ethers.parseEther("1.2");
        await letsSale.connect(founder).setSaleInfo(
          saleStart,
          saleEnd,
          0,
          minPrice,
          maxPrice
        );

        // set time
        await setTime(saleStart);

        // Purchase token with price in range
        const purchasePrice = ethers.parseEther("1.0");
        await expect(
          letsSale.connect(buyer1).offerToken(buyer1.address, { value: purchasePrice })
        ).to.emit(letsSale, "TokenPurchased");

        // Verify token ownership
        const tokenId = 1;
        expect(await lets.ownerOf(tokenId)).to.equal(buyer1.address);
      });

      it("should revert when price is below minimum", async function () {
        const { founder, buyer1, letsSale } = await getLETSSaleBaseContext();

        const saleStart = Date.now() + 3600;
        const saleEnd = saleStart + 90000;

        // Set up range price sale
        const minPrice = ethers.parseEther("0.8");
        const maxPrice = ethers.parseEther("1.2");
        await letsSale.connect(founder).setSaleInfo(
          saleStart,
          saleEnd,
          0,
          minPrice,
          maxPrice
        );

        // set time
        await setTime(saleStart);

        // Try to purchase with price below minimum
        await expect(
          letsSale.connect(buyer1).offerToken(buyer1.address, { value: ethers.parseEther("0.7") })
        ).to.be.revertedWithCustomError(letsSale, "InsufficientFunds");
      });

      it("should revert when price is above maximum", async function () {
        const { founder, buyer1, letsSale } = await getLETSSaleBaseContext();

        const saleStart = Date.now() + 3600;
        const saleEnd = saleStart + 90000;

        // Set up range price sale
        const minPrice = ethers.parseEther("0.8");
        const maxPrice = ethers.parseEther("1.2");
        await letsSale.connect(founder).setSaleInfo(
          Date.now(),
          Date.now() + 86400,
          0,
          minPrice,
          maxPrice
        );

        // set time
        await setTime(saleStart);

        // Try to purchase with price above maximum
        await expect(
          letsSale.connect(buyer1).offerToken(buyer1.address, { value: ethers.parseEther("1.3") })
        ).to.be.revertedWithCustomError(letsSale, "InsufficientFunds");
      });
    });

    it("should revert when sale is not active", async function () {
      const { buyer1, letsSale } = await getLETSSaleBaseContext();

      await expect(
        letsSale.connect(buyer1).offerToken(buyer1.address, { value: ethers.parseEther("1.0") })
      ).to.be.revertedWithCustomError(letsSale, "NotSaleActive");
    });

    it("should revert when buyer already owns a token", async function () {
      const { founder, buyer1, letsSale } = await getLETSSaleBaseContext();

      const saleStart = Date.now() + 3600; // 1 hour later
      const saleEnd = saleStart + 90000; // 24 hours later

      // Set up fixed price sale
      const fixedPrice = ethers.parseEther("1.0");
      await letsSale.connect(founder).setSaleInfo(
        saleStart,
        saleEnd,
        fixedPrice,
        0,
        0
      );

      // set time
      await setTime(saleStart);

      // Purchase first token
      await letsSale.connect(buyer1).offerToken(buyer1.address, { value: fixedPrice });

      // Try to purchase second token
      await expect(
        letsSale.connect(buyer1).offerToken(buyer1.address, { value: fixedPrice })
      ).to.be.revertedWithCustomError(letsSale, "AlreadyPurchased");
    });
  });

  describe("withdraw", function () {
    it("should allow treasury to withdraw funds", async function () {
      const { founder, treasury, buyer1, letsSale } = await getLETSSaleBaseContext();

      const saleStart = Date.now() + 3600;
      const saleEnd = saleStart + 90000;

      // Set up fixed price sale and purchase token
      const fixedPrice = ethers.parseEther("1.0");
      await letsSale.connect(founder).setSaleInfo(
        Date.now(),
        Date.now() + 86400,
        fixedPrice,
        0,
        0
      );

      // set time
      await setTime(saleStart);

      await letsSale.connect(buyer1).offerToken(buyer1.address, { value: fixedPrice });

      const treasuryBalanceBefore = await ethers.provider.getBalance(treasury.address);
      
      await letsSale.connect(treasury).withdraw();

      const treasuryBalanceAfter = await ethers.provider.getBalance(treasury.address);
      expect(treasuryBalanceAfter).to.be.gt(treasuryBalanceBefore);
    });

    it("should revert when called by non-treasury", async function () {
      const { buyer1, letsSale } = await getLETSSaleBaseContext();

      await expect(
        letsSale.connect(buyer1).withdraw()
      ).to.be.revertedWithCustomError(letsSale, "NotTreasuryRole");
    });
  });

  describe("updateSalePeriod", function () {
    it("should allow treasury to update sale period", async function () {
      const { treasury, letsSale } = await getLETSSaleBaseContext();

      const newSaleStart = Date.now();
      const newSaleEnd = newSaleStart + 86400;

      await expect(
        letsSale.connect(treasury).updateSalePeriod(newSaleStart, newSaleEnd)
      ).to.emit(letsSale, "SalePeriodUpdated")
        .withArgs(newSaleStart, newSaleEnd);
    });

    it("should revert when called by non-treasury", async function () {
      const { buyer1, letsSale } = await getLETSSaleBaseContext();

      await expect(
        letsSale.connect(buyer1).updateSalePeriod(
          Date.now(),
          Date.now() + 86400
        )
      ).to.be.revertedWithCustomError(letsSale, "NotTreasuryRole");
    });
  });

  describe("updatePrice", function () {
    describe("Fixed Price Update", function () {
      it("should allow treasury to update fixed price", async function () {
        const { treasury, letsSale } = await getLETSSaleBaseContext();

        const newFixedPrice = ethers.parseEther("2.0");

        await expect(
          letsSale.connect(treasury).updatePrice(newFixedPrice, 0, 0)
        ).to.emit(letsSale, "PriceUpdated")
          .withArgs(newFixedPrice, 0, 0);
      });
    });

    describe("Range Price Update", function () {
      it("should allow treasury to update price range", async function () {
        const { treasury, letsSale } = await getLETSSaleBaseContext();

        const newMinPrice = ethers.parseEther("1.8");
        const newMaxPrice = ethers.parseEther("2.2");

        await expect(
          letsSale.connect(treasury).updatePrice(0, newMinPrice, newMaxPrice)
        ).to.emit(letsSale, "PriceUpdated")
          .withArgs(0, newMinPrice, newMaxPrice);
      });

      it("should revert when both fixed price and range prices are set", async function () {
        const { treasury, letsSale } = await getLETSSaleBaseContext();

        const newFixedPrice = ethers.parseEther("2.0");
        const newMinPrice = ethers.parseEther("1.8");
        const newMaxPrice = ethers.parseEther("2.2");

        await expect(
          letsSale.connect(treasury).updatePrice(newFixedPrice, newMinPrice, newMaxPrice)
        ).to.be.revertedWithCustomError(letsSale, "InvalidPrice");
      });
    });

    it("should revert when called by non-treasury", async function () {
      const { buyer1, letsSale } = await getLETSSaleBaseContext();

      await expect(
        letsSale.connect(buyer1).updatePrice(
          ethers.parseEther("2.0"),
          0,
          0
        )
      ).to.be.revertedWithCustomError(letsSale, "NotTreasuryRole");
    });
  });
}); 