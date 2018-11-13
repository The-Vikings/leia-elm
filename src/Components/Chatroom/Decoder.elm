module Components.Chatroom.Decoder exposing (decoder)

import Components.Chatroom.Model exposing (Chatroom)
import Components.Question.Model exposing (Question)
import Components.Question.Decoder
import Json.Decode as Decode exposing (field, int, list, string)
import Json.Decode.Extra exposing ((|:))


decoder : Decode.Decoder Chatroom
decoder =
    Decode.succeed
        Chatroom
        |: field "id" string
        |: field "questions" questionsDecoder

questionsDecoder : Decode.Decoder (List Question)
questionsDecoder =
    Decode.list Components.Question.Decoder.decoder
