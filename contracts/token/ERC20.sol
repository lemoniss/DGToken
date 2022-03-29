// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../lib/SafeMath.sol";

contract ERC20 {

    using SafeMath for uint;

    uint256 internal _totalSupply;

    mapping (address => uint) balances;

    mapping (address => mapping (address => uint)) allowed;

    event Transfer(address indexed _from, address indexed _to, uint _value);

    event Approval(address indexed _owner, address indexed _spender, uint _value);

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint) {
        return balances[_owner];
    }

    function transfer(address _to, uint _value) public returns (bool) {
        require(_to != address(0), "수신자의 지갑주소가 없습니다.");
        require(balances[msg.sender] >= _value && _value > 0, "전송할 토큰이 보유한 토큰보다 많습니다.");

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        require(_from != address(0), "발신자의 지갑주소가 없습니다.");
        require(_to != address(0), "수신자의 지갑주소가 없습니다.");
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0, "전송할 토큰이 보유한 토큰보다 많습니다.");

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);

        return true;
    }

    function approve(address _spender, uint _value) public returns (bool) {
        if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) {
            revert();
        }
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint) {
        return allowed[_owner][_spender];
    }
}
