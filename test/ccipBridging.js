const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Bridging Contract", function () {
  let Bridging, bridging, owner, addr1, addr2;
  const destinationChainSelector = 10344971235874465080; // example chain selector
  const message = ethers.utils.formatBytes32String("Hello");
  const linkTokenAddress = "0xE4aB69C077896252FAFBD49EFD26B5D171A32410"; // Replace with actual LINK token address

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    Bridging = await ethers.getContractFactory("Bridging");

    // Deploy the contract
    bridging = await Bridging.deploy("0xD3b06cEbF099CE7DA4AcCf578aaebFDBd6e88a93", linkTokenAddress);
    await bridging.deployed();
  });

  it("Should set the correct owner", async function () {
    expect(await bridging.owner()).to.equal(owner.address);
  });

  it("Should allow the owner to allowlist a destination chain", async function () {
    await expect(bridging.allowlistDestinationChain(destinationChainSelector, true))
      .to.emit(bridging, "msgRecieved") // emitted in onlyAllowlisted
      .withArgs(destinationChainSelector, owner.address);
    expect(await bridging.allowlistedDestinationChains(destinationChainSelector)).to.equal(true);
  });

  it("Should not allow non-owner to allowlist destination chain", async function () {
    await expect(
      bridging.connect(addr1).allowlistDestinationChain(destinationChainSelector, true)
    ).to.be.revertedWith("Ownable: caller is not the owner");
  });

  it("Should allow the owner to allowlist a sender", async function () {
    await bridging.allowlistSender(addr1.address, true);
    expect(await bridging.allowlistedSenders(addr1.address)).to.equal(true);
  });

  it("Should prevent token transfer if destination chain is not allowlisted", async function () {
    await expect(
      bridging.transferToken(destinationChainSelector, addr1.address, message, addr2.address)
    ).to.be.revertedWith("DestinationChainNotAllowlisted");
  });

  it("Should allow token transfer if destination chain is allowlisted", async function () {
    // Allowlist the destination chain
    await bridging.allowlistDestinationChain(destinationChainSelector, true);

    // Transfer tokens
    await expect(
      bridging.transferToken(destinationChainSelector, addr1.address, message, addr2.address)
    ).to.emit(bridging, "MessageSent"); // Confirm that MessageSent event was emitted
  });
});
