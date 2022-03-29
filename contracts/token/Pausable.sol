// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Signable.sol";

contract Pausable is Signable {

    event Pause(address indexed account);
    event UnPause(address indexed account);

    bool isPause = false;

    modifier CheckPause() {
        require(isPause == false);
        _;
    }

    function setPause() external onlyOwner returns (bool) {
        require(validAllSign(), "전원의 서명이 필요합니다.");
        require(isPause == false);
        isPause = true;
        emit Pause(msg.sender);
        resetAgenda();
        return true;
    }

    function setUnPause() external onlyOwner returns (bool) {
        require(validAllSign(), "전원의 서명이 필요합니다.");
        require(isPause == true);
        isPause = false;
        emit UnPause(msg.sender);
        resetAgenda();
        return true;
    }
}