require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

// Sample Hardhat task
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// Export an object to set up the config
// https://hardhat.org/config/

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  networks: {
    rinkeby: {
      url: process.env.STAGING_ALCHEMY_KEY,
      accounts: [process.env.ACCOUNT_PRIVATE_KEY],
    },
    // mainnet: {
    //   chainId: 1,
    //   url: process.env.PROD_ALCHEMY_KEY,
    //   accounts: [process.env.ACCOUNT_PRIVATE_KEY],
    // },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};
