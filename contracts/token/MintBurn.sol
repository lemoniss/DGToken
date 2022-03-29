// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./ERC20.sol";
import "./Signable.sol";

contract MintBurn is ERC20, Signable {

    event Mint(address indexed minter, uint256 value);
    event Burn(address indexed burner, uint256 value);

    function mint(address _account, uint256 _value) public onlyOwner returns (bool) {
        require(_account != address(0), "관리자의 지갑주소가 없습니다.");

        require(validAllSign(), "전원의 서명이 필요합니다.");

        balances[_account] = balances[_account].add(_value);
        _totalSupply = _totalSupply.add(_value);

        emit Mint(_account, _value);

        resetAgenda();
        return true;
    }

    function burn(address _account, uint256 _value) public onlyOwner returns (bool) {
        require(_account != address(0), "관리자의 지갑주소가 없습니다.");
        require(_value <= balances[_account]);

        require(validAllSign(), "전원의 서명이 필요합니다.");

        balances[_account] = balances[_account].sub(_value);
        _totalSupply = _totalSupply.sub(_value);

        emit Burn(_account, _value);

        resetAgenda();
        return true;
    }
}