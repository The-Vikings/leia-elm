module Commands exposing (contactsApiUrl, chatroomsApiUrl, questionsApiUrl)

import Components.Chatroom.Model exposing (Chatroom)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Messages exposing (Msg)
import RemoteData


contactsApiUrl : String
contactsApiUrl =
    "/api/v1/contacts"


chatroomsApiUrl : String
chatroomsApiUrl =
    "/api/chatrooms"

questionsApiUrl : String -> String
questionsApiUrl chatroomId = 
    chatroomsApiUrl ++ chatroomId ++ "/questions"
