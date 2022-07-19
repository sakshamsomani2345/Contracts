//SPDX-License-Identifier: GPL-3.0
pragma solidity>=0.5.0 <0.9.0;
contract auction{
    address payable public auctioneer;
    uint public stblock;
    uint public etblock;
    enum auction_state{
        started,
        running,
        end,
        cancelled
    }
    auction_state public State;
    // uint public highest_bid;
    uint public highest_payable_bid;
    uint public bid_inc;
    address  payable public highest_bidder;
    constructor(){
        auctioneer=payable(msg.sender);
        stblock=block.number;
        State=auction_state.running;
        etblock=stblock+240;
        bid_inc=1 ether;
    }
    modifier notowner(){
        require(msg.sender!=auctioneer,"owner cannot bid");
        _;
    }
     modifier owner(){
        require(msg.sender==auctioneer,"bidders cannot play");
        _;
    }
     modifier started(){
        require(block.number>stblock);
        _;
    }
    modifier beforending(){
        require(block.number<etblock);
        _;
    }
    mapping(address=>uint) public bids;
    function cancelauction() public owner{
    State=auction_state.cancelled;
    }
    function min(uint a,uint b) private pure returns(uint){
if(a<b){
    return a;
}else{
    return b;
}
    }
    function endauction() public owner{
      State=auction_state.end;
    }
    function bid()  payable notowner started beforending public{
     require(State==auction_state.running);
     require(msg.value>1 ether,"error by the way");
     uint currbid=bids[msg.sender]+msg.value ;
     require(currbid>highest_payable_bid);
     bids[msg.sender]=currbid;
     if(currbid<bids[highest_bidder]){
         highest_payable_bid=min(currbid+bid_inc,bids[highest_bidder]);
     }else{
         highest_payable_bid=min(currbid,bids[highest_bidder]+bid_inc);
         highest_bidder=payable(msg.sender);

     }
    }
    function finalizeauc()  public{
        require(State==auction_state.cancelled ||State==auction_state.end || block.number>=etblock );
        require(msg.sender==auctioneer || bids[msg.sender]>0);

address payable person;
uint value;
if(State==auction_state.cancelled){
    person=payable(msg.sender);
    value=bids[msg.sender];
}else if(msg.sender==auctioneer){
    person=auctioneer;
    value=highest_payable_bid;
    
}else{
    if(msg.sender==highest_bidder){
        person=highest_bidder;
        value=bids[highest_bidder]-highest_payable_bid;
    }else{
        person=payable(msg.sender);
        value=bids[msg.sender];
    }
}
bids[msg.sender]=0;
person.transfer(value);

    }

}
