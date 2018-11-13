module Commands exposing (contactsApiUrl, fetchChatrooms)

import Components.Chatroom.Model exposing (Chatroom)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Messages exposing (Msg)
import RemoteData


contactsApiUrl : String
contactsApiUrl =
    "/api/v1/contacts"


fetchChatrooms : Cmd Msg
fetchChatrooms =
    Http.get fetchChatroomsUrl chatroomsDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Messages.OnFetchChatrooms


fetchChatroomsUrl : String
fetchChatroomsUrl =
    "http://localhost/api/chatrooms"


chatroomsDecoder : Decode.Decoder (List Chatroom)
chatroomsDecoder =
    Decode.list chatroomDecoder


chatroomDecoder : Decode.Decoder Chatroom
chatroomDecoder =
    decode Chatroom
        |> required "id" Decode.string
        |> required "name" Decode.string