pragma solidity ^0.4.20;

import "./Lucky7TicketFactory.sol";

contract Lucky7Ballot is Lucky7TicketFactory{
    
    function Lucky7Ballot() payable {
        
    }
    
    function _startLucky7NumbersGeneration() public onlyOwner{
        indexForLucky7Array = 0;
        _generateLucky7Number();
    }
    
    function _generateLucky7Number() public onlyOwner{
        if(indexForLucky7Array == numberOfLucky7Numbers){
            _orderLucky7Numbers();
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
            smallest = lucky7Numbers[i];
            for (j=i+1; j<numberOfLucky7Numbers; j++){
                if(smallest.ticketValue>lucky7Numbers[j].ticketValue){
                    smallest = lucky7Numbers[j];
                    aux = j;
                }
            }
            if(aux!=i){
                lucky7Numbers[aux]=lucky7Numbers[i];
                lucky7Numbers[i] = smallest;
            }
        }
    }
    
    function _orderLucky7Tickets() public onlyOwner{
        Lucky7Ticket memory smallest;
        uint aux = 0;
        uint j;
        for (uint i = 0; i < numberOfLucky7Numbers; i++) {
            lucky7Tickets[i].difference=lucky7TicketDifference[i];
            lucky7Tickets[i].owner=lucky7TicketOwner[i];
            lucky7Tickets[i].ticketID=lucky7TicketID[i];
        }
        for(i=0; i<numberOfLucky7Numbers; i++){
            aux = i;
            smallest = lucky7Tickets[i];
            for (j=i+1; j<numberOfLucky7Numbers; j++){
                if(smallest.difference>lucky7Tickets[j].difference){
                    smallest = lucky7Tickets[j];
                    aux = j;
                }
            }
            if(aux!=i){
                lucky7Tickets[aux]=lucky7Tickets[i];
                lucky7Tickets[i] = smallest;
            }
        }
    }
    
    function _deliverPrizes() public onlyOwner{
        uint winnersPrize = this.balance.mul(7);
        winnersPrize = winnersPrize.div(10);
        uint firstPrize = winnersPrize.mul(6);
        uint secondPrize = winnersPrize.mul(3);
        uint thirdPrize = winnersPrize.mul(1);
        firstPrize = firstPrize.div(10);
        secondPrize = secondPrize.div(10);
        thirdPrize = thirdPrize.div(10);
        _orderLucky7Tickets();
        lucky7Tickets[0].owner.transfer(firstPrize);
        lucky7Tickets[1].owner.transfer(secondPrize);
        lucky7Tickets[2].owner.transfer(thirdPrize);
        enterpriseWallet.transfer(this.balance);
        
    }
    
    function _balance() public view returns (uint256){
        return this.balance;
    }
    
    function () public payable {
        
    }
}