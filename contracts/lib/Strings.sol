// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library Strings {

    function concat(string memory _base, string memory _value) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        string memory _tmpValue = new string(_baseBytes.length + _valueBytes.length);
        bytes memory _newValue = bytes(_tmpValue);

        uint i;
        uint j;

        for (i = 0; i < _baseBytes.length; i++) {
            _newValue[j++] = _baseBytes[i];
        }

        for (i = 0; i < _valueBytes.length; i++) {
            _newValue[j++] = _valueBytes[i];
        }

        return string(_newValue);
    }

    function uintToStr(uint256 _i) internal pure returns (string memory str) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        str = string(bstr);
    }

    function descAgenda(uint8 _agenda) internal pure returns(string memory) {
        string memory returnMsg;

        if(_agenda == 1) {
            returnMsg = "owner가 토큰전송";
        } else if(_agenda == 2) {
            returnMsg = "owner가 토큰발행";
        } else if(_agenda == 3) {
            returnMsg = "owner가 토큰소각";
        } else if(_agenda == 4) {
            returnMsg = "owner가 서명자추가";
        } else if(_agenda == 5) {
            returnMsg = "owner가 서명자제거";
        } else if(_agenda == 6) {
            returnMsg = "owner가 일시정지 실행";
        } else if(_agenda == 7) {
            returnMsg = "owner가 일시정지 해제";
        } else if(_agenda == 8) {
            returnMsg = "owner가 blacklist 등록/해제 실행권한을 타 계정에 부여";
        } else if(_agenda == 9) {
            returnMsg = "owner가 blacklist 실행권한을 부여한 타 계정에 권한회수";
        } else if(_agenda == 10) {
            returnMsg = "owner가 lockup 등록/해제 실행권한을 타 계정에 부여";
        } else if(_agenda == 11) {
            returnMsg = "owner가 lockup 실행권한을 부여한 타 계정에 권한회수";
        } else if(_agenda == 12) {
            returnMsg = "owner의 위임";
        } else {
            revert("잘못된 파라미터입니다.");
        }

        return returnMsg;
    }

}
