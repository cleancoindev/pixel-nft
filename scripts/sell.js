const opensea = require("opensea-js");
const OpenSeaPort = opensea.OpenSeaPort;
const Network = opensea.Network;

const HDWalletProvider = require("truffle-hdwallet-provider");
const MnemonicWalletSubprovider = require("@0x/subproviders")
  .MnemonicWalletSubprovider;
const RPCSubprovider = require("web3-provider-engine/subproviders/rpc");
const web3 = require("web3");
const Web3ProviderEngine = require("web3-provider-engine");
const MNEMONIC = process.env.MNEMONIC;
const INFURA_KEY = process.env.INFURA_KEY;
const FACTORY_CONTRACT_ADDRESS = process.env.FACTORY_CONTRACT_ADDRESS;
const OWNER_ADDRESS = process.env.OWNER_ADDRESS;
const NETWORK = process.env.NETWORK;

const FIXED_PRICE_SINGLE_ITEM_OPTION_ID = "0";
const FIXED_PRICE_MULTIPLE_ITEMS_OPTION_ID = "1";
const NUM_FIXED_PRICE_SINGLE_ITEM_AUCTIONS = 5000;
const NUM_FIXED_PRICE_MULTIPLE_ITEMS_AUCTIONS = 200; // 200 * 25 = 5000
const FIXED_PRICE_SINGLE_ITEM = 0.1;
const FIXED_PRICE_MULTIPLE_ITEMS = 2.5; // eth

if (!MNEMONIC || !INFURA_KEY || !NETWORK || !OWNER_ADDRESS) {
  console.error(
    "Please set a mnemonic, infura key, owner, network, and contract address."
  );
  return;
}
const BASE_DERIVATION_PATH = `44'/60'/0'/0`;
const mnemonicWalletSubprovider = new MnemonicWalletSubprovider({
  mnemonic: MNEMONIC,
  baseDerivationPath: BASE_DERIVATION_PATH
});
const infuraRpcSubprovider = new RPCSubprovider({
  rpcUrl: "https://" + NETWORK + ".infura.io/" + INFURA_KEY
});

const providerEngine = new Web3ProviderEngine();
providerEngine.addProvider(mnemonicWalletSubprovider);
providerEngine.addProvider(infuraRpcSubprovider);
providerEngine.start();

const seaport = new OpenSeaPort(
  providerEngine,
  {
    networkName: Network.Rinkeby
  },
  arg => console.log(arg)
);

async function main() {
  if (FACTORY_CONTRACT_ADDRESS) {
    console.log("Creating fixed price single item auctions...");
    for (var i = 0; i < NUM_FIXED_PRICE_SINGLE_ITEM_AUCTIONS; i++) {
      const sellOrder = await seaport.createSellOrder({
        tokenId: FIXED_PRICE_SINGLE_ITEM_OPTION_ID,
        tokenAddress: FACTORY_CONTRACT_ADDRESS,
        accountAddress: OWNER_ADDRESS,
        startAmount: FIXED_PRICE_SINGLE_ITEM
      });
      console.log(sellOrder);
    }

    console.log("Creating fixed price multiple items auctions...");
    for (var i = 0; i < NUM_FIXED_PRICE_MULTIPLE_ITEMS_AUCTIONS; i++) {
      const sellOrder = await seaport.createSellOrder({
        tokenId: FIXED_PRICE_MULTIPLE_ITEMS_OPTION_ID,
        tokenAddress: FACTORY_CONTRACT_ADDRESS,
        accountAddress: OWNER_ADDRESS,
        startAmount: FIXED_PRICE_MULTIPLE_ITEMS
      });
      console.log(sellOrder);
    }
  }
}

main();
