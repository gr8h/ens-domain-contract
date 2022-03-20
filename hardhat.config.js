require("@nomiclabs/hardhat-waffle");
require("dotenv").config();

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 module.exports = {
  solidity: "0.8.10",
  networks: {
		mumbai: {
         url: process.env.ALCHEMY_MUMBAI_URL,
         accounts: [process.env.PRIVATE_KEY],
		},
      mainnet: {
         chainId: 1,
         url: process.env.PROD_ALCHEMY_KEY,
         accounts: [process.env.PRIVATE_KEY],
       },
  }
};
