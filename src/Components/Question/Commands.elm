module Components.Question.Commands exposing (fetchQuestions)

import Commands exposing (questionsApiUrl)
import Components.Question.Model exposing (Question)
import Components.Question.Decoder as Decoder
import Components.Question.Messages exposing (QuestionMsg(FetchQuestion))
import Http
import Json.Decode as Decode exposing (field, int, list, string)
import Json.Decode.Extra exposing ((|:))
import Json.Decode.Pipeline exposing (decode, required)
import Messages exposing (Msg(QuestionMsg))


fetchQuestions : Cmd Msg
fetchQuestions =
    Http.get ("111" questionsApiUrl) questionsDecoder
        --hardcoded id as of now
        |> RemoteData.sendRequest
        |> Cmd.map Messages.OnFetchQuestions


questionsDecoder : Decode.Decoder (List Question)
questionsDecoder =
    Decode.list questionDecoder


questionDecoder : Decode.Decoder Question
questionDecoder =
    decode Question
        |> required "id" Decode.string
        |> required "name" Decode.string
