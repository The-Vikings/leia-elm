module Components.Chatroom.Commands exposing (fetchAllChatrooms, fetchChatroomWithQuestions)

import Commands exposing (allChatroomsApiUrl, currentChatroomApiUrl)
import Components.Chatroom.Decoder exposing (chatroomDecoder, chatroomListDecoder)
import Http
import Json.Decode as Decode exposing (field)
import Messages exposing (Msg(..))
import RemoteData
import Json.Decode as Decode exposing (list)


fetchAllChatrooms : Cmd Msg
fetchAllChatrooms =
    Decode.field "data" chatroomListDecoder
        |> Http.get allChatroomsApiUrl
        |> RemoteData.sendRequest
        |> Cmd.map Messages.FetchAllChatrooms


fetchChatroomWithQuestions : String -> Cmd Msg
fetchChatroomWithQuestions chatroomId =
    Decode.field "data" chatroomDecoder
        |> Http.get (currentChatroomApiUrl chatroomId)
        |> RemoteData.sendRequest 
        |> Cmd.map Messages.FetchChatroomWithQuestions
