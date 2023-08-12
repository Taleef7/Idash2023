require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545/",
    },
  },
  contracts: {
    deploy: [
      {
        contract: "DynamicConsent",
        gasLimit: 300000000, // Adjust this value as needed
      },
    ],
  },
};
