// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Signable.sol";
import "../lib/SafeMath.sol";

contract LockUp is Signable {
    event Lock(address indexed account, uint256 lockingDate);
    event UnLock(address indexed account);
    event SetLockDays(address indexed account, uint256 lockDays);
    event ExecutePermissionLockUpAccounts(address indexed account);
    event UnExecutePermissionLockUpAccounts(address indexed account);

    using SafeMath for uint;

    uint256 oneDaySecond;

    mapping(address => uint256) public lockUpList;

    mapping(address => bool) public executePermissionLockUpAccounts;

    constructor() public {
        oneDaySecond = 86400;
        executePermissionLockUpAccounts[owner] = true;
    }

    modifier CheckLockUpList() {
        require(lockUpList[msg.sender] < now, "잠김기간이 남았으므로 사용할 수 없습니다.");
        _;
    }

    modifier CheckLockUpPermission() {
        require(executePermissionLockUpAccounts[msg.sender] == true, "락업 사용권한이 없습니다.");
        _;
    }

    function setLockAccount(address _account, uint256 _lockDays) external CheckLockUpPermission returns (bool) {
        require(_account != address(0), "잠김계정이 없습니다.");
        require(_lockDays != 0, "짐김기간(일)이 없습니다.");
        require(lockUpList[_account] < now);

        lockUpList[_account] = SafeMath.mul(_lockDays, oneDaySecond);
        emit Lock(_account, lockUpList[_account]);

        return true;
    }

    function setUnLockAccount(address _account) external CheckLockUpPermission returns (bool) {
        require(_account != address(0), "잠금해제할 계정이 없습니다.");
        require(lockUpList[_account] > now);

        lockUpList[_account] = 0;
        emit UnLock(_account);

        return true;
    }

    function setExecutePermissionAccount(address _account) external onlyOwner returns (bool) {
        require(validAllSign(), "전원의 서명이 필요합니다.");
        executePermissionLockUpAccounts[_account] = true;
        emit ExecutePermissionLockUpAccounts(_account);
        resetAgenda();
        return true;
    }

    function setUnExecutePermissionAccount(address _account) external onlyOwner returns (bool) {
        require(validAllSign(), "전원의 서명이 필요합니다.");
        executePermissionLockUpAccounts[_account] = false;
        emit UnExecutePermissionLockUpAccounts(_account);
        resetAgenda();
        return true;
    }
}