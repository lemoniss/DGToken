# DGToken

Custom ERC-20 Token

주요기능
1. transfer Gas 대납
2. owner의 견제
3. 다수의 서명자가 서명을 하고 이로인해 agenda 통과

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

일시정지, 블랙리스트, 기간잠금 기능 추가
