//SPDX-License-Identifier: GPL-3.0
pragma solidity>=0.5.0 <0.9.0;
contract crowdfunding{
    mapping (address=>uint) public contributors;
    address public manager;
    uint public minimumcontribution;
    uint public target;
    uint public raisedamount;
    uint public noOfcontributors;
    uint public deadline;
    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfvoters;
        mapping(address=>bool) voters;
    }
    // function hello() pure returns(bool){

    // }
    mapping (uint=>Request) public requests;
    uint public numRequests;
    constructor(uint _target,uint _deadline){
        target=_target;
        deadline=block.timestamp+_deadline;
        minimumcontribution=100 wei;
        manager=msg.sender;
    }
    function sendether() public payable{
        require(block.timestamp<deadline,"deadline has passed");
        require(msg.value>minimumcontribution,"min contribution is not met");
        if(contributors[msg.sender]==0){
            noOfcontributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedamount+=msg.value;
    }
    function getcontract() public view returns(uint ){
        return address(this).balance;
    }
    function refund() payable public{
     require(block.timestamp>deadline && raisedamount<target);
     require(contributors[msg.sender]>0);
     address payable user=payable(msg.sender);
     user.transfer(contributors[msg.sender]);
     contributors[msg.sender]=0;   
    }
    modifier onlymanager(){
        require(msg.sender==manager,"only manager can access");
        _;
    }
    function createrequest(string memory _description,address payable _recipient,uint _value) public onlymanager{
        Request storage newRequest=requests[numRequests];
        numRequests++;
        newRequest.description=_description;
        newRequest.recipient=_recipient;
        newRequest.value=_value;
        newRequest.completed=false;
        newRequest.noOfvoters=0;
    }
    function voterequest(uint _requestno) public {
        require(contributors[msg.sender]>0,"Not a contributor");
        Request storage thisrequest=requests[_requestno];
        require(thisrequest.voters[msg.sender]==false,"already voted");
        thisrequest.voters[msg.sender]=true;
        thisrequest.noOfvoters++;
    }
    function makepayment(uint _requestno) public onlymanager{
        require(raisedamount>=target);
        Request storage thisrequest=requests[_requestno];
        require(thisrequest.completed==false,"the request has already been completed");
        require(thisrequest.noOfvoters>noOfcontributors/2,"majority doesnot support");
        thisrequest.recipient.transfer(thisrequest.value);
        thisrequest.completed=true;

    } 
}
