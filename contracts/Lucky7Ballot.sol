pragma solidity ^0.4.20;

import "./Lucky7TicketFactory.sol";

contract Lucky7Ballot is Lucky7TicketFactory{
    
    
    uint public initialLucky7TicketPosition=0;
    mapping (address => uint) public pendingWithdrawals;


    function Lucky7Ballot() payable {
        
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
    
    function setNewGame()                                      
        public 
        onlyOwner 
    {
        //Set initial index for Lucky7Tickets
        initialLucky7TicketPosition=drawNumber*numberOfLucky7Numbers;
        //Increase drawNumber
        //Set on Lucky7NumbersSetting
        toggleLucky7Setting();
        //Deliver Prizes
        //Deliver lot for enterprise
        _orderLucky7Tickets();
        _deliverPrizes();
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
        uint aux;
        uint j;
        uint i;
        for (i=0; i<numberOfLucky7Numbers; i++){
            lucky7Tickets.push(
                Lucky7Ticket(
                    lucky7TicketDifference[i],
                    lucky7TicketOwner[i],
                    lucky7TicketID[i],
                    tickets[lucky7TicketID[i]].ticketValue,
                    lucky7Numbers[i].ticketValue,
                    i,
                    drawNumber)
                    );
        }
        for(i=initialLucky7TicketPosition; i<numberOfLucky7Numbers+initialLucky7TicketPosition; i++){
            aux = i;
            smallest = lucky7Tickets[i];
            for (j=i+1; j<numberOfLucky7Numbers+initialLucky7TicketPosition; j++){
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
            if(lucky7Tickets[i].owner!=address(0x0)){
                pendingWithdrawals[lucky7Tickets[i].owner] += firstPrize;
                break;
            }
        }
        
        for(i++; i<numberOfLucky7Numbers+initialLucky7TicketPosition; i++){
            if(lucky7Tickets[i].owner!=address(0x0)){
                pendingWithdrawals[lucky7Tickets[i].owner] += secondPrize;
                break;
            }
        }
        
        for(i++; i<numberOfLucky7Numbers+initialLucky7TicketPosition; i++){
            if(lucky7Tickets[i].owner!=address(0x0)){
                pendingWithdrawals[lucky7Tickets[i].owner] += thirdPrize;
                break;
            }
        }
        drawNumber++;
        enterpriseWallet.transfer(address(this).balance);
        for(i=0; i<numberOfLucky7Numbers; i++){
            lucky7TicketOwner[i] = address(0x0);
            lucky7TicketDifference[i] = 0;
            lucky7TicketID[i] = 0;
            lucky7Numbers[i].mu="0";
            lucky7Numbers[i].i="0";
            lucky7Numbers[i].ticketValue=0;
            lucky7Numbers[i].drawID=drawNumber;
        }
    }
    
    function withdraw() public {
        uint amount = pendingWithdrawals[msg.sender];
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    function getlucky7Numbers() public view returns (uint[7]) {
        uint[7] luckySevenNumbers;
        for(uint i=0; i<numberOfLucky7Numbers; i++){
            luckySevenNumbers[i]=lucky7Numbers[i].ticketValue;
        }
        return luckySevenNumbers;
    }

    function getlucky7Tickets() public view returns (uint[7]) {
        uint[7] luckySevenTickets;
        for(uint i=0; i<numberOfLucky7Numbers; i++){
            if(lucky7TicketOwner[i]!=address(0x0)){
                luckySevenTickets[i] = tickets[lucky7TicketID[i]].ticketValue;
            }
            else{
                luckySevenTickets[i]=0;
            }
        }
        return luckySevenTickets;
    }

    function () public payable {
        
    }
}