/**
  * @author Matias Barrios
  * @version 1.0
  */

/** @title Lucky7TicketFactor. 
  * This contract contains all the functions to generate tickets and Lucky7Numbers.
  * Inherits from Lucky7Admin and usingOraclize to do the oraclize querys. 
*/


pragma solidity ^0.4.20;
import "./usingOraclize.sol";
import "./Lucky7Admin.sol";


contract Lucky7TicketFactory is Lucky7Admin, usingOraclize{
    
    /** @dev The constructor needs to set the @param OAR parameter to use oraclize on localhost.
      */
    function Lucky7TicketFactory() payable{
        OAR = OraclizeAddrResolverI(0x6f485c8bf6fc43ea212e93bbf8ce046c7f1cb475);
    }
    
    using SafeMath for uint256;
    
    /**@dev The events are used mainly for testing purposes
      */
    event NewOraclizeQuery(string description);
    event NewMuReceived(string muParameter);
    event NewIReceived(string iParameter);
    event NewTicketReceived(string newTicket);
    event NewWolframQuery(string description);
    event NewLucky7Ticket(uint ticketID);
    event NewLucky7Number(uint value);
    
    /** @dev This modifier is used to set the gas price on the functions which do oraclize querys.
      *  It uses the oraclizeCustomGasPrice of the Lucky7Admin contract.
      */
    modifier oraclizeGasPriceCustomized{
        oraclize_setCustomGasPrice(oraclizeCustomGasPrice);
        _;
    }

    /** @param settingLucky7Numbers is a circuit breaker to stop users of buying tickets while the game is getting setted
      *i.e. when a new game is started, previous winners are erased, the Lucky7Numbers are getting setted and prizes are delivered.
      */
    bool public settingLucky7Numbers = true;
    
    /** @dev Function to toggle the settingLucky7Numbers to stop users to buy tickets. 
      */
    function toggleLucky7Setting() public onlyOwner{
        settingLucky7Numbers = !settingLucky7Numbers;
    }

    /** @dev UserParametersValue is a struct where the values of the user ticket is stored temporarily.
      * While the user is just generating (not buying) tickets, the values of this struct for each user are going to change.
      * Once the user buys a ticket, all the parameters of this struct are used to generate a ticket and store it in the tickets array.
      * where they will be stored permanently.
      * @param mu is a parameter of the pseudo-random number generator (PRNG).
      * @param i is a parameter of the pseudo-random number generator (PRNG).
      * @param ticketValue is the value of the last buyed ticket of the user.
      * @param muReady is a boolean value used for the oraclize's callback function to verify if the mu parameter for the current ticket was already setted.
      * @param iReady is a boolean value used for the oraclize's callback function to verify if the i parameter for the current ticket was already setted.
      * @param userPaidTicket is a boolean value to verify if the user which is calling for the oraclize query actually paid for the ticket or is just generating
      * parameters to choose a ticket.
    */
    struct UserParametersValue{
        string mu;
        string i;
        uint ticketValue;
        bool muReady;
        bool iReady;
        bool userPaidTicket;
    }
    
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

    /** @dev Because addresses are not correlatives, is better to use a mapping. 
      * @param userValues maps from the user address to it UserParametersValue struct.
      */
    mapping (address => UserParametersValue) public userValues;

    /** @dev The next three mapping are used for the functions which do oraclize querys to being identified in the oraclize's callback function
      * as mu parameter, i parameter or a ticket.
      * @param muParameterID maps from a bytes32 generated everytime the oraclize_query function is called and points to the address of the user which did the call.
      * @param iParameterID maps from a bytes32 generated everytime the oraclize_query function is called and points to the address of the user which did the call.
      * @param newTicketID maps from a bytes32 generated everytime the oraclize_query function is called and points to the address of the user which did the call.
      */
    mapping (bytes32 => address) muParameterID;
    mapping (bytes32 => address) iParameterID;
    mapping (bytes32 => address) newTicketID;

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
    
    /** @dev _askForMuParameter is a function to ask for a new mu parameter through an oraclize query.
      * @param _ticketOwner is the address of the user which is calling this function through a generation of new parameters or by buying a new random ticket.
      * First, it emit an event to register the query. Then it do the query and save the bytes32 value generated to the muID.
      * Finally it associate this muID with the _ticketOwner through the muParameterID mapping, so the oraclize's callback function know it is a mu petition and it belongs to the _ticketOwner user.
      */
    function _askForMuParameter(address _ticketOwner) public oraclizeGasPriceCustomized{
        emit NewOraclizeQuery("Asking for a new mu parameter...");
        bytes32 muID = oraclize_query("WolframAlpha","4 random number",oraclizeGasLimit);
        muParameterID[muID] = _ticketOwner;
    }

    /** @dev _askForIParameter is a function to ask for a new I parameter through an oraclize query.
      * @param _ticketOwner is the address of the user which is calling this function through a generation of new parameters or by buying a new random ticket.
      * First, it emit an event to register the query. Then it do the query and save the bytes32 value generated to the iID.
      * Finally it associate this iID with the _ticketOwner through the iParameterID mapping, so the oraclize's callback function know it is a i petition and it belongs to the _ticketOwner user.
      */
    function _askForIParameter(address _ticketOwner) public oraclizeGasPriceCustomized{
        emit NewOraclizeQuery("Asking for a new i parameter...");
        bytes32 iID = oraclize_query("WolframAlpha","4 random number",oraclizeGasLimit);
        iParameterID[iID] = _ticketOwner;
    }
    
    /** @dev _askForTicket is a function to ask for a new ticket through an oraclize query.
      * @param _ticketOwner is the address of the user which is calling this function through by buying a new random ticket or buying the ticket generated by it parameters.
      * First, it emit an event to register the query. Then it do the query and save the bytes32 value generated to the userTicketID.
      * Finally it associate this userTicketID with the _ticketOwner through the newTicketID mapping, so the oraclize's callback function know it 
      * is a ticket petition and it belongs to the _ticketOwner user. Inside the oraclize_query function it calls the _setTicketQuery function, so it generate the query 
      * depending on the UserParametersValue struct of the _ticketOwner user.
      */
    function _askForTicket(address _ticketOwner) public oraclizeGasPriceCustomized{
        emit NewOraclizeQuery("Asking for a new ticket...");
        bytes32 userTicketID = oraclize_query("WolframAlpha", _setTicketQuery(_ticketOwner), oraclizeGasLimit);
        newTicketID[userTicketID] = _ticketOwner;
    }

    /** @dev _setTicketQuery is a function which sets the query to ask for a ticket to WolframAlpha through oraclize.
      * @param _parametersOwner is the address of the user which is going to receive the ticket, e.g. a user asking for a ticket or the admin of the contract when calling for a
      * Lucky7Number. The final shape of the query is (mod((1/(10^n-mu))*10^p,10^(j+i))-mod((1/(10^n-mu))*10^p,10^(i)))/10^i, and this function uses the strConcat function of
      * the usingOraclize contract to concat the parts with the parameters of the user.
      * Every line explains how the query is getting it shape. The meaning of this query is going to be explained on the paper of the project.
      */
    function _setTicketQuery(address _parametersOwner) internal returns (string){
        string memory queryWolfram;
        //This line => (mod((1/(10^n-mu))*10^    
        queryWolfram = strConcat("(mod((1/(10^",n,"-",userValues[_parametersOwner].mu,"))*10^");
        //This line => (mod((1/(10^n-mu))*10^p,10^(j+
        queryWolfram = strConcat(queryWolfram,p,",10^(",j,"+");
        //This line => (mod((1/(10^n-mu))*10^p,10^(j+i))-mod((1/(10^n-
        queryWolfram = strConcat(queryWolfram,userValues[_parametersOwner].i,"))-mod((1/(10^",n,"-");
        //This line => (mod((1/(10^n-mu))*10^p,10^(j+i))-mod((1/(10^n-mu))*10^p,10^
        queryWolfram = strConcat(queryWolfram,userValues[_parametersOwner].mu,"))*10^",p,",10^");
        //This line => (mod((1/(10^n-mu))*10^p,10^(j+i))-mod((1/(10^n-mu))*10^p,10^(i)))/10^i
        queryWolfram = strConcat(queryWolfram,"(",userValues[_parametersOwner].i,")))/10^",userValues[_parametersOwner].i);
        return queryWolfram;
    }

    /** @dev _generateTicket is used for another contract. Invokes _askForMuParameter and _askForIparameter
      */
    function _generateTicket(address _ticketOwner) public {
        _askForMuParameter(_ticketOwner);
        _askForIParameter(_ticketOwner);
    }
    
    /** @dev _insertTicket inserts a ticket in the ticketsArray array.
      * @param _ticketOwner is the owner of the ticket already generated. It uses the UserParametersValue struct values and the drawNumber value.
      * Then it call the _checkForLucky7Ticket function to check if the inserted ticket is a Lucky7Ticket.
      * Because a push return the size of the array, is necessary to decrement the id value in 1 to check the current ticket. 
      */
    function _insertTicket(address _ticketOwner) internal {
        uint id = ticketsArray.push(Ticket(userValues[_ticketOwner].mu,userValues[_ticketOwner].i,userValues[_ticketOwner].ticketValue,_ticketOwner,drawNumber)) - 1;
        _checkForLucky7Ticket(id);
    }

    /** @dev _insertLucky7Number inserts a Lucky7Number in the lucky7NumbersArray array.
      * @param _ticketOwner is the owner, but in this case is the owner of the contract. This is setted this way to take advantage of the UserParametersValue struct
      * and store it the same way the tickets are stored. Once stored, the indexForLucky7Array is incremented by 1, so next time this function is called, the next
      * Lucky7Number don't replace the last inserted. 
      * Then an event is emited.
      */
    function _insertLucky7Number(address _ticketOwner) internal {
        lucky7NumbersArray[indexForLucky7Array] = Lucky7Number(userValues[_ticketOwner].mu,userValues[_ticketOwner].i,userValues[_ticketOwner].ticketValue,drawNumber);
        indexForLucky7Array++;
        emit NewLucky7Number(userValues[_ticketOwner].ticketValue);
    }
    
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
    
    /** @dev __callback is a function used for oraclize to send back the query emitted to oraclize.
      * @param myid is the id of the query, same as the muID, iID or userTicketID of the _askForMuParameter, _askForIParameter and _askForTicket functions above.
      * @param result is the result of the query.
      * Once the query is resolved, oraclize sends back the answer, and the function check that the one calling the function is indeed a oraclize contract. 
      */
    function __callback(bytes32 myid, string result) public{
        require(msg.sender == oraclize_cbAddress());
        /** @dev First, the function checks if there's an muParameterID value associated to myid,i.e. the response is a mu parameter of the  
          * "muParameterID[myid]" user (remember that muParameterID[] maps from an bytes32, the id, to an user address).
          * Then it will check if the muReady boolean of the user's UserParametersValue struct is setted to false (explained in later contracts).
          * If so, stores the result as the mu parameter of the user's UserParametersValue struct, emits an event and set the muReady of the struct to true.
          * Then checks if the iReady boolen is setted to true. If so, it means that the user already recieved both parameters and is ready to generate a new ticket.
          * To do so, the function checks if the user already paid for the ticket through checking if the userPaidTicket boolean of the user's UserParametersValue struct
          * is true, or if the settingLucky7Numbers circuit breaker is on, which means that currently the game is in the setting Lucky7Numbers phase.
          * In any of those cases, the function calls the _askForTicketFunction for the "muParameterID[myid]" user.
          */
        if(muParameterID[myid]!=0 && userValues[muParameterID[myid]].muReady==false){
            userValues[muParameterID[myid]].mu=result;
            emit NewMuReceived(result);
            userValues[muParameterID[myid]].muReady=true;
            if(userValues[muParameterID[myid]].iReady == true && (userValues[muParameterID[myid]].userPaidTicket==true || settingLucky7Numbers==true )){
                _askForTicket(muParameterID[myid]);
            }
        }

        /** @dev If above don't fit, then checks if the result is the i parameter of the user and proceeds the same way, checking if already have the mu parameter setted,
          * and if the user paid for the ticket or the game is in the setting Lucky7Number phase.
          */
        else if (iParameterID[myid]!=0 && userValues[iParameterID[myid]].iReady==false){
            userValues[iParameterID[myid]].i=result;
            emit NewIReceived(result);
            userValues[iParameterID[myid]].iReady=true;
            if(userValues[iParameterID[myid]].muReady == true && (userValues[iParameterID[myid]].userPaidTicket==true || settingLucky7Numbers==true )){
                _askForTicket(iParameterID[myid]);
            }
        }

        /** @dev If not, then proceed the same way as above, but once the ticket is inserted and the event is emitted, the userPaidTicket of the user's UserValuesStruct is 
          * setted to 0, marking that the ticket thet user paid is already stored and it have to pay again if it wants to buy another ticket.
          * Finally, it checks if the game is currently in the setting Lucky7Numbers phase. If so, calls the _insertLucky7Number function, else it calls the 
          * _insertTicket function, both explained above.
          */
        else if (newTicketID[myid]!=0 &&  (userValues[newTicketID[myid]].userPaidTicket==true || settingLucky7Numbers==true )){
            userValues[newTicketID[myid]].ticketValue=parseInt(result);
            emit NewTicketReceived(result);
            userValues[newTicketID[myid]].userPaidTicket=false;
            if(settingLucky7Numbers==true){
                _insertLucky7Number(newTicketID[myid]);
            }
            else{
                _insertTicket(newTicketID[myid]);
            }
        }
    }

    function() public payable{}
} 