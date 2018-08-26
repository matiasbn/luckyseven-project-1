pragma solidity ^0.4.20;

import "./Lucky7TicketFactory.sol";

contract Lucky7Ballot is Lucky7TicketFactory{
    
    
    uint public initialLucky7TicketPosition=0;
    uint public currentTicketID=0;
    address public lastFirstPrize = address(0);
    address public lastSecondPrize = address(0);
    address public lastThirdPrize = address(0);

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
        //Increase drawNumber
        //Set on Lucky7NumbersSetting
        toggleLucky7Setting();
        //Deliver Prizes
        //Deliver lot for enterprise
        _orderLucky7Tickets();
        _deliverPrizes();
        drawNumber++;
        //Set initial index for the Lucky7Tickets for the next game
        initialLucky7TicketPosition+=drawNumber*numberOfLucky7Numbers;
        _cleanMappings();
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
        uint j;
        uint i;
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
        for(i=initialLucky7TicketPosition; i<numberOfLucky7Numbers+initialLucky7TicketPosition; i++){
            aux = i;
            smallest = lucky7TicketsArray[i];
            for (j=i+1; j<numberOfLucky7Numbers+initialLucky7TicketPosition; j++){
                if(smallest.difference>lucky7TicketsArray[j].difference){
                    smallest = lucky7TicketsArray[j];
                    aux = j;
                }
            }
            if(aux!=i){
                lucky7TicketsArray[aux]=lucky7TicketsArray[i];
                lucky7TicketsArray[i] = smallest;
            }
        }
    }

    function _deliverPrizes() public onlyOwner{
        pendingWithdrawals[lastFirstPrize] = 0;
        pendingWithdrawals[lastSecondPrize] = 0;
        pendingWithdrawals[lastThirdPrize] = 0;
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
                lastFirstPrize = lucky7TicketsArray[i].owner;
                break;
            }
        }
        
        for(i++; i<numberOfLucky7Numbers+initialLucky7TicketPosition; i++){
            if(lucky7TicketsArray[i].owner!=address(0x0)){
                pendingWithdrawals[lucky7TicketsArray[i].owner] += secondPrize;
                lastSecondPrize = lucky7TicketsArray[i].owner;
                break;
            }
        }
        
        for(i++; i<numberOfLucky7Numbers+initialLucky7TicketPosition; i++){
            if(lucky7TicketsArray[i].owner!=address(0x0)){
                pendingWithdrawals[lucky7TicketsArray[i].owner] += thirdPrize;
                lastThirdPrize = lucky7TicketsArray[i].owner;
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
    
    function () public payable {
        
    }
}