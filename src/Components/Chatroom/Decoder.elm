module Components.Chatroom.Decoder exposing (chatroomDecoder, chatroomListDecoder)

import Components.Chatroom.Model exposing (Chatroom)
import Components.Question.Decoder exposing (questionsDecoder)
import Json.Decode as Decode exposing (Decoder, decodeString, field, int, list, map, map2, map3, map5, string)
import Json.Decode.Pipeline exposing (decode, optional, required)


chatroomDecoder : Decoder Chatroom
chatroomDecoder =
    decode Chatroom
        |> optional "questions" (list questionsDecoder) []
        |> required "name" string
        |> required "id" int


chatroomListDecoder : Decode.Decoder (List Chatroom)
chatroomListDecoder =
    Decode.list chatroomDecoder
