pragma solidity ^0.4.20;

import "./Lucky7Store.sol";

contract Lucky7Test is Lucky7Store{
    
    function insertTestLucky7Numbers() public{
        lucky7Numbers[0] = Lucky7Number("1","2",10651283657614267398,drawNumber);
        lucky7Numbers[2] = Lucky7Number("1","2",52398723847810031239,drawNumber);
        lucky7Numbers[4] = Lucky7Number("1","2",30481723712938712983,drawNumber);
        lucky7Numbers[5] = Lucky7Number("1","2",24342359080214091240,drawNumber);
        lucky7Numbers[6] = Lucky7Number("1","2",75126192741201932912,drawNumber);
        _orderLucky7Numbers();
    }    
    
    function insertTestTickets() public{
        uint id=tickets.push(Ticket("1","2",24016058422221620610,address(this),drawNumber))-1;
        _checkForLucky7Ticket(id);
        id=tickets.push(Ticket("1","2",41211282110361018491,address(this),drawNumber))-1;
        _checkForLucky7Ticket(id);
        id=tickets.push(Ticket("1","2",75615966567006227384,address(this),drawNumber))-1;
        _checkForLucky7Ticket(id);
        id=tickets.push(Ticket("1","2",52440930826522170732,address(0x6401b4cde3fdf3f857f9e62c1760700750b84709),drawNumber))-1;
        _checkForLucky7Ticket(id);
        id=tickets.push(Ticket("1","2",30365787076250930766,address(0x366348aaaf19fab5b082baf3d1060fcd778fae3f),drawNumber))-1;
        _checkForLucky7Ticket(id);
        id=tickets.push(Ticket("1","2",33643378726346993905,address(this),drawNumber))-1;
        _checkForLucky7Ticket(id);
        id=tickets.push(Ticket("1","2",10903483408365649132,address(0xf294525b3d0ddeba7bb8f0be22fbfca6833e3015),drawNumber))-1;
        _checkForLucky7Ticket(id);
    }
    
    function _balance() public view returns (uint256){
        return this.balance;
    }
}
