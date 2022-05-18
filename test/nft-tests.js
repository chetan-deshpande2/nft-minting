const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFT", function () {
  beforeEach(async function () {
    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy();
    await nft.deployed();
  });

  it("Should return minter role", async function () {
    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy();
    await nft.deployed();

    const minterRole = await nft.MINTER_ROLE();

    console.log(minterRole);
    expect(minterRole).to.equal(
      "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"
    );
  });
});
