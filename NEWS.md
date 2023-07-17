# bitGPT 0.4.1.9000

## NEW FEATURES

* GPT-4 모델의 지원. (thanks to @statkclee, #38, #39). 
    - chat_completion()
    - 지원 GPT-4 모델
        - gpt-4, gpt-4-0613, gpt-4-32k, gpt-4-32k-0613
    
    
    
# bitGPT 0.4.0

## NEW FEATURES

* update.messages() 메소드 추가. (#35). 
    - messages 클래스 객체이서 이전 메시지 성분 수정
    
* 마지막 언어모델 사용 토큰 정보조회 함수 추가. (#36). 
    - get_last_tokens()
    
## MAJOR CHANGES

* 결과 반환에 사용 토큰 개수 정보를 인지하는 방법 제공. (#34). 
  - chat_completion()
  - create_completion()
  - create_embeddings()
 
## MINOR CHANGES

* chat_completion() 모델 패러미터 초기값 설정 및 도움말 보강. (#32). 

* show.messages() 출력 시 HTML 타이틀 제거. (#37).  

    
    
# bitGPT 0.3.8.

## MINOR CHANGES

* show.messages()에 HTML 파일 생성 디렉토리 지정 기능 추가. (#33). 
    - type = "viewer"일 경우 파일 생성 디렉토리 지정 기능
    
    
    
# bitGPT 0.3.7.

## MINOR CHANGES

* show.messages()에 `is_browse` parameter 추가. (#31). 
    - type = "viewer"일 경우 브라우징 여부 선택



# bitGPT 0.3.6.

## NEW FEATURES

* 사용자가 R 콘솔에서 채팅을 수행하는 용도의 함수. (#25, thanks to HelloDataScience). 
    - keep_completion() 
* messages 객체에서 마지막 질문과 답변 추출 함수. (#27). 
    - last()
* 패키지 environment의 채팅 messages 객체 추출 함수. (#29).
    - extract_chat()
    
## BUG FIX

* README 파일의 오류 수정. (#24, thanks to HelloDataScience).
* type = 'viewer' 인수 지정 시 chat_completion() 함수에서 아이콘을 찾지 못하는 오류 수정. (#24, thanks to HelloDataScience).
    
## MINOR CHANGES

* create_completion() 도움말 예제 수정. (#30). 



# bitGPT 0.3.5.

## MINOR CHANGES

* chat_completion() 함수의 type 인수 컴플릭 수정. (#23). 
* 현행 지원 함수의 형상으로 README 내용 수정. (#21).     



# bitGPT 0.3.4.

## NEW FEATURES

* Create embeddings 인터페이스 기능. (#22). 
    - create_embeddings()
    
    
    
# bitGPT 0.3.3.

## NEW FEATURES

* Create completion API 인터페이스 기능. (#13). 
    - create_completion()



# bitGPT 0.3.2.

## NEW FEATURES

* 모델 인스턴스 검색 기능. (#19). 
    - retrieve_model()



# bitGPT 0.3.1.

## NEW FEATURES

* messages 객체 출력 및 웹 브라우징 메소드. (#17). 
    - show()

* Model lists 조회 기능. (#18). 
    - list_models()



# bitGPT 0.3.0.

## NEW FEATURES

* message 클래스 객체의 정의 및 관련 메소드 정의. (#12). 
    - create_messages()
    - add.messages()

## MAJOR CHANGES

* chat completion의 message 처리 세분화. (#15).

## MINOR CHANGES

* chat completion의 반환 유형에 "messages" 추가 및 "viewer" 유형의 개선.
    - chat_completion()


# bitGPT 0.2.2.

## NEW FEATURES

* 실시간 음성(오디오) 레코드 기능의 추가. (#12). 
    - record_audio()
    
    
    
# bitGPT 0.2.1.

## NEW FEATURES

* chatGPT를 이용한 이미지 편집. (#11). 
    - draw_img_edit()
    
    
    
# bitGPT 0.2.0.

## NEW FEATURES

* chatGPT를 이용한 chat completion. (#9). 
    - chat_completion()
    
    
    
# bitGPT 0.1.0.9000

## NEW FEATURES

* chatGPT를 이용한 Speech to Text. (#7). 
    - transcript_audio()


# bitGPT 0.0.2.

## NEW FEATURES

* chatGPT를 이용한 이미지 변형. (#6). 
    - draw_img_variation()
    


# bitGPT 0.0.1.

## NEW FEATURES

* Naver 파파고 번역기. (#1).
    - translate()

* chatGPT를 이용한 이미지 생성. (#2). 
    - draw_img()
    
* API key 리소스 핸들링 기능. (#3). 
