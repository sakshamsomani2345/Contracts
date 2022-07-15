//SPDX-License-Identifier: GPL-3.0
pragma solidity>=0.5.0 <0.9.0;
abstract contract ERC20Token {
function name() virtual public view returns ( string memory);
function symbol() virtual public view returns (string memory);
function decimals() virtual public view returns (uint8);
function totalSupply()  virtual public view returns (uint256);
function balanceOf(address _owner)  virtual public view returns (uint256 balance);
function transfer(address _to, uint256 _value)  virtual public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) virtual public returns (bool success);
// function approve(address _spender, uint256 _value) virtual public returns (bool success);
// function allowance(address _owner, address _spender) virtual public view returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}
contract owned{
    address public owner;
    address public newowner;
event ownershiptransfer(address indexed _from,address indexed _to);
   constructor(){
       owner=msg.sender;
   }
   function transferownership(address _to) public {
require(msg.sender==owner);
newowner=_to;
   }
   function acceptownership() public {
       require(msg.sender==newowner);
       emit ownershiptransfer(owner,newowner);
       owner=newowner;
       newowner=address(0);
   }
}
contract token is ERC20Token,owned{
  string public _name;
   string public _symbol;
   uint8 public _decimals;
   uint256 public _totalsupply;
   address public _minter;
   mapping(address=>uint) balances;
   constructor(){
       _symbol="TK";
       _name="Mytoken";
       _decimals=0;
       _totalsupply=100;
       _minter=0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
       balances[_minter]=_totalsupply;
       emit Transfer(address(0),_minter,_totalsupply);

   }
   function name() virtual override public view returns ( string memory){
       return _name;
   }
function symbol() virtual override public view returns (string memory){
    return _symbol;
}
function decimals() virtual override public view returns (uint8){
    return _decimals;
}
function totalSupply()  virtual override  public view returns (uint256){
    return _totalsupply;
}
function balanceOf(address _owner) override virtual public view returns (uint256 balance){
    return balances[_owner];
}
function transferFrom(address _from,address _to ,uint256 _value) override  virtual public returns (bool success){
    require(balances[_from]>=_value);
balances[_from]-=_value;
balances[_to]+=_value;
emit Transfer(_from,_to,_value);
return true;
    
}
function transfer(address _to, uint256 _value) virtual override public returns (bool success){
    return transferFrom(msg.sender,_to,_value);
}
// function approve( uint256 _value) virtual  public returns (bool success){
//     return true;
// }
// function allowance(address _owner, address _spender) virtual override public view returns (uint256 remaining){
//     return 0;
// }

function mint(uint amount) public returns (bool){
    require(msg.sender==_minter);
    balances[_minter]+=amount;
    _totalsupply+=amount;
    return true;
}
function confisacte(address target,uint amount) public returns (bool){
    require(msg.sender==_minter);
    if(balances[target]>=amount){
        balances[target]=amount;
        _totalsupply-=amount;
    }else{
        _totalsupply-=balances[target];
    }
    return true;
}
}
