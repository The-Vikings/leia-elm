module Components.Question.Decoder exposing (decoder)

import Components.Question.Model exposing (AutomaticAnswer, Question, UserAnswer)
import Json.Decode as Decode exposing (field, int, list, string)
import Json.Decode.Extra exposing ((|:))


decoder : Decode.Decoder Question
decoder =
    Decode.succeed
        Question
        |: field "id" int
        |: field "votes" int
        |: field "text" string
        |: field "userAnswers" userAnswersDecoder
        |: field "automaticAnswers" automaticAnswersDecoder


userAnswersDecoder : Decode.Decoder (List UserAnswer)
userAnswersDecoder =
    Decode.list userAnswerDecoder


userAnswerDecoder : Decode.Decoder UserAnswer
userAnswerDecoder =
    Decode.succeed
        UserAnswer
        |: field "id" int
        --Type is UserAnswerId
        |: field "votes" int
        |: field "text" string


automaticAnswersDecoder : Decode.Decoder (List AutomaticAnswer)
automaticAnswersDecoder =
    Decode.list automaticAnswerDecoder


automaticAnswerDecoder : Decode.Decoder AutomaticAnswer
automaticAnswerDecoder =
    Decode.succeed
        AutomaticAnswer
        |: field "id" int
        --Type is AutomaticAnswerId
        |: field "votes" int
        |: field "text" string
