/**
  * @author Matias Barrios
  * @version 1.0
  */

/** @title Lucky7Ballot. 
  * This contract contains all the functions to start a new game and deliver prizes.
  * Particularly contains function that have the business logic for generating Lucky7Numbers and Lucky7Tickets
  * ordering them, deliver prizes and clean necessary arrays.
*/

pragma solidity ^0.4.20;

import "./Lucky7TicketFactory.sol";

contract Lucky7Ballot is Lucky7TicketFactory{
    
    event NewPrizeStored(uint prizeAmoun, address prizeOwner);

    function Lucky7Ballot() payable {
        
    }

    /** @param initialLucky7TicketPosition is a uint used for the _orderLucky7Tickets function of this contract. 
      * Because is necessary to store the information of previous games permanently is necessary then to know what it the starting point to store in the 
      * lucky7TicketsArray array of the Lucky77TicketFactory.sol contract. 
      * This way, the _orderLucky7Tickets function starts storing in the "initialLucky7TicketPosition" and finish storing in the 
      * "numberOfLucky7Numbers+initialLucky7TicketPosition" position of the lucky7TicketsArray array. 
      * Defaults to 0, and is getting incremented by "numberOfLucky7Numbers" value every time the setNewGame function of this contract is called.
      * @param currentTicketID is a uint which points to the position in the ticketsArray array of the Lucky7TicketFactory contract where was pushed the last ticket
      * inserted by the insertCustomizedTicket function of this contract. That function and this parameter are used for testing purposes only.
      * @param lastFirstParameter is and address which stores the address of the last first prize winner. Is setted on the _deliverPrizes function of this contract 
      * and is used to set to 0 the amount of the prize for the last first prize winner before start delivering prizes for security reasons.
      * @param lastSecondParameter is and address which stores the address of the last second prize winner. Is setted on the _deliverPrizes function of this contract 
      * and is used to set to 0 the amount of the prize for the last second prize winner before start delivering prizes for security reasons.
      * @param lastThirdParameter is and address which stores the address of the last third prize winner. Is setted on the _deliverPrizes function of this contract 
      * and is used to set to 0 the amount of the prize for the last third prize winner before start delivering prizes for security reasons.
      * @param pendingWithdrawals is a mapping that points from an address to an uint. Is used for the _deliverPrizes function of this contract to store the 
      * the correspondent prize with the correspondent winner. The prizes are setted to 0 every time the _deliverPrizes function is called for security reasons.
      * To claim a prize, user have to call the withdraw function of this contract, so the prize is delivered and the amount for him prize is setted to 0 again.
      */
    uint public initialLucky7TicketPosition = 0;
    uint public currentTicketID = 0;
    address public lastFirstPrizeWinner = address(0);
    address public lastSecondPrizeWinner = address(0);
    address public lastThirdPrizeWinner = address(0);
    mapping (address => uint) public pendingWithdrawals;


    function setNewGame()                                      
        public 
        onlyOwner 
    {
        toggleLucky7Setting();
        _orderLucky7Tickets();
        _deliverPrizes();
        _cleanMappings();
        drawNumber++;
        initialLucky7TicketPosition+=drawNumber*numberOfLucky7Numbers;
    }
    
    function _generateLucky7Number() public onlyOwner{
        if(indexForLucky7Array == numberOfLucky7Numbers){
            _orderLucky7Numbers();
            indexForLucky7Array = 0;
            toggleLucky7Setting();
        }
        else{
            userValues[this].muReady = false;
            userValues[this].iReady = false;
            _generateTicket(this);
        }
    }
    
    
    function _orderLucky7Numbers() public onlyOwner{
        Lucky7Number memory smallest;
        uint aux;
        uint j;
        uint i;
        for(i=0; i<numberOfLucky7Numbers; i++){
            aux = i;
            smallest = lucky7NumbersArray[i];
            for (j=i+1; j<numberOfLucky7Numbers; j++){
                if(smallest.ticketValue>lucky7NumbersArray[j].ticketValue){
                    smallest = lucky7NumbersArray[j];
                    aux = j;
                }
            }
            if(aux!=i){
                lucky7NumbersArray[aux]=lucky7NumbersArray[i];
                lucky7NumbersArray[i] = smallest;
            }
        }
    }
    
    function _orderLucky7Tickets() public onlyOwner{
        Lucky7Ticket memory smallest;
        uint aux;
        uint i;
        uint j;
        uint k;
        for (i=0; i<numberOfLucky7Numbers; i++){
            lucky7TicketsArray.push(
                // struct Lucky7Ticket{
                //     uint difference;
                //     address owner;
                //     uint ticketID;
                //     uint ticketValue;
                //     uint lucky7Number;
                //     uint lucky7NumberID;
                //     uint drawID;
                // }
                Lucky7Ticket(
                    lucky7TicketDifference[i],
                    lucky7TicketOwner[i],
                    lucky7TicketID[i],
                    ticketsArray[lucky7TicketID[i]].ticketValue,
                    lucky7NumbersArray[i].ticketValue,
                    i,
                    drawNumber)
                    );
        }
        for(j=initialLucky7TicketPosition; j<numberOfLucky7Numbers+initialLucky7TicketPosition; j++){
            aux = j;
            smallest = lucky7TicketsArray[j];
            emit NewPrizeStored(j,lucky7TicketsArray[j].owner);
            for (k=j+1; k<numberOfLucky7Numbers+initialLucky7TicketPosition; k++){
                if(smallest.difference>lucky7TicketsArray[k].difference){
                    smallest = lucky7TicketsArray[k];
                    aux = k;
                }
            }
            if(aux!=j){
                lucky7TicketsArray[aux]=lucky7TicketsArray[j];
                lucky7TicketsArray[j] = smallest;

            }
        }
    }

    function _deliverPrizes() public onlyOwner{
        pendingWithdrawals[lastFirstPrizeWinner] = 0;
        pendingWithdrawals[lastSecondPrizeWinner] = 0;
        pendingWithdrawals[lastThirdPrizeWinner] = 0;
        uint winnersPrize = address(this).balance.mul(7);
        winnersPrize = winnersPrize.div(10);
        uint firstPrize = winnersPrize.mul(6);
        uint secondPrize = winnersPrize.mul(3);
        uint thirdPrize = winnersPrize.mul(1);
        firstPrize = firstPrize.div(10);
        secondPrize = secondPrize.div(10);
        thirdPrize = thirdPrize.div(10);
        uint i;
        for(i=initialLucky7TicketPosition; i<numberOfLucky7Numbers+initialLucky7TicketPosition; i++){
            if(lucky7TicketsArray[i].owner!=address(0x0)){
                pendingWithdrawals[lucky7TicketsArray[i].owner] += firstPrize;
                lastFirstPrizeWinner = lucky7TicketsArray[i].owner;
                break;
            }
        }
        
        for(i++; i<numberOfLucky7Numbers+initialLucky7TicketPosition; i++){
            if(lucky7TicketsArray[i].owner!=address(0x0)){
                pendingWithdrawals[lucky7TicketsArray[i].owner] += secondPrize;
                lastSecondPrizeWinner = lucky7TicketsArray[i].owner;
                break;
            }
        }
        
        for(i++; i<numberOfLucky7Numbers+initialLucky7TicketPosition; i++){
            if(lucky7TicketsArray[i].owner!=address(0x0)){
                pendingWithdrawals[lucky7TicketsArray[i].owner] += thirdPrize;
                lastThirdPrizeWinner = lucky7TicketsArray[i].owner;
                break;
            }
        }
        uint enterprisePrize = address(this).balance.mul(3);
        enterprisePrize = enterprisePrize.div(10);
        enterpriseWallet.transfer(enterprisePrize);
    }
    //Should clean lucky7TicketDifference[i], lucky7TicketOwner[i], lucky7TicketID[i],
    function _cleanMappings() public{
        for(uint i=0; i<numberOfLucky7Numbers; i++){
            lucky7TicketDifference[i]=0;
            lucky7TicketOwner[i]=0;
            lucky7TicketID[i]=0;
            lucky7NumbersArray[i].mu="0";
            lucky7NumbersArray[i].i="0";
            lucky7NumbersArray[i].ticketValue=0;
            lucky7NumbersArray[i].drawID=drawNumber;
            ExactLucky7TicketValue[i]=0;
            ExactLucky7TicketOwner[i]=0;
            ExactLucky7TicketID[i]=0;
        }
        indexForExactLucky7Ticket =0;
    }

    function withdraw() public {
        uint amount = pendingWithdrawals[msg.sender];
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }


    //For front-end conection
    function getlucky7Numbers() public view returns (uint[7]) {
        uint[7] luckySevenNumbers;
        for(uint i=0; i<numberOfLucky7Numbers; i++){
            luckySevenNumbers[i]=lucky7NumbersArray[i].ticketValue;
        }
        return luckySevenNumbers;
    }

    function getlucky7Tickets() public view returns (uint[7]) {
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

    //For testing purposes
    function insertCustomizedLucky7Number(uint _id, string _mu, string _i, uint _ticketValue,uint _drawNumber) public onlyOwner{
        lucky7NumbersArray[_id] = Lucky7Number(_mu, _i, _ticketValue, _drawNumber);
    }
    

    function insertCustomizedTicket(string _mu, string _i, uint _ticketValue,address _ticketOwner, uint _drawNumber) 
        public 
        onlyOwner 
        returns (uint){
            uint id = ticketsArray.push(Ticket(_mu,_i,_ticketValue,_ticketOwner,_drawNumber)) - 1;
            currentTicketID = id;
        }
    
    function setIndexForLucky7Array(uint _newValue) public onlyOwner{
        indexForLucky7Array = _newValue;
    }

    function setInitialLucky7TicketPosition(uint _newValue) public onlyOwner{
        initialLucky7TicketPosition = _newValue;
    }
    
    function () public payable {
        
    }
}