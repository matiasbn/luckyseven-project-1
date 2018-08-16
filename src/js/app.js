App = {
  web3Provider: null,
  contracts: {},

  init: function() {
    // Is there an injected web3 instance?
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
    } else {
      // If no injected web3 instance is detected, fall back to Ganache
      App.web3Provider = new Web3.providers.HttpProvider('http://127.0.0.1:8545');
    }
    web3 = new Web3(App.web3Provider);


    return App.initContract();
  },

  initContract: function() {
    $.getJSON('Lucky7Store.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var Lucky7Artifact = data;
      App.contracts.Lucky7Store = TruffleContract(Lucky7Artifact);

      // Set the provider for our contract
      App.contracts.Lucky7Store.setProvider(App.web3Provider);

      // Use our contract to retrieve and mark the adopted pets
      return App.retrieveTicket();
    });

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-generate-ticket', App.generateTicket);
    $(document).on('click', '.btn-buy-ticket', App.buyTicket);
  },

  retrieveTicket: function(numbers, account) {
    var lucky7Instance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.Lucky7Store.deployed().then(function(instance) {
        lucky7Instance = instance;

        // Execute adopt as a transaction by sending account
        return lucky7Instance.userValues(account);
      }).then(function(result) {
         console.log(result);
         var numbersTemplate = $('#numbersTemplate');
         numbersTemplate.find('.ticket').text(result[2]);
         numbersTemplate.find('.first-parameter').text(result[0]);
         numbersTemplate.find('.second-parameter').text(result[1]);
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },

  generateTicket: function() {
    console.log("generateTicket");
    var lucky7Instance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.Lucky7Store.deployed().then(function(instance) {
        lucky7Instance = instance;

        // Execute adopt as a transaction by sending account
        return lucky7Instance.askForMuParameter({from: account});
      }).then(function(result) {
         console.log(result);
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },

  buyTicket: function(event) {
    event.preventDefault();

    var petId = parseInt($(event.target).data('id'));

    var lucky7Instance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.Lucky7.deployed().then(function(instance) {
        lucky7Instance = instance;

        // Execute adopt as a transaction by sending account
        return lucky7Instance.adopt(petId, {from: account});
      }).then(function(result) {
        return App.markAdopted();
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
