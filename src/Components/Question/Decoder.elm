module Components.Question.Decoder exposing (questionDecoder, userAnswerDecoder, automaticAnswerDecoder)

import Components.Question.Model exposing (AutomaticAnswer, Question, UserAnswer)
import Components.Votes.Model exposing (Votes)
import Json.Decode as Decode exposing (Decoder, decodeString, field, int, list, map, map2, map3, map5, string)
import Json.Decode.Pipeline exposing (decode, optional, required)


questionDecoder : Decoder Question
questionDecoder =
    decode Question
        |> optional "votes" (list votesDecoder) []
        |> required "user_id" int
        |> required "updated_at" string
        |> optional "replies" (list userAnswerDecoder) []
        |> required "inserted_at" string
        |> required "id" int
        |> required "body" string
        |> optional "autoanswers" (list automaticAnswerDecoder) []
        |> optional "votesNumber" int 0


automaticAnswerDecoder : Decoder AutomaticAnswer
automaticAnswerDecoder =
    decode AutomaticAnswer
        |> required "updated_at" string
        |> required "question_id" int
        |> required "inserted_at" string
        |> required "body" string


userAnswerDecoder : Decoder UserAnswer
userAnswerDecoder =
    decode UserAnswer
        |> required "user_id" int
        |> required "updated_at" string
        |> required "question_id" int
        |> required "inserted_at" string
        |> required "body" string


votesDecoder : Decoder Votes
votesDecoder =
    decode Votes
        |> required "value" int 
        |> required "user_id" int
        |> required "updated_at" string
        |> required "question_id" int
        |> required "inserted_at" string
