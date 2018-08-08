pragma solidity ^0.4.20;

import "./Lucky7TicketFactory.sol";

contract Lucky7Ballot is Lucky7TicketFactory{
    
    //0xca35b7d915458ef540ade6068dfe2f44e8fa733c
    //0x14723a09acff6d2a60dcdf7aa4aff308fddc160c
    //0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db
    //0x583031d1113ad414f02576bd6afabfb302140225
    //0xdd870fa1b7c4700f2bd7f44238821c26f7392148
    //0x265a5c3dd46ec82e2744f1d0e9fb4ed75d56132a
    
    function test ()public payable{
        lucky7Numbers[0] = Lucky7Number("1","2",106,0);
        lucky7Numbers[1] = Lucky7Number("1","2",433,0);
        lucky7Numbers[2] = Lucky7Number("1","2",455,0);
        lucky7Numbers[3] = Lucky7Number("1","2",331,0);
        lucky7Numbers[4] = Lucky7Number("1","2",304,0);
        lucky7Numbers[5] = Lucky7Number("1","2",242,0);
        lucky7Numbers[6] = Lucky7Number("1","2",751,0);
        _orderLucky7Numbers();
        
        address _ticketOwner = address(0x14723a09acff6d2a60dcdf7aa4aff308fddc160c);
        uint id = tickets.push(Ticket("1","2",107,_ticketOwner,0)) - 1;
        ticketToOwner[id] = _ticketOwner;
        ownerTicketCount[_ticketOwner]++;
        
        _ticketOwner = address(0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db);
        id = tickets.push(Ticket("1","2",431,_ticketOwner,0)) - 1;
        ticketToOwner[id] = _ticketOwner;
        ownerTicketCount[_ticketOwner]++;
        
        _ticketOwner = address(0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db);
        id = tickets.push(Ticket("1","2",458,_ticketOwner,0)) - 1;
        ticketToOwner[id] = _ticketOwner;
        ownerTicketCount[_ticketOwner]++;
        
        _ticketOwner = address(0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db);
        id = tickets.push(Ticket("1","2",327,_ticketOwner,0)) - 1;
        ticketToOwner[id] = _ticketOwner;
        ownerTicketCount[_ticketOwner]++;
        
        _ticketOwner = address(0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db);
        id = tickets.push(Ticket("1","2",309,_ticketOwner,0)) - 1;
        ticketToOwner[id] = _ticketOwner;
        ownerTicketCount[_ticketOwner]++;
        
        _ticketOwner = address(0xca35b7d915458ef540ade6068dfe2f44e8fa733c);
        id = tickets.push(Ticket("1","2",248,_ticketOwner,0)) - 1;
        ticketToOwner[id] = _ticketOwner;
        ownerTicketCount[_ticketOwner]++;
        
        _ticketOwner = address(0x583031d1113ad414f02576bd6afabfb302140225);
        id = tickets.push(Ticket("1","2",760,_ticketOwner,0)) - 1;
        ticketToOwner[id] = _ticketOwner;
        ownerTicketCount[_ticketOwner]++;
        
        _ticketOwner = address(0x265a5c3dd46ec82e2744f1d0e9fb4ed75d56132a);
        id = tickets.push(Ticket("1","2",305,_ticketOwner,0)) - 1;
        ticketToOwner[id] = _ticketOwner;
        ownerTicketCount[_ticketOwner]++;
        
        for (uint k=0 ; k<id; k++){
            _checkForLucky7Ticket(k);
        }    
    }
    
    function _startLucky7NumbersGeneration() public payable onlyOwner{
        indexForLucky7Array = 0;
        _generateLucky7Number();
    }
    
    function _generateLucky7Number() public payable onlyOwner{
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
        uint aux = 0;
        uint j;
        for(uint i=0; i<numberOfLucky7Numbers; i++){
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
}