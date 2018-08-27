/**
  * @author Matias Barrios
  * @version 1.0
  */

/** @title Lucky7FrontFunctions. 
  * This contract contains all the functions to interact with front end.
  * Is not going to be tested.
*/

pragma solidity ^0.4.20;

import "./Lucky7Store.sol";

contract Lucky7FrontEndFunctions is Lucky7Store{
    function Lucky7FrontEndFunctions() payable {
        
    }

    /** @dev Function to get the contract balance
    */
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    /** @dev Function to get the lucky7NumbersArray, i.e. the array which contains the Lucky7Numbers
      */
    function getlucky7Numbers() public view returns (uint[7]) {
        uint[7] memory luckySevenNumbers;
        for(uint i=0; i<numberOfLucky7Numbers; i++){
            luckySevenNumbers[i]=lucky7NumbersArray[i].ticketValue;
        }
        return luckySevenNumbers;
    }
    
    /** @dev Function to get the lucky7Tickets, i.e. the mapping which contains the Lucky7Tickets
      * @return an array containing the value of the Lucky7Ticket, i.e. the value of the user ticket
      */
    function getlucky7TicketsValue() public view returns (uint[7]) {
        uint[7] memory luckySevenTickets;
        for(uint i=0; i<numberOfLucky7Numbers; i++){
            if(lucky7TicketOwner[i]!=address(0x0)){
                luckySevenTickets[i] = ticketsArray[lucky7TicketID[i]].ticketValue;
            }
            else{
                luckySevenTickets[i]=0;
            }
        }
        return luckySevenTickets;
    }

    /** @dev Function to get the lucky7TicketDiffernce, i.e. the mapping which contains the difference between
      * Lucky7Tickets[i] and Lucky7Number[i] in absolut value
      * @return an array containing those differences
      */
    function getLucky7TicketDifference() public view returns (uint[7]) {
        uint[7] memory luckySevenTicketDifference;
        for(uint i=0; i<numberOfLucky7Numbers; i++){
            if(lucky7TicketOwner[i]!=address(0x0)){
                luckySevenTicketDifference[i] = lucky7TicketDifference[i];
            }
            else{
                luckySevenTicketDifference[i]=123456789012345678907;
            }
        }
        return luckySevenTicketDifference;
    }

    /** @dev Function to get the lucky7TicketOwner, i.e. the mapping which contains the owners
      * of the Lucky7Tickets
      * @return an array containing those differences
      */
    function getLucky7TicketOwner() public view returns (address[7]) {
        address[7] memory luckySevenTicketOwner;
        for(uint i=0; i<numberOfLucky7Numbers; i++){
            luckySevenTicketOwner[i] = lucky7TicketOwner[i];
        }
        return luckySevenTicketOwner;
    }

    /** @dev Function to get the difference of the Lucky7Ticket that belogs to an user.
      * @param _lucky7TicketOwner is the owner which we want to know the difference
      */
    function getLastLucky7Difference(address _lucky7TicketOwner) public view returns (uint) {
        uint difference;
        if(drawNumber>0){
          for(uint i=(drawNumber-1)*numberOfLucky7Numbers; i<drawNumber*numberOfLucky7Numbers; i++){
            if(lucky7TicketsArray[i].owner == _lucky7TicketOwner){
              difference = lucky7TicketsArray[i].difference;
              break;
            }
          }
        }
        
        return difference;
    }
}