#파일 실행 스크립트: 프로그램 + 이름 + 전화번호
#프로그램 내용:
# 검색: 입력된 이름으로 전화번호부를 검색한다.
#존재하면 전화번호 비교한다. 동일하면 메시지 프린트하고 프로그램 종료
#다르면 새로운 전화번호로 추가하고 이름순으로 정렬한다.
#잘못된 입력값 판별하기
#번호가 숫자일 경우만 실행한다.
#전화번호는 하이픈(-)으로 연결해서 저장한다.
#인수는 2개 전달되어야 함. 종료 코드 설정할 것
#지역번호 구현하기
#전화번호를 저장할 때 지역번호에 따라 "이름 전화번호 지역" 으로 저장한다.
#예: 홍길동 02-2222-2222 서울
#지역번호는 자유롭게 구현하되 최소 5개 있을 것


#!/bin/bash

PHONEBOOK="phonebook.txt"

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <이름> <전화번호>"
    exit 1
fi

NAME="$1"
PHONE="$2"

if ! [[ "$PHONE" =~ ^[0-9]{2,3}-[0-9]{3,4}-[0-9]{4}$ ]]; then
    echo "형식이 잘못되었습니다."
    exit 2
fi

AREA_CODE="${PHONE%%-*}"
REGION=""

case "$AREA_CODE" in
    "02")
        REGION="서울"
        ;;
    "031")
        REGION="경기"
        ;;
    "032")
        REGION="인천"
        ;;
    "051")
        REGION="부산"
        ;;
    "053")
        REGION="대구"
        ;;
    *)
        echo "알 수 없는 지역코드입니다."
        exit 2
        ;;
esac

TEMP_FILE=$(mktemp)

FOUND=0
while IFS= read -r LINE; do
    CURRENT_NAME=$(echo "$LINE" | awk '{print $1}')
    CURRENT_PHONE=$(echo "$LINE" | awk '{print $2}')
    CURRENT_REGION=$(echo "$LINE" | awk '{print $3}')

    if [ "$CURRENT_NAME" == "$NAME" ]; then
        FOUND=1
        if [ "$CURRENT_PHONE" == "$PHONE" ]; then
            echo "The phone number for $NAME is already $PHONE."
            rm -f "$TEMP_FILE"
            exit 0
        else
            echo "$NAME $PHONE $REGION" >> "$TEMP_FILE"
        fi
    else
        echo "$LINE" >> "$TEMP_FILE"
    fi
done < "$PHONEBOOK"

if [ $FOUND -eq 0 ]; then
    echo "$NAME $PHONE $REGION" >> "$TEMP_FILE"
fi

sort "$TEMP_FILE" > "$PHONEBOOK"
rm -f "$TEMP_FILE"

echo "Updated phonebook for $NAME with phone number $PHONE."
exit 0


