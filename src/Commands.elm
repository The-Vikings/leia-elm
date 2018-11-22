module Commands exposing (chatroomsApiUrl, contactsApiUrl, questionsApiUrl)


contactsApiUrl : String
contactsApiUrl =
    "/api/v1/contacts"


chatroomsApiUrl : String
chatroomsApiUrl =
    "/api/chatrooms"


questionsApiUrl : String -> String
questionsApiUrl chatroomId =
    chatroomsApiUrl ++ chatroomId ++ "/questions"
