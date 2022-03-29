// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./token/ERC20.sol";
import "./token/MintBurn.sol";
import "./token/BlackList.sol";
import "./token/Pausable.sol";
import "./token/LockUp.sol";
import "./token/Delegatable.sol";

contract DGToken is ERC20, MintBurn, BlackList, LockUp, Pausable, Delegatable {

    string public name;
    string public symbol;
    uint8 public decimals;

    // 생성자 (최초 컨트랙트 배포시에 1회만 실행됨)
    constructor(string memory _name, string memory _symbol, uint256 _tokenTotalSupply, uint8 _decimals) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        uint256 _value = _tokenTotalSupply * (10 ** uint256(_decimals));

        balances[msg.sender] = balances[msg.sender].add(_value);
        _totalSupply = _totalSupply.add(_value);

        emit MintBurn.Mint(msg.sender, _value);
        emit Transfer(address(0), msg.sender, _value);

    }

    function transfer(address _to, uint _amount) public CheckPause CheckBlackList CheckLockUpList returns (bool) {

        if(msg.sender == owner) {       // 관리자가 전송을 할때에는
            require(validAllSign(), "All signers disagreed");       // 전원이 서명을 해야만 통과
            resetAgenda();
        }

        return super.transfer(_to, _amount);
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        revert("not support");
        return false;
    }

}
