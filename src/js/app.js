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
    $.getJSON('Lucky7FrontEndFunctions.json', function(data) {
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
    $(document).on('click', '.btn-claim-prize', App.claimPrize);
  },

  retrieveTicket: function(numbers, account) {
    var lucky7Instance;
    var lastFirstPrizeWinner;
    var lastSecondPrizeWinner;
    var lastThirdPrizeWinner;
    var usersLastPrize;
    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];
      App.contracts.Lucky7Store.deployed().then(function(instance) {
        lucky7Instance = instance;
        return lucky7Instance.userValues(account);
      }).then(function(result) {
         var userTicketsTemplate = $('#userTicketsTemplate');
         var mainTemplate = $('#mainTemplate');
         var purchasedParameters = $('#purchasedParameters');
         mainTemplate.find('.account').text(account);
         userTicketsTemplate.find('.ticket').text(result[2]);
         purchasedParameters.find('.first-parameter').text(result[0]);
         purchasedParameters.find('.second-parameter').text(result[1]);
         return lucky7Instance.drawNumber();
      }).then(function(drawID) {
        var mainTemplate = $('#mainTemplate');
        mainTemplate.find('.gameID').text(drawID);
        return lucky7Instance.pendingWithdrawals(account);
      }).then(function(userPrize) {
        var mainTemplate = $('#mainTemplate');
        mainTemplate.find('.userPrize').text(web3.fromWei(userPrize,"ether")+" ETH");
         return lucky7Instance.sellTicketPrice();
      }).then(function(sellTicketPrice) {
        var mainTemplate = $('#mainTemplate');
        mainTemplate.find('.sellTicketPrice').text(web3.fromWei(sellTicketPrice,"ether")+" ETH");
        return lucky7Instance.generateTicketPrice();
      }).then(function(generateTicketPrice) {
        var mainTemplate = $('#mainTemplate');
        mainTemplate.find('.generateTicketPrice').text(web3.fromWei(generateTicketPrice,"ether")+" ETH");
        return lucky7Instance.getlucky7Numbers.call();
      }).then(function(lucky7Numbers) {
        for (i = 0; i < lucky7Numbers.length; i++) {
          if (lucky7Numbers[i] == 0){
            lucky7Numbers[i] = "Still not generated"
          }
        }
        var numbersTemplate = $('#lucky7Numbers');
        numbersTemplate.find('.firstNumber').text(lucky7Numbers[0]);
        numbersTemplate.find('.secondNumber').text(lucky7Numbers[1]);
        numbersTemplate.find('.thirdNumber').text(lucky7Numbers[2]);
        numbersTemplate.find('.fourthNumber').text(lucky7Numbers[3]);
        numbersTemplate.find('.fifthNumber').text(lucky7Numbers[4]);
        numbersTemplate.find('.sixthNumber').text(lucky7Numbers[5]);
        numbersTemplate.find('.seventhNumber').text(lucky7Numbers[6]);
        return lucky7Instance.getlucky7TicketsValue.call();
      }).then(function(lucky7Tickets){
        for (i = 0; i < lucky7Tickets.length; i++) {
          if (lucky7Tickets[i] == 0){
            lucky7Tickets[i] = "Still vacant"
          }
        }
        var numbersTemplate = $('#lucky7Tickets');
        numbersTemplate.find('.firstTicket').text(lucky7Tickets[0]);
        numbersTemplate.find('.secondTicket').text(lucky7Tickets[1]);
        numbersTemplate.find('.thirdTicket').text(lucky7Tickets[2]);
        numbersTemplate.find('.fourthTicket').text(lucky7Tickets[3]);
        numbersTemplate.find('.fifthTicket').text(lucky7Tickets[4]);
        numbersTemplate.find('.sixthTicket').text(lucky7Tickets[5]);
        numbersTemplate.find('.seventhTicket').text(lucky7Tickets[6]);
       return lucky7Instance.getLucky7TicketDifference.call();
      }).then(function(lucky7TicketDifference){
        for (i = 0; i < lucky7TicketDifference.length; i++) {
          if (lucky7TicketDifference[i] == 123456789012345678907){
            lucky7TicketDifference[i] = "Still vacant"
          }
          if (lucky7TicketDifference[i] == 0){
            lucky7TicketDifference[i] = "ExactLucky7Ticket!"
          }
        }
        var differenceTemplate = $('#lucky7Difference');
        differenceTemplate.find('.firstDifference').text(lucky7TicketDifference[0]);
        differenceTemplate.find('.secondDifference').text(lucky7TicketDifference[1]);
        differenceTemplate.find('.thirdDifference').text(lucky7TicketDifference[2]);
        differenceTemplate.find('.fourthDifference').text(lucky7TicketDifference[3]);
        differenceTemplate.find('.fifthDifference').text(lucky7TicketDifference[4]);
        differenceTemplate.find('.sixthDifference').text(lucky7TicketDifference[5]);
        differenceTemplate.find('.seventhDifference').text(lucky7TicketDifference[6]);
        return lucky7Instance.getLucky7TicketOwner.call();
      }).then(function(lucky7TicketOwner){
        for (i = 0; i < lucky7TicketOwner.length; i++) {
          if (lucky7TicketOwner[i] == 0){
            lucky7TicketOwner[i] = "Still vacant"
          }
        }
        var ownerTemplate = $('#lucky7Owner');
        ownerTemplate.find('.firstOwner').text(lucky7TicketOwner[0]);
        ownerTemplate.find('.secondOwner').text(lucky7TicketOwner[1]);
        ownerTemplate.find('.thirdOwner').text(lucky7TicketOwner[2]);
        ownerTemplate.find('.fourthOwner').text(lucky7TicketOwner[3]);
        ownerTemplate.find('.fifthOwner').text(lucky7TicketOwner[4]);
        ownerTemplate.find('.sixthOwner').text(lucky7TicketOwner[5]);
        ownerTemplate.find('.seventhOwner').text(lucky7TicketOwner[6]);
        
        return lucky7Instance.lastFirstPrizeWinner();
      }).then(function(lastWinner){
        lastFirstPrizeWinner = lastWinner
        var lastTemplate = $('#lastWinners');
        lastTemplate.find('.lastFirstOwner').text(lastFirstPrizeWinner);
        return lucky7Instance.getLastLucky7Difference(lastFirstPrizeWinner);
      }).then(function(difference){
        var lastTemplate = $('#lastWinners');
        lastTemplate.find('.lastFirstDifference').text(difference);
        return lucky7Instance.lastFirstPrizeAmount();
      }).then(function(amount){
        var lastTemplate = $('#lastWinners');
        lastTemplate.find('.lastFirstAmount').text(web3.fromWei(amount,"ether")+" ETH");
        
        return lucky7Instance.lastSecondPrizeWinner();
      }).then(function(winner){
        lastSecondPrizeWinner = winner
        var lastTemplate = $('#lastWinners');
        lastTemplate.find('.lastSecondOwner').text(winner);
        return lucky7Instance.getLastLucky7Difference(winner);
      }).then(function(difference){
        var lastTemplate = $('#lastWinners');
        lastTemplate.find('.lastSecondDifference').text(difference);
        return lucky7Instance.lastSecondPrizeAmount();
      }).then(function(amount){
        var lastTemplate = $('#lastWinners');
        lastTemplate.find('.lastSecondAmount').text(web3.fromWei(amount,"ether")+" ETH");
        
        return lucky7Instance.lastThirdPrizeWinner();
      }).then(function(lastWinner){
        lastThirdPrizeWinner = lastWinner
        var lastTemplate = $('#lastWinners');
        lastTemplate.find('.lastThirdOwner').text(lastWinner);
        return lucky7Instance.getLastLucky7Difference(lastWinner);
      }).then(function(difference){
          var lastTemplate = $('#lastWinners');
          lastTemplate.find('.lastThirdDifference').text(difference);
          return lucky7Instance.lastThirdPrizeAmount();
      }).then(function(amount){
          var lastTemplate = $('#lastWinners');
          lastTemplate.find('.lastThirdAmount').text(web3.fromWei(amount,"ether")+" ETH");
          return lucky7Instance.pendingWithdrawals(lastFirstPrizeWinner);
      }).then(function(amount){
        usersLastPrize=parseFloat(web3.fromWei(amount,"ether"))
        return lucky7Instance.pendingWithdrawals(lastSecondPrizeWinner);
      }).then(function(amount){
        usersLastPrize=usersLastPrize + parseFloat(web3.fromWei(amount,"ether"))
        return lucky7Instance.pendingWithdrawals(lastThirdPrizeWinner);
      }).then(function(amount){
        usersLastPrize=usersLastPrize + parseFloat(web3.fromWei(amount,"ether"))
        return lucky7Instance.getBalance.call();
      }).then(function(accountBalance) {
        var totalPrize = 0.7*(parseFloat(web3.fromWei(accountBalance,"ether"))-usersLastPrize)
        var firstPrize = totalPrize*0.6
        var secondPrize = totalPrize*0.3
        var thirdPrize = totalPrize*0.1
        var mainTemplate = $('#mainTemplate');
        mainTemplate.find('.totalPrize').text(totalPrize+" ETH");
        mainTemplate.find('.firstPrize').text(firstPrize+" ETH");
        mainTemplate.find('.secondPrize').text(secondPrize+" ETH");
        mainTemplate.find('.thirdPrize').text(thirdPrize+" ETH");
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
        return lucky7Instance.generateRandomTicket({from: account, value: generateTicketPrice});
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
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },

  claimPrize: function(event) {
    event.preventDefault();
    var lucky7Instance;
    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.Lucky7Store.deployed().then(function(instance) {
        lucky7Instance = instance;
        return lucky7Instance.withdraw();
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
