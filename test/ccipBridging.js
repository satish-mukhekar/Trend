const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Trend Contract", function () {
  let Trend;
  let trend;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    // Get the ContractFactory and Signers
    Trend = await ethers.getContractFactory("Trend");
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy the contract with an initial supply of tokens (e.g., 1000 tokens)
    trend = await Trend.deploy(ethers.utils.parseUnits("1000", 18));
    await trend.deployed();
  });

  describe("setMinterRole", function () {
    it("should allow the owner to set the minter role", async function () {
      // Ensure the owner has the MINTER_ROLE initially
      expect(await trend.hasRole(await trend.MINTER_ROLE(), owner.address)).to.be.true;

      // Grant MINTER_ROLE to addr1
      await trend.setMinterRole(addr1.address);

      // Check if addr1 has the MINTER_ROLE
      expect(await trend.hasRole(await trend.MINTER_ROLE(), addr1.address)).to.be.true;
    });

    it("should not allow non-admins to set the minter role", async function () {
      // Try to grant MINTER_ROLE to addr2 from addr1's account (non-admin)
      await expect(trend.connect(addr1).setMinterRole(addr2.address))
        .to.be.revertedWith("AccessControl: account " + addr1.address.toLowerCase() + " is missing role " + await trend.DEFAULT_ADMIN_ROLE());

      // Ensure addr2 does not have the MINTER_ROLE
      expect(await trend.hasRole(await trend.MINTER_ROLE(), addr2.address)).to.be.false;
    });

    it("should emit a role granted event when MINTER_ROLE is assigned", async function () {
      // Grant MINTER_ROLE to addr1 and check for the event
      await expect(trend.setMinterRole(addr1.address))
        .to.emit(trend, "RoleGranted")
        .withArgs(await trend.MINTER_ROLE(), addr1.address, owner.address);
    });
  });
});
