module Commands exposing (allChatroomsApiUrl, contactsApiUrl, questionsApiUrl, currentChatroomApiUrl)

import Components.Chatroom.Model exposing (ChatroomId)

contactsApiUrl : String
contactsApiUrl =
    "/api/v1/contacts"


allChatroomsApiUrl : String
allChatroomsApiUrl =
    "/api/chatrooms"

currentChatroomApiUrl : String -> String
currentChatroomApiUrl chatroomId = 
    allChatroomsApiUrl ++ chatroomId ++ "/all"

questionsApiUrl : String -> String
questionsApiUrl chatroomId =
    allChatroomsApiUrl ++ chatroomId ++ "/questions"
