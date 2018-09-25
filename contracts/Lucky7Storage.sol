/**
  * @author Matias Barrios
  * @version 1.0
  */


/** @title Lucky7Storage. 
  * This contract is meant to storage all the important information of the game, i.e. Tickets, Lucky7Numbers and Lucky7Tickets related info.
  */

pragma solidity ^0.4.20;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/access/Whitelist.sol";
import "./Lucky7Library.sol";

contract Lucky7Storage is Whitelist{
    using SafeMath for uint256;
    /**@dev The events are used mainly for testing purposes
      */
    event NewLucky7Ticket(uint ticketID);
    event NewLucky7Number(uint value);

    /** @pdev Ticket is a struct to store information of the tickets. It information is stored permanently through the tickets array.
      * @param mu is a parameter of the pseudo-random number generator (PRNG).
      * @param i is a parameter of the pseudo-random number generator (PRNG).
      * @param ticketValue is the value of ticket.
      * @param owner is the owner of the ticket.
      * @param drawID is the number of the draw for this ticket, i.e. the game where this ticket was emitted.
      */
    struct Ticket{
        string mu;
        string i;
        uint ticketValue;
        address owner;
        uint drawID;
    }
    
    /** @dev Lucky7Number is a struct to store the information of the Lucky7Numbers. Is used for the lucky7Numbers array
      * and it information is erased when a new game is setted, i.e. it information is replaced with the Lucky7Numbers information
      * of the new game.
      * @param mu is a parameter of the pseudo-random number generator (PRNG).
      * @param i is a parameter of the pseudo-random number generator (PRNG).
      * @param ticketValue is the value of the Lucky7Number.
      * @param drawID is the number of the draw for this Lucky7Number, i.e. the game where this Lucky7Number was emitted. 
      */
    struct Lucky7Number{
        string mu;
        string i;
        uint ticketValue;
        uint drawID;
    }
    
    /** @dev Lucky7Ticket is a struct to store the information of the Lucky7Tickets. Is used once a new game is setted, and it store the information of the final
      * Lucky7Tickets permanently.
      * @param difference is the difference (in absolute value) of the ticket with the Lucky7Number.
      * @param owner is the owner of the Lucky7Ticket.
      * @param ticketID is the ticket ID of the ticket which was selected as Lucky7Ticket. Is helpful to look up in the ticketID mapping to verify
      * past games and results.
      * @param ticketValue is the value of the ticket associated to this Lucky7Ticket.
      * @param lucky7Number is the value of the Lucky7Number associated to this Lucky7Ticket.
      * @param lucky7NumberID is the ID of the Lucky7Number associated to this Lucky7Ticket, i.e. if 0 is the first Lucky7Number of the draw.
      * @param drawID is the number of the draw for this Lucky7Ticket, i.e. the game where this Lucky7Ticket was emitted.
      */
    struct Lucky7Ticket{
        uint difference;
        address owner;
        uint ticketID;
        uint ticketValue;
        uint lucky7Number;
        uint lucky7NumberID;
        uint drawID;
    }
    
    /** @dev The next two arrays are used to store information of the game permanently.
      * @param lucky7TicketsArray stores the Lucky7Tickets once a new game is setted.
      * @param ticketsArray stores the tickets everytime a user buys a ticket.
      */
    Lucky7Ticket[] public lucky7TicketsArray;
    Ticket[] public ticketsArray;
    
    /** @param lucky7NumbersArray stores the Lucky7Numbers for the current draw. Once a new game is called, it is cleand to 0 to be reused. 
      */
    Lucky7Number[7] public lucky7NumbersArray;

    /** @dev The next three mapping are used to state the Lucky7Ticket values while a game is on course. This is because is expensive to look up on the Lucky7Ticket
      * struct everytime a new ticket is inserted in the tickets array.
      * They all maps from the lucky7NumberID, i.e. the id of the Lucky7Number of the current game. 
      * @param lucky7TicketDifference points to an uint which is the difference between the Lucky7Number of it _KeyType and the ticket selected as Lucky7Ticket, 
      * e.g. lucky7TicketDifference[0] is the difference between the first Lucky7Number with the ticket which was selected as his Lucky7Ticket.
      * @param lucky7TicketOwner points to the address of the owner of the Lucky7Ticket associated to the Lucky7Number of it _KeyType, 
      * e.g. lucky7TicketOwner[0] is the owner of the Lucky7Ticket associated to the first Lucky7Number.
      * @param lucky7TicketID points to the id of the ticket which was selected as Lucky7Ticket for the Lucky7Number of it _KeyType, 
      * e.g. lucky7TicketID[0] is the ticketID of the ticket owned by lucky7TicketOwner[0], with a difference of lucky7TicketDiffference[0] with the Lucky7Number[0].
      */
    mapping (uint => uint) public lucky7TicketDifference;
    mapping (uint => address) public lucky7TicketOwner;
    mapping (uint => uint) public lucky7TicketID;

    /** @dev The next three mappings are used to storage ExactLucky7Ticket, i.e. tickets which difference with a Lucky7Number is 0 
      * They follow the same logic as the previous three mapings. They're setted for future development, because this project is meant to emit tokens and ExactLucky7Tickets
      * are going to be specially awarded.
      * They're cleaned to 0 everytime a new game is setted.
      */
    mapping (uint => uint) public ExactLucky7TicketValue;
    mapping (uint => address) public ExactLucky7TicketOwner;
    mapping (uint => uint) public ExactLucky7TicketID;

    /** @param drawNumber is the number of the current draw. Is used to help storage Lucky7Tickets, look up for current game winners and others functions.
      * Is incremented by 1 everytime a new game is setted.
      * @param indexForLucky7Array is a uint used to count the number of Lucky7Numbers generated everytime a new game is setted. Is used to know if all the Lucky7Numbers 
      * were setted, and if they did, order them by them values in ascendant order and let users start buying tickets. Is setted to 0 after all this process.
      * @param indexForExactLucky7Ticket is a uint which increments everytime a ExactLucky7Ticket is detected and stored. It's used to look up in in the ExactLucky7 mappings
      * and is cleaned to 0 everytime a new game is setted.
      */
    uint public drawNumber = 0;
    uint public indexForLucky7Array = 0;
    uint public indexForExactLucky7Ticket = 0;

    /** @param numberOfLucky7Numbers is the parameter that indicates the number of Lucky7Numbers which are going to be generated
      * before letting users start buying a ticket. Is used for other functions to shutdown a circuit breaker, lookup in arrays and
      * order the Lucky7Numbers
      */
    uint public numberOfLucky7Numbers = 7;

    /** @param initialLucky7TicketPosition is a uint used for the _orderLucky7Tickets function of this contract. 
      * Because is necessary to store the information of previous games permanently is necessary then to know what it the starting point to store in the 
      * lucky7TicketsArray array of the Lucky77TicketFactory.sol contract. 
      * This way, the _orderLucky7Tickets function starts storing in the "initialLucky7TicketPosition" and finish storing in the 
      * "numberOfLucky7Numbers+initialLucky7TicketPosition" position of the lucky7TicketsArray array. 
      * Defaults to 0, and is getting incremented by "numberOfLucky7Numbers" value every time the setNewGame function of this contract is called.
      * @param currentTicketID is a uint which points to the position in the ticketsArray array of the Lucky7TicketFactory contract where was pushed the last ticket
      * inserted by the insertCustomizedTicket function of this contract. That function and this parameter are used for testing purposes only.
      * @param lastFirstPrizeWinner is and address which stores the address of the last first prize winner. Is setted on the _deliverPrizes function of this contract 
      * and is used to set to 0 the amount of the prize for the last first prize winner before start delivering prizes for security reasons.
      * @param lastSecondPrizeWinner is and address which stores the address of the last second prize winner. Is setted on the _deliverPrizes function of this contract 
      * and is used to set to 0 the amount of the prize for the last second prize winner before start delivering prizes for security reasons.
      * @param lastThirdPrizeWinner is and address which stores the address of the last third prize winner. Is setted on the _deliverPrizes function of this contract 
      * and is used to set to 0 the amount of the prize for the last third prize winner before start delivering prizes for security reasons.
      * @param lastFirstPrizeAmount is and uint which stores the amount of the last first prize. Is setted on the _deliverPrizes function of this contract.
      * @param lastSecondPrizeAmount is and uint which stores the uint of the last second prize winner. Is setted on the _deliverPrizes function of this contract.
      * @param lastThirdPrizeAmount is and uint which stores the uint of the last third prize winner. Is setted on the _deliverPrizes function of this contract.
      * @param pendingWithdrawals is a mapping that points from an address to an uint. Is used for the _deliverPrizes function of this contract to store the 
      * the correspondent prize with the correspondent winner. The prizes are setted to 0 every time the _deliverPrizes function is called for security reasons.
      * To claim a prize, user have to call the withdraw function of this contract, so the prize is delivered and the amount for him prize is setted to 0 again.
      
      */
    uint public initialLucky7TicketPosition = 0;
    uint public currentTicketID = 0;
    address public lastFirstPrizeWinner = address(0);
    address public lastSecondPrizeWinner = address(0);
    address public lastThirdPrizeWinner = address(0);
    address public lastFourthPrizeWinner = address(0);
    address public lastFifthPrizeWinner = address(0);
    address public lastSixthPrizeWinner = address(0);
    address public lastSeventhPrizeWinner = address(0);
    uint public lastFirstPrizeAmount = 0;
    uint public lastSecondPrizeAmount = 0;
    uint public lastThirdPrizeAmount = 0;
    uint public lastFourthPrizeAmount = 0;
    uint public lastFifthPrizeAmount = 0;
    uint public lastSixthPrizeAmount = 0;
    uint public lastSeventhPrizeAmount = 0;
    mapping (address => uint) public pendingWithdrawals;

     /** @dev _checkForLucky7Ticket is a function that check if a ticket recently inserted in the ticketsArray is a Lucky7Ticket.
      * @param _ticketID is the ticket which is going to be checked.
      * At this point, the Lucky7Numbers are ordered by them values in ascedant order.
      * This function uses the SafeMath library to avoid integer underflow or overflow, or to check that the difference is not 0, which is a special case.
      */
    function _checkForLucky7Ticket(uint _ticketID) public{
        uint i;
        uint difference;
        /** @dev First it checks if the ticket is bigger than the last Lucky7Number.
          * If so, sets the auxiliary parameter i to the id of the last Lucky7Number, numberOfLucky7Numbers-1 in this case. Don't confuse with the i parameter of the PRNG.
          * Then the difference between them is obtained through the sub function of the SafeMath library, knowing that the ticket is bigger than the last Lucky7Number.
          */
        if(ticketsArray[_ticketID].ticketValue>lucky7NumbersArray[numberOfLucky7Numbers-1].ticketValue){
            i = numberOfLucky7Numbers-1;
            difference = ticketsArray[_ticketID].ticketValue.sub(lucky7NumbersArray[i].ticketValue);
            
        }
        /** @dev If it is not bigger than the last Lucky7Number, then checks if it is smaller thant the first Lucky7Number.
          * If so, sets the auxiliary parameter i to the id of the first Lucky7Number, 0 in this case. Don't confuse with the i parameter of the PRNG.
          * Then the difference between them is obtained through the sub function of the SafeMath library, knowing that the ticket is smaller than the first Lucky7Number.
          */
        else if (ticketsArray[_ticketID].ticketValue<lucky7NumbersArray[0].ticketValue){
            i = 0;
            difference = lucky7NumbersArray[i].ticketValue.sub(ticketsArray[_ticketID].ticketValue);
        }

        /** @dev If none of the above fits, then the ticket could be bigger or equal than the first Lucky7Number or smaller or equal than the last Lucky7Number.
          * The function proceeds then to look which is it interval,i.e. it should be between two Lucky7Numbers or equal to one Lucky7Number.
          */
        else{
            /** @dev The function then proceed to increment i until the ticket is bigger than the Lucky7Number[i].
              */
            while(ticketsArray[_ticketID].ticketValue>lucky7NumbersArray[i].ticketValue){ 
                i++;
            }
            /** @dev If the ticket and the correspondent Lucky7Numbers are equal, then the ticket is a ExactLucky7Ticket
              */
            if(ticketsArray[_ticketID].ticketValue==lucky7NumbersArray[i].ticketValue){
                difference = 0;
            }
            else{
                /** @dev If not, then it will have to check if the Lucky7Number above or below the ticket is closer
                  * if the below Lucky7Number is closer to the ticket than the above Lucky7Number (if(upperLucky7NumberDifference>lowerLucky7NumberDifference)) then the 
                  * correspondent candidate to Lucky7Ticket is the Lucky7Number which is below the ticket.
                  * Else, the above Lucky7Number is the correspondent candidate.
                  * Then saves the value of difference.
                  */
                uint lowerLucky7NumberDifference = ticketsArray[_ticketID].ticketValue.sub(lucky7NumbersArray[i-1].ticketValue);
                uint upperLucky7NumberDifference = lucky7NumbersArray[i].ticketValue.sub(ticketsArray[_ticketID].ticketValue);
                
                if(upperLucky7NumberDifference>lowerLucky7NumberDifference){
                    i=i-1;
                    difference = lowerLucky7NumberDifference;
                }
                else{
                    difference = upperLucky7NumberDifference;
                }
            }
        }
        /** @dev Now the function proceed to check if it is in fact a Lucky7Ticket.
          * If the Lucky7Ticket[i] hasn't an owner, then the ticket is automatically assigned as Lucky7Ticket.
          * If it has an owner, then check if the difference is smaller than the difference of the current owner.
          * If it is smaller, then the ticket is a Lucky7Ticket and is stored in the Lucky7Ticket mappings.
          * Then an event is emitted.
          */
        if(lucky7TicketOwner[i] == address(0x0) || difference<lucky7TicketDifference[i]){
            lucky7TicketOwner[i] = ticketsArray[_ticketID].owner;
            lucky7TicketDifference[i] = difference;
            lucky7TicketID[i] = _ticketID;
            emit NewLucky7Ticket(_ticketID);
        }
        /** @dev Then, checks if it's a ExactLucky7Ticket.
          * Due to the high entropy of the PRNG is pretty unfeasible to get an ExactLucky7Ticket without having the same mu and i parameters than the
          * Lucky7Number. The probability of having two identical ExactLucky7Tickets in the same game is even lower.
          * If in determinated unfortunate case an user gets a ExacyLucky7Ticket which is already occupied, then it will not replace the old one.
          * That's why is necessary to storage all the ExactLucky7Tickets to award them specially, e.g. giving them tokens according to some rules, which would be
          * specified in future developments.
          * The next step, then, is to check if it is indeed a ExactLucky7Ticket. If so, then store the information in the ExactLucky7Tickets mappings and increment
          * indexForExactLucky7Ticket by 1.
          */
        if(difference == 0){
            ExactLucky7TicketOwner[indexForExactLucky7Ticket] = ticketsArray[_ticketID].owner;
            ExactLucky7TicketValue[indexForExactLucky7Ticket] = ticketsArray[_ticketID].ticketValue;
            ExactLucky7TicketID[indexForExactLucky7Ticket] = _ticketID;
            indexForExactLucky7Ticket++;
        }
    }
    
    
    /** @dev _orderLucky7Numbers is a function designed to order the Lucky7Numbers. It is called from the _generateLucky7Number function of this contract (above function).
      * First, it generates 4 auxiliary parameters; a Lucky7Number struct called smallest, and aux, j and i which are uint initiated to 0.
      * Then it loops over the Lucky7Numbers array, comparing the i Lucky7Number value with the i+1, i+2, i+3 until reachs the numberOfLucky7Numbers-1 value. 
      * If none of them is smaller than it, then jumps to the next Lucky7Number. It then starts comparing it (the i+1 for this case) with the subsequents number. If one of 
      * them is smaller, changes positions and starts comparing the new one with the subsequents. 
      */
    function _orderLucky7Numbers() public onlyOwner{
        Lucky7Number memory smallest;
        uint aux;
        uint j;
        uint i;
        for(i=0; i<numberOfLucky7Numbers; i++){
            /** @dev At this point, aux is going to be ever equal to i and smallest is the Lucky7Number which is going to be compared with the next.
              */
            aux = i;
            smallest = lucky7NumbersArray[i];
            for (j=i+1; j<numberOfLucky7Numbers; j++){
                /** @dev At this point, the function starts comparing "smallest" with the next to it, j+1 in this case.
                  * If "smallest" is not smaller than the next ticketValue (or Lucky7Number[j] value), then it saves the value of the new "smallest" value, 
                  * and saves aux as the j value.
                  */
                if(smallest.ticketValue>lucky7NumbersArray[j].ticketValue){
                    smallest = lucky7NumbersArray[j];
                    aux = j;
                }
            }

            /** @dev Once the previous loop is finished, i.e. the comparison of "smallest" with all the other above it, it checks if aux changed.
              * If it changed, it means that there was one Lucky7Number which value was lower than "smallest", and change the position of "smallest" with the Lucky7Number[j]
              * which is actually smalller than "smallest". This way, in next hopes former "smallest" Lucky7Number is going to be compared again until it fits the state of
              * "smallest than every Lucky7Number above itself"
              */
            if(aux!=i){
                lucky7NumbersArray[aux]=lucky7NumbersArray[i];
                lucky7NumbersArray[i] = smallest;
            }
        }
    }
    /** @dev _orderLucky7Tickets is a function designed to store and order the Lucky7Tickets according to its difference in asceding order.
      * First, it stores all the current Lucky7Ticket values, i.e. lucky7TicketDifference, lucky7TicketOwner and lucky7TicketID mappings from the Lucky7TicketFactory contract,
      * the ticketValue associated to it, the Lucky7Number and Lucky7NumberID (first, second, third) associated to it, and the drawID. This is thought to be capable of verify
      * in the future possible problems delivering prizes.
      * Then, it order the Lucky7Tickets depending on them difference value of the Lucky7Ticket struct of the Lucky7TicketFactory contract. The order logic is the same defined
      * in the _orderLucky7Numbers function of this contract (the above function).
      */
    function _orderLucky7Tickets() public onlyOwner{
        Lucky7Ticket memory smallest;
        uint aux;
        uint i;
        uint j;
        uint k;
        for (i=0; i<numberOfLucky7Numbers; i++){
            lucky7TicketsArray.push(
                /** @dev The Lucky7Ticket struct is as follows:   
                  *     struct Lucky7Ticket{
                  *         uint difference;
                  *         address owner;
                  *         uint ticketID;
                  *         uint ticketValue;
                  *         uint lucky7Number;
                  *         uint lucky7NumberID;
                  *         uint drawID;
                  *     }  
                  */
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

    /** @dev _cleanMappings is a function used by the setNewGame function of this contract to clean the necessary mappings, 
      * i.e. lucky7TicketDifference, lucky7TicketOwner, lucky7TicketID, lucky7NumbersArray, ExactLucky7TicketValue, ExactLucky7TicketOwner and
      * ExactLucky7TicketID. This, because for new games the old winners needs to been cleaned up.
      */
    //Should clean 
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

    /** @dev Storage functions.
      *  Functions created to be called through other contracts to storage data in this contract.
      */

    function storageTicket(string _mu, string _i, uint _ticketValue, address _owner)
        public    
        onlyOwner
        returns(uint)
    {
        uint id = ticketsArray.push(Ticket(_mu, _i,_ticketValue,_owner,drawNumber)) - 1;
        return id;
    }

    function storageLucky7Number(string _mu, string _i, uint _ticketValue)
        public 
        //onlyOwner
    {
        lucky7NumbersArray[indexForLucky7Array] = Lucky7Number(_mu, _i, _ticketValue, drawNumber);
        indexForLucky7Array++;
        emit NewLucky7Number(_ticketValue);
    }

    function increaseCounters() public onlyOwner{
        drawNumber++;
        initialLucky7TicketPosition+=drawNumber*numberOfLucky7Numbers;
    }

    function setWinners(uint _firstPrize, uint _secondPrize, uint _thirdPrize, uint _fourthPrize, uint _fifthPrize, uint _sixthPrize, uint _seventhPrize)   
        public 
        onlyOwner 
        returns(address,address,address,address,address,address,address)
    {
        uint i;
        address[7] memory winners;
        for(i=initialLucky7TicketPosition; i<numberOfLucky7Numbers+initialLucky7TicketPosition; i++){
            if(lucky7TicketsArray[i].owner!=address(0x0)){
                winners[0]=lucky7TicketsArray[i].owner;
                lastFirstPrizeAmount = _firstPrize;
                lastFirstPrizeWinner = lucky7TicketsArray[i].owner;
                break;
            }
        }
        
        for(i++; i<numberOfLucky7Numbers+initialLucky7TicketPosition; i++){
            if(lucky7TicketsArray[i].owner!=address(0x0)){
                winners[1]=lucky7TicketsArray[i].owner;
                lastSecondPrizeAmount = _secondPrize;
                lastSecondPrizeWinner = lucky7TicketsArray[i].owner;
                break;
            }
        }
        
        for(i++; i<numberOfLucky7Numbers+initialLucky7TicketPosition; i++){
            if(lucky7TicketsArray[i].owner!=address(0x0)){
                winners[2]=lucky7TicketsArray[i].owner;
                lastThirdPrizeAmount = _thirdPrize;
                lastThirdPrizeWinner = lucky7TicketsArray[i].owner;
                break;
            }
        }

        for(i++; i<numberOfLucky7Numbers+initialLucky7TicketPosition; i++){
            if(lucky7TicketsArray[i].owner!=address(0x0)){
                winners[3]=lucky7TicketsArray[i].owner;
                lastFourthPrizeAmount = _fourthPrize;
                lastFourthPrizeWinner = lucky7TicketsArray[i].owner;
                break;
            }
        }

        for(i++; i<numberOfLucky7Numbers+initialLucky7TicketPosition; i++){
            if(lucky7TicketsArray[i].owner!=address(0x0)){
                winners[4]=lucky7TicketsArray[i].owner;
                lastFifthPrizeAmount = _fifthPrize;
                lastFifthPrizeWinner = lucky7TicketsArray[i].owner;
                break;
            }
        }

        for(i++; i<numberOfLucky7Numbers+initialLucky7TicketPosition; i++){
            if(lucky7TicketsArray[i].owner!=address(0x0)){
                winners[5]=lucky7TicketsArray[i].owner;
                lastSixthPrizeAmount = _sixthPrize;
                lastSixthPrizeWinner = lucky7TicketsArray[i].owner;
                break;
            }
        }

        for(i++; i<numberOfLucky7Numbers+initialLucky7TicketPosition; i++){
            if(lucky7TicketsArray[i].owner!=address(0x0)){
                winners[6]=lucky7TicketsArray[i].owner;
                lastSeventhPrizeAmount = _seventhPrize;
                lastSeventhPrizeWinner = lucky7TicketsArray[i].owner;
                break;
            }
        }
        return(winners[0],winners[1],winners[2],winners[3],winners[4],winners[5],winners[6]);
    }

    function setIndexForLucky7ArrayToZero() public onlyOwner{
        indexForLucky7Array = 0;
    }
}