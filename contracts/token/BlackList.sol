// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Signable.sol";

contract BlackList is Signable {
    event Black(address indexed account);
    event UnBlack(address indexed account);
    event ExecutePermissionBlackListAccounts(address indexed account);
    event UnExecutePermissionBlackListAccounts(address indexed account);

    mapping(address => bool) public blackList;

    mapping(address => bool) public executePermissionBlackListAccounts;

    constructor() public {
        executePermissionBlackListAccounts[owner] = true;
    }

    modifier CheckBlackList() {
        require(blackList[msg.sender] != true, "블랙리스트에 등록되었으므로 사용할 수 없습니다.");
        _;
    }

    modifier CheckBlackListPermission() {
        require(executePermissionBlackListAccounts[msg.sender] == true, "블랙리스트 사용권한이 없습니다.");
        _;
    }

    function setBlackAccount(address _account) external CheckBlackListPermission returns (bool) {
        require(_account != address(0), "블랙리스트에 등록할 계정이 없습니다.");
        require(blackList[_account] != true, "이미 블랙리스트에 등록되었습니다.");
        blackList[_account] = true;
        emit Black(_account);
        return true;
    }

    function setUnBlackAccount(address _account) external CheckBlackListPermission returns (bool) {
        require(_account != address(0), "블랙리스트 해제를 할 계정이 없습니다.");
        require(blackList[_account] != false, "블랙리스트에 등록된 계정이 아닙니다.");

        blackList[_account] = false;
        emit UnBlack(_account);

        return true;
    }

    function setExecutePermissionAccount(address _account) external onlyOwner returns (bool) {
        require(validAllSign(), "전원의 서명이 필요합니다.");
        executePermissionBlackListAccounts[_account] = true;
        emit ExecutePermissionBlackListAccounts(_account);
        resetAgenda();
        return true;
    }

    function setUnExecutePermissionAccount(address _account) external onlyOwner returns (bool) {
        require(validAllSign(), "전원의 서명이 필요합니다.");
        executePermissionBlackListAccounts[_account] = false;
        emit UnExecutePermissionBlackListAccounts(_account);
        resetAgenda();
        return true;
    }
}