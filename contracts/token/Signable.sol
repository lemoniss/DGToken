// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Ownable.sol";
import "../lib/Strings.sol";

contract Signable is Ownable {

    using Strings for string;

    bool globalValidSign;       // 모든 서명을 체크하는지 여부, 기본값 : true, false로 설정시 위 프로세스에서 서명여부를 체크하지 않음.

    address[] signers;          // 전체 서명자 배열
    address[] agendaSigners;    // 안건에 서명한 서명자 배열

    address removeSignerAddress;    // 삭제예정인 서명자 주소

    uint8 currentAgenda;    // 현재 안건

    constructor() public {
        // 1. 기본 서명자 세팅
        signers.push(0x703939951bd3e08D63B4e30055EAd6d5e75504Db);   // 대표이사
        signers.push(0x1a1C965e99B79feCAeE47211DF8237dd8Ccc21B2);   // 최고관리자
        // 2. 현재 서명안건 초기값
        currentAgenda = 0;
        // 3. 전체 서명체크 값을 true 로 초기화
        globalValidSign = true;
    }

    event ProposeAgenda(uint8 _agenda, string agendaDescription, uint256 date);
    event AbandonAgenda(string msg, uint256 date);
    event ResetAgenda(string msg, uint256 date);
    event AgendaSign(address indexed signer, string msg, uint256 date);
    event ProposeAgendaForRemoveSigner(uint8 _agenda, string agendaDescription, address signer, uint256 date);
    event AddSigner(address indexed signer, uint256 date);
    event RemoveSigner(address indexed signer, uint256 date);
    event SignMsg(string msg, uint256 date);

    modifier onlySigner() {
        bool isSinger = false;
        for(uint8 i= 0; i< signers.length; i++) {
            if(signers[i] == msg.sender) {
                isSinger = true;
                break;
            }
        }
        require(isSinger, "등록된 서명자가 아닙니다.");
        _;
    }
    /*
        서명안건 타입
        1. owner가 토큰전송
        2. owner가 토큰발행
        3. owner가 토큰소각
        4. owner가 서명자추가
        5. owner가 서명자제거
        6. owner가 일시정지 실행
        7. owner가 일시정지 해제
        8. owner가 blacklist 등록/해제 실행권한을 타 계정에 부여
        9. owner가 blacklist 실행권한을 부여한 타 계정에 권한회수
        10. owner가 lockup 등록/해제 실행권한을 타 계정에 부여
        11. owner가 lockup 실행권한을 부여한 타 계정에 권한회수
        12. owner의 위임
        13. 모든 서명을 체크하는지 여부 (true/false)
            false로 설정시 위 프로세스에서 서명여부를 체크하지 않음.
            (13번기능은 검증이 필요하므로 4월1일 버전에는 제외함.)
    */
    //------------------------------------------------------------------------------------------------------------
    function proposeAgenda(uint8 _agenda) external onlyOwner returns (bool) {    // owner가 안건 발의 (서명자삭제 제외)
        require(_agenda != 5, "서명자제거 안건은 발의할 수 없습니다.");
        require(currentAgenda == 0, Strings.concat("이미 발의된 서명안건이 있습니다. : ", Strings.descAgenda(_agenda)));
        currentAgenda = _agenda;
        emit ProposeAgenda(_agenda, Strings.descAgenda(_agenda), now);
        return true;
    }

    function proposeAgendaForRemoveSigner(uint8 _agenda, address _removeSigner) external onlyOwner returns (bool) {    // owner가 안건 발의 (서명자삭제 전용)
        require(_agenda == 5, "서명자제거 안건만 발의할 수 없습니다.");
        require(currentAgenda == 0, Strings.concat("이미 발의된 서명안건이 있습니다. : ", Strings.descAgenda(_agenda)));
        currentAgenda = _agenda;
        removeSignerAddress = _removeSigner;
        emit ProposeAgendaForRemoveSigner(_agenda, Strings.descAgenda(_agenda), _removeSigner, now);
        return true;
    }

    function abandonAgenda() external onlyOwner returns (bool) { // owner가 안건 폐기
        require(currentAgenda != 0, "폐기할 서명안건이 없습니다.");
        emit AbandonAgenda(Strings.concat("안건이 폐기되었습니다. : ", Strings.descAgenda(currentAgenda)), now);
        currentAgenda = 0;                  // 현재안건 초기화
        agendaSigners = new address[](0);   // 현재안건이 폐기되었으므로, 안건에 서명한 사람도 리셋
        return true;
    }

    function agendaSign(uint8 _agenda) external onlySigner returns (bool) {   // 서명자가 안건에 서명함
        require(_agenda == currentAgenda, "서명하려는 안건과 현재진행중인 안건이 다릅니다.");

        for(uint8 i= 0; i< agendaSigners.length; i++) {
            if(agendaSigners[i] == msg.sender) {
                revert("이미 서명을 했습니다.");
            }
        }
        agendaSigners.push(msg.sender);
        emit AgendaSign(msg.sender, Strings.descAgenda(_agenda), now);
        return true;
    }

    function resetAgenda() internal {
        if(globalValidSign) {   // 전체서명체크를 안한다면
            currentAgenda = 0;                  // 현재안건 초기화
            agendaSigners = new address[](0);   // 현재안건이 초기화되었으므로, 안건에 서명한 사람도 리셋
            emit ResetAgenda("안건 및 서명데이터를 초기화", now);
        }
    }

    function validAllSign() internal returns (bool) { // 서명자 전원 서명 체크
        if(!globalValidSign) {   // 전체서명체크를 안한다면
            return true;
        } else if(agendaSigners.length == signers.length) {
            return true;
        } else {
            emit SignMsg("전체 서명자가 동의하지 않았습니다.", now);
            return false;
        }
    }

    function validSignExceptMe(address _signer) internal returns (bool) {   // 서명자 나를 제외한 전원 서명 체크
        if(!globalValidSign) {   // 전체서명체크를 안한다면
            return true;
        } else {
            uint8 signCnt = 0;
            for(uint8 i= 0; i< agendaSigners.length; i++) {
                if(agendaSigners[i] == _signer) {
                    continue;
                }
                signCnt++;
            }
            if(signCnt == signers.length-1 ) {
                return true;
            } else {
                emit SignMsg("삭제 서명자를 제외한 전원의 서명이 필요합니다." , now);
                return false;
            }
        }
    }

    //------------------------------------------------------------------------------------------------------------
    function addSigner(address _newSigner) external onlyOwner returns (bool) { // 서명자 추가
        require(_newSigner != address(0), "서명자 주소가 없습니다.");  // 파라미터 빈값이면 안됨
        require(validAllSign(), "전체 서명자가 동의하지 않았습니다.");

        for(uint8 i= 0; i< signers.length; i++) {
            require(signers[i] != _newSigner, "이미 등록된 서명자입니다.");
        }

        signers.push(_newSigner);
        resetAgenda();
        emit AddSigner(_newSigner, now);
        return true;
    }

    function removeSigner(address _removeSigner) external onlyOwner returns (bool) {   // 서명자 제거
        require(_removeSigner != address(0), "서명자 주소가 없습니다.");  // 파라미터 빈값이면 안됨
        require(validSignExceptMe(_removeSigner), "전체 서명자가 동의하지 않았습니다.");

        for(uint8 i= 0; i< signers.length; i++) {
            if(signers[i] == _removeSigner) {
                signers[i] = signers[signers.length-1];
                signers.pop();
                break;
            }
        }
        removeSignerAddress = address(0);
        resetAgenda();
        emit RemoveSigner(_removeSigner, now);
        return true;
    }

    function transferOwnership(address _newOwner) external onlyOwner returns (bool) {  // owner 위임
        require(validAllSign(), "전체 서명자가 동의하지 않았습니다.");
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
        resetAgenda();
        return true;
    }
    //------------------------------------------------------------------------------------------------------------
    function getCurrentAgendaAndSigners() external view onlyOwner returns(uint8 getAgenda, address[] memory getSigners, address getRemoveSigner) {   // 현재안건과 안건에 서명한 서명자목록 가져오기 (안건이 삭제인 경우 삭제예정인 주소도 포함)
        return (currentAgenda, agendaSigners, removeSignerAddress);
    }

    function getAllSigners() external view onlyOwner returns(address[] memory getSigners) {   // 전체 서명자목록 가져오기
        return signers;
    }

    function getCurrentAgenda() external view onlySigner returns(uint8 getAgenda, address getRemoveSigner) {   // 현재안건
        return (currentAgenda, removeSignerAddress);
    }
}
