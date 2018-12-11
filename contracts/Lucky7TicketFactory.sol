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
import "./Lucky7Storage.sol";
import "./Lucky7Library.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


contract Lucky7TicketFactory is usingOraclize,Ownable{
    /** @dev SafeMath library is used for the _checkForLucky7Ticket of this contract. 
        @dev Lucky7Library is a library used to get values from other contracts.
      */
    using Lucky7Library for *;
    using SafeMath for uint256;
    
    /** @dev Address of the Lucky7Storage contract
      */
    address public lucky7AdminAddress;
    address public lucky7StorageAddress;
    /** @dev The constructor needs to set the OAR, Oraclize Address Resolver
      * OAR is the Oraclize Address Resolver to use oraclize on localhost
      */
    function Lucky7TicketFactory(address _lucky7AdminAddress,address _lucky7StorageAddress) public payable{
        OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
        lucky7AdminAddress = _lucky7AdminAddress;
        lucky7StorageAddress = _lucky7StorageAddress;
    }

    /** @dev This function is to change the OAR without compiling again and deploying again
      * Used only for testing purposes.
      */
    function changeOAR(address _newOAR)
        public
        //onlyOwner
    {
        OAR = OraclizeAddrResolverI(_newOAR);
    }

    /**@dev The events are used mainly for testing purposes
      */
    event NewOraclizeQuery(string description);
    event NewMuReceived(string muParameter);
    event NewIReceived(string iParameter);
    event NewTicketReceived(string newTicket);
    event NewWolframQuery(string description);
    event NewValue(uint value);
    
    /** @dev This modifier is used to set the gas price on the functions which do oraclize querys.
      *  It uses the oraclizeCustomGasPrice of the Lucky7Admin contract.
      */
    modifier oraclizeGasPriceCustomized{
        uint oraclizeCustomGasPrice = Lucky7Library.oraclizeCustomGasPrice(lucky7AdminAddress);
        oraclize_setCustomGasPrice(oraclizeCustomGasPrice);
        _;
    }

    /** @dev This modifier is meant to block the Lucky7Number generation when the game is on course
      * Is used to block the action of the _generateLucky7Number function of this contract if the circuit breaker
      * is not 
      */
    modifier gameNotInCourse(){
        require(settingLucky7Numbers==true);
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
      * @param userState is an enum to let other contracts verify that the info for the user is not empty.
    */
    struct UserParametersValue{
        string mu;
        string i;
        uint ticketValue;
        bool muReady;
        bool iReady;
        bool userPaidTicket;
    }
    
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

    
    /** @dev _askForMuParameter is a function to ask for a new mu parameter through an oraclize query.
      * @param _ticketOwner is the address of the user which is calling this function through a generation of new parameters or by buying a new random ticket.
      * First, it emit an event to register the query. Then it do the query and save the bytes32 value generated to the muID.
      * Finally it associate this muID with the _ticketOwner through the muParameterID mapping, so the oraclize's callback function know it is a mu petition and it belongs to the _ticketOwner user.
      */
    function _askForMuParameter(address _ticketOwner) 
        public 
        oraclizeGasPriceCustomized
    {
        uint oraclizeGasLimit = Lucky7Library.oraclizeGasLimit(lucky7AdminAddress);
        emit NewValue(oraclizeGasLimit);
        emit NewOraclizeQuery("Asking for a new mu parameter...");
        bytes32 muID = oraclize_query("WolframAlpha","4 random number",oraclizeGasLimit);
        muParameterID[muID] = _ticketOwner;
    }

    /** @dev _askForIParameter is a function to ask for a new I parameter through an oraclize query.
      * @param _ticketOwner is the address of the user which is calling this function through a generation of new parameters or by buying a new random ticket.
      * First, it emit an event to register the query. Then it do the query and save the bytes32 value generated to the iID.
      * Finally it associate this iID with the _ticketOwner through the iParameterID mapping, so the oraclize's callback function know it is a i petition and it belongs to the _ticketOwner user.
      */
    function _askForIParameter(address _ticketOwner) 
        public 
        oraclizeGasPriceCustomized
    {
        uint oraclizeGasLimit = Lucky7Library.oraclizeGasLimit(lucky7AdminAddress);
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
    function _askForTicket(address _ticketOwner) 
        public 
        oraclizeGasPriceCustomized
    {
        uint oraclizeGasLimit = Lucky7Library.oraclizeGasLimit(lucky7AdminAddress);
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
    function _setTicketQuery(address _parametersOwner) 
        internal 
        returns (string)
    {
        string memory b;
        string memory n;
        string memory p;
        string memory j;
        (b,n,p,j) = Lucky7Library.getParameters(lucky7AdminAddress);
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
        emit NewWolframQuery(queryWolfram);
        return queryWolfram;
    }

    /** @dev _generateTicket is used for another contract. Invokes _askForMuParameter and _askForIparameter
      */
    function _generateTicket(address _ticketOwner) 
        public
        //onlyOwner 
    {
        _askForMuParameter(_ticketOwner);
        _askForIParameter(_ticketOwner);
    }
    
    /** @dev _generateLucky7Number is the function that is actually used to generate the Lucky7Numbers. It have the business logic for generating the Lucky7Numbers, i.e. if 
      * the indexForLucky7Array is different than the numberOfLucky7Numbers, then sets the muReady and iReady booleans of the UserParametersValue struct of the 
      * Lucky7TicketFactory contract to true and calls for the _askForMuParameter and _askForIParameter function of the Lucky7TicketFactory contract. This way it can ask for both mu and i parameters
      * to oraclize and when the oraclize respond with both, ask for a ticket which is going to be a Lucky7Number.
      * If the indexForLucky7Array is equal to the numberOfLucky7Numbers, then proceed to order the Lucky7Numbers through the _orderLucky7Numbers function of this contract.
      * Then it sets the indexForLucky7Array to 0 so the next time a new game is setted, this function starts storing the Lucky7Numbers from the position 0, to finally shut off
      * the settingLucky7Numbers circuit breaker to allow users to start buying tickets.
      */
    function _generateLucky7Number() 
        public 
        // onlyOwner 
        gameNotInCourse
    {
        uint indexForLucky7Array = Lucky7Library.indexForLucky7Array(lucky7StorageAddress);
        uint numberOfLucky7Numbers = Lucky7Library.numberOfLucky7Numbers(lucky7StorageAddress);
        if(indexForLucky7Array == numberOfLucky7Numbers){
            Lucky7Storage lucky7StorageContract = Lucky7Storage(lucky7StorageAddress);
            lucky7StorageContract._orderLucky7Numbers();
            lucky7StorageContract.setIndexForLucky7ArrayToZero();
            toggleLucky7Setting();
        }
        else{
            userValues[this].muReady = false;
            userValues[this].iReady = false;
            _generateTicket(this);
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
          * Finally, it checks if the game is currently in the setting Lucky7Numbers phase. If so, calls the storageLuckyNumber function, else it calls the 
          * storageTicket function. Both functions are on the Lucky7Storage contract.
          */
        else if (newTicketID[myid]!=0 &&  (userValues[newTicketID[myid]].userPaidTicket==true || settingLucky7Numbers==true )){
            Lucky7Storage lucky7StorageContract = Lucky7Storage(lucky7StorageAddress);
            userValues[newTicketID[myid]].ticketValue=parseInt(result);
            emit NewTicketReceived(result);
            userValues[newTicketID[myid]].userPaidTicket=false;
            if(settingLucky7Numbers==true){
                lucky7StorageContract.storageLucky7Number(
                    userValues[newTicketID[myid]].mu, 
                    userValues[newTicketID[myid]].i, 
                    userValues[newTicketID[myid]].ticketValue
                    );
            }
            else{
                lucky7StorageContract.storageTicket(
                    userValues[newTicketID[myid]].mu, 
                    userValues[newTicketID[myid]].i, 
                    userValues[newTicketID[myid]].ticketValue,
                    newTicketID[myid]
                    );
            }
        }
    }

    /** @dev Functions to set booleans of the UsersParametersValue to true or false 
      */

    function bothToFalse(address _ticketOwner)
        public
        //onlyOwner
    {
        userValues[_ticketOwner].muReady = false;
        userValues[_ticketOwner].iReady = false;
    }

    function paidTicketToTrue(address _ticketOwner)
        public
        //onlyOwner
    {
        userValues[_ticketOwner].userPaidTicket = true;
    
    }

    function userParametersEmpty(address _ticketOwner)
        public
        view
        returns(bool)
    {
        if(keccak256(userValues[_ticketOwner].mu)==keccak256("") && keccak256(userValues[_ticketOwner].i)==keccak256("")){
            return true;
        }
        else {
            return false;
        }
    }
    function() public payable{}
} 