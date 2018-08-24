module.exports = {
  networks: {
      development: {
          host: "localhost",
          port: 8545, // Using ganache as development network
          network_id: "*",
      }
  },
  solc: {
      optimizer: {
          enabled: true,
          runs: 200
      }
  }
};