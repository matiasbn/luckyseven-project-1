module.exports = {
  networks: {
      development: {
          host: "localhost",
          port: 8545, // Using ganache as development network
          network_id: "*",
          gas: 4000000000
      }
  },
  solc: {
      optimizer: {
          enabled: true,
          runs: 200
      }
  }
};