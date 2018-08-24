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
    $(document).on('click', '.btn-random-ticket', App.randomTicket);
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
         var numbersTemplate = $('#numbersTemplate');
         var mainTemplate = $('#mainTemplate');
         mainTemplate.find('.account').text(account);
         numbersTemplate.find('.ticket').text(result[2]);
         numbersTemplate.find('.first-parameter').text(result[0]);
         numbersTemplate.find('.second-parameter').text(result[1]);
         return lucky7Instance.getlucky7Numbers.call();
      }).then(function(lucky7Numbers) {
        var numbersTemplate = $('#lucky7Numbers');
        numbersTemplate.find('.firstNumber').text(lucky7Numbers[0]);
        numbersTemplate.find('.secondNumber').text(lucky7Numbers[1]);
        numbersTemplate.find('.thirdNumber').text(lucky7Numbers[2]);
        numbersTemplate.find('.fourthNumber').text(lucky7Numbers[3]);
        numbersTemplate.find('.fifthNumber').text(lucky7Numbers[4]);
        numbersTemplate.find('.sixthNumber').text(lucky7Numbers[5]);
        numbersTemplate.find('.seventhNumber').text(lucky7Numbers[6]);
        return lucky7Instance.getlucky7Tickets.call();
      }).then(function(lucky7Tickets){
        var numbersTemplate = $('#lucky7Tickets');
        numbersTemplate.find('.firstTicket').text(lucky7Tickets[0]);
        numbersTemplate.find('.secondTicket').text(lucky7Tickets[1]);
        numbersTemplate.find('.thirdTicket').text(lucky7Tickets[2]);
        numbersTemplate.find('.fourthTicket').text(lucky7Tickets[3]);
        numbersTemplate.find('.fifthTicket').text(lucky7Tickets[4]);
        numbersTemplate.find('.sixthTicket').text(lucky7Tickets[5]);
        numbersTemplate.find('.seventhTicket').text(lucky7Tickets[6]);
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },

  randomTicket: function(event) {
    event.preventDefault();
    var lucky7Instance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.Lucky7Store.deployed().then(function(instance) {
        lucky7Instance = instance;
        return lucky7Instance.sellTicketPrice();
      }).then(function(result){
        var sellTicketPrice = parseInt(result);
        return lucky7Instance.sellRandomTicket({from: account, value: sellTicketPrice});
      }).then(function(result){
        console.log(parseInt(result));
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },

  generateTicket: function(event) {
    event.preventDefault();
    var lucky7Instance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.Lucky7Store.deployed().then(function(instance) {
        lucky7Instance = instance;
        return lucky7Instance.generateTicketPrice();
      }).then(function(result){
        var generateTicketPrice = parseInt(result);
        console.log(generateTicketPrice);
        return lucky7Instance.generateRandomTicket({from: account, value: generateTicketPrice});
      }).then(function(result){
        console.log(parseInt(result));
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },

  buyTicket: function(event) {
    event.preventDefault();
    var lucky7Instance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.Lucky7Store.deployed().then(function(instance) {
        lucky7Instance = instance;
        return lucky7Instance.sellTicketPrice();
      }).then(function(result){
        var sellTicketPrice = parseInt(result);
        return lucky7Instance.sellGeneratedTicket({from: account, value: sellTicketPrice});
      }).then(function(result){
        console.log(parseInt(result));
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
