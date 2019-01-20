const Pixel = artifacts.require("./Pixel.sol");
const PixelFactory = artifacts.require("./PixelFactory.sol");

module.exports = function(deployer, network) {
  // OpenSea proxy registry addresses for rinkeby and mainnet.
  let proxyRegistryAddress = "";
  if (network === "rinkeby") {
    proxyRegistryAddress = "0xf57b2c51ded3a29e6891aba85459d600256cf317";
  } else {
    proxyRegistryAddress = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
  }

  deployer
    .deploy(Pixel, proxyRegistryAddress, { gas: 5000000 })
    .then(() => {
      return deployer.deploy(
        PixelFactory,
        proxyRegistryAddress,
        Pixel.address,
        { gas: 7000000 }
      );
    })
    .then(async () => {
      var pixel = await Pixel.deployed();
      return pixel.transferOwnership(PixelFactory.address);
    });
};
