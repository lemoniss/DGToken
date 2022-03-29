// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./ERC20.sol";

contract Delegatable is ERC20 {

    mapping(bytes => bool) signatures;
    mapping (address => uint256) nonces;

    bytes4 internal constant transferSig = 0x15420b71;

    event TransferPreSigned(address indexed from, address indexed to, address indexed delegate, uint256 amount);

    function getNonce(address _owner) public view returns (uint256 nonce){
        return nonces[_owner];
    }

    function transferPreSigned(
        bytes memory _signature,    // 최초발신자의 서명값
        address _to,    // 수신자 지갑주소
        uint256 _value, // 전송할 토큰수량
        uint256 _nonce  // 서명트랜잭션의 nonce
    )
    public
    returns (bool)
    {
        require(_to != address(0), "수신자의 지갑주소가 없습니다.");
        require(_signature.length != 0, "발신자 서명이 없습니다.");
        require(signatures[_signature] == false, "이미 사용된 발신자 서명입니다.");
        bytes32 hashedTx = recoverPreSignedHash(_to, _value, _nonce);
        address from = recover(hashedTx, _signature);
        require(from != address(0), "최초발신자의 주소가 없습니다.");
        require(_nonce == nonces[from], "nonce가 일치하지 않습니다.");

        require(balances[from] >= _value && _value > 0, "전송할 토큰이 보유한 토큰보다 많습니다.");

        nonces[from] = _nonce.add(1);
        signatures[_signature] = true;
        balances[from] = balances[from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit TransferPreSigned(from, _to, msg.sender, _value);
        return true;
    }

    function recoverPreSignedHash(
        address _to,    // 수신자 지갑주소
        uint256 _value, // 전송할 토큰수량
        uint256 _nonce  // 서명트랜잭션의 nonce
    )
    public view returns (bytes32)
    {
        return keccak256(abi.encodePacked(transferSig, address(this), _to, _value, _nonce));
    }

    function recover(bytes32 hash, bytes memory signature) public pure returns (address) {

        if (signature.length != 65) {
            return address(0);
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return address(0);
        } else {
//            bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
            bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Klaytn Signed Message:\n32", hash));
            return ecrecover(prefixedHash, v, r, s);    // 서명검증 후 signature파라미터의 서명자주소를 리턴
        }
    }
}
