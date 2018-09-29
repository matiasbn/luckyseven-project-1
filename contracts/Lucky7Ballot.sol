/**
  * @author Matias Barrios
  * @version 1.0
  */

/** @title Lucky7Ballot. 
  * This contract contains all the functions to start a new game and deliver prizes.
  * Particularly contains function that have the business logic for generating Lucky7Numbers and Lucky7Tickets, order them, deliver prizes and clean necessary arrays.
*/

pragma solidity ^0.4.20;

import "./Lucky7Library.sol";
import "./Lucky7Admin.sol";
import "./Lucky7Storage.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Lucky7Ballot is Ownable{

    using SafeMath for uint256;
    /** @dev Address of the contracts to call functions
      */
    address lucky7AdminAddress;
    address lucky7StorageAddress;
    address lucky7TicketFactoryAddress;
    
    function constructor(address _lucky7AdminAddress, address _lucky7StorageAddress, address _lucky7TicketFactoryAddress) payable public{
        lucky7AdminAddress = _lucky7AdminAddress;
        lucky7TicketFactoryAddress = _lucky7TicketFactoryAddress;
        lucky7StorageAddress = _lucky7StorageAddress;
    }

    /** @dev setNewGame is a function designed to call all the functions necessary to start a new game. First, it activate the settingLucky7Numbers circuit breaker.
      * Then it stores and order the Lucky7Tickets in ascendante order depending on them difference values through the _orderLucky7Tickets. 
      * Then it set the prizes for the last winners to 0 (for security reasons), look up for Lucky7Tickets with owners different than 0 and update the 
      * pendingWithdrawals for the first, second and third winnner, deliver the prize for the enterprise, clean the necessary mappings and arrays (ExactLucky7Ticket and
      * lucky7NumbersArray), increase the drawNumber parameter to differentiate the Lucky7Tickets and Tickets from each different game in the future, and update the value
      * of the initialLucky7TicketPosition to store the Lucky7Tickets for every game correctly.
      */
    function setNewGame()                                      
        public 
        onlyOwner 
    {
        Lucky7TicketFactory lucky7TicketFactoryContract = Lucky7TicketFactory(lucky7TicketFactoryAddress);
        Lucky7Storage lucky7StorageContract = Lucky7Storage(lucky7StorageAddress);
        lucky7TicketFactoryContract.toggleLucky7Setting();
        lucky7StorageContract._orderLucky7Tickets();
        _deliverPrizes();
        lucky7StorageContract._cleanMappings();
    }
    
    /** @dev _deliverPrizes is a function designed to complete the business logic of the deliver prizes phase.
      * First, it takes the balance of prizes of the previous winners to 0 for security reasons (explained in the paper of the project).
      * Then it proceeds to calculate the amount of the prizes. The winners lot is 70% of the accumulated earnings,i.e. 70% of the contract balance.
      * Of that amount:
      * First prize: 25%
      * Second prize: 21% 
      * Third prize: 18%
      * Fourth prize: 14%
      * Fifth prize: 11%
      * Sixth prize: 7%
      * Seventh prize: 4%
      * The function then proceeds to check if, starting in the initialLucky7TicketPosition (the first Lucky7Ticket of the current game ordered by difference in ascending order)
      * belongs to a user, i.e. it address is not 0. If it's different than 0, then sets the prize for that address to the first prize amount on the pendingWithdrawals mapping, 
      * saves it adddress in lastFirstPrizeWinner to set it prize to 0 in the next new game setting and breaks the loop to deliver the second place prize.
      * It is not automatically delivered to the first prize winner to avoid DoS with (Unexpected) revert attack, i.e. one or more of the winners address isn't
      * capable of receiving ether and cut the transaction, stucking the contract function to deliver prizes to real winners.
      * After update the pendingWithdrawals mapping for payment for the first prize winner, it proceeds the same way with the second and third winner, to finally deliver the
      * enterprise prize automatically, because is a known address and is first setted as the owner of the contract. 
      */
    function _deliverPrizes() 
        public 
        onlyOwner
    {
        uint winnersPrize = address(this).balance.mul(7);
        winnersPrize = winnersPrize.div(100);
        uint firstPrize = winnersPrize.mul(25);
        uint secondPrize = winnersPrize.mul(21);
        uint thirdPrize = winnersPrize.mul(18);
        uint fourthPrize = winnersPrize.mul(14);
        uint fifthPrize = winnersPrize.mul(11);
        uint sixthPrize = winnersPrize.mul(7);
        uint seventhPrize = winnersPrize.mul(4);
        Lucky7Storage lucky7StorageContract = Lucky7Storage(lucky7StorageAddress);
        lucky7StorageContract.setWinners(firstPrize,secondPrize,thirdPrize,fourthPrize,fifthPrize,sixthPrize,seventhPrize);

        address enterpriseWallet = Lucky7Library.enterpriseWallet(lucky7AdminAddress);
        uint enterprisePrize = address(this).balance.mul(30);
        enterprisePrize = enterprisePrize.div(100);
        enterpriseWallet.transfer(enterprisePrize);
    }

    /** @dev withdraw is a function used for winners to claim them prices. It is updated in the _deliverPrizesFunction of this contract to
      * state the owners of the first, second and third prize. It is used to avoid DoS with (Unexpected) revert attack.
      */
    function withdraw() 
        public 
    {
        Lucky7Storage lucky7StorageContract = Lucky7Storage(lucky7StorageAddress);
        uint amount = lucky7StorageContract.pendingWithdrawals(msg.sender);
        lucky7StorageContract.setPendingWithdrawalToZero(msg.sender);
        msg.sender.transfer(amount);
    }

    
    /** @dev Fallback function to make this contract payable.
      */
    function () public payable {
        
    }
}