module Components.Chatroom.Commands exposing (fetchChatroom, fetchChatrooms)

import Commands exposing (chatroomsApiUrl)
import Components.Chatroom.Decoder as Decoder
import Components.Chatroom.Messages exposing (ChatroomMsg(FetchChatroom))
import Components.Chatroom.Model exposing (Chatroom)
import Components.Question.Decoder
import Components.Question.Model exposing (Question)
import Http
import Json.Decode as Decode exposing (field, int, list, string)
import Json.Decode.Extra exposing ((|:))
import Json.Decode.Pipeline exposing (decode, required)
import Messages exposing (Msg(ChatroomMsg))
import RemoteData


fetchChatroom : String -> Cmd Msg
fetchChatroom id =
    let
        apiUrl =
            chatroomsApiUrl ++ "/" ++ id
    in
    Decoder.decoder
        |> Http.get apiUrl
        |> Http.send FetchChatroom
        |> Cmd.map ChatroomMsg


fetchChatrooms : Cmd Msg
fetchChatrooms =
    Http.get chatroomsApiUrl chatroomsDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Messages.OnFetchChatrooms


chatroomsDecoder : Decode.Decoder (List Chatroom)
chatroomsDecoder =
    Decode.list chatroomDecoder


chatroomDecoder : Decode.Decoder Chatroom
chatroomDecoder =
    decode Chatroom
        |> required "id" Decode.string
        |> required "name" questionsDecoder


questionsDecoder : Decode.Decoder (List Question)
questionsDecoder =
    Decode.list Components.Question.Decoder.decoder
