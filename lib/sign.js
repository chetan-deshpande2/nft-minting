const SINGNATURE_DOMAIN_NAME = "NFT";
const SINGNATURE_DOMAIN_VERSION = "1";

class SignHelper {
  constructor(constructorAddress, chainId, signer) {
    this.constructorAddress = constructorAddress;
    this.chainId = chainId;
    this.signer = signer;
  }

  async createSignature(tokenId, uri, price) {
    const sign = { tokenId, uri, price };
    const domain = await this._signingDomain();
    const types = {
      Signature: [
        {
          name: "tokenId",
          type: "uint256",
        },
        { name: "uri", type: "string" },
        { name: "price", type: "uint256" },
      ],
    };

    const signature = await this.signer._signTypedData(domain, types, sign);
    return { ...sign, signature };
  }

  async _signingDomain() {
    if (this._domain != null) {
      return this._domain;
    }
    const chainId = await this.contract.getChainID();
    this._domain = {
      name: SIGNING_DOMAIN_NAME,
      version: SIGNING_DOMAIN_VERSION,
      verifyingContract: this.contract.address,
      chainId,
    };
    return this._domain;
  }

  static async getSign(contractAddress, chainId, signer) {
    var provider = new ethers.providers.Web3Provider(window.ethereum);

    await provider.send("eth_requestAccounts", []);
    let signer = provider.getSigner();
    await signer.getAddress();
    await signer.getAddress();
    var lm = new SignHelper(contractAddress, chainId, signer);
    let voucher = await lm.createSignature(tokenId);
    return voucher;
  }
}
