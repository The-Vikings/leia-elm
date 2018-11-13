module Components.Question.Messages exposing (QuestionMsg(..))

import Components.Question.Model exposing (Question)
import Http

type QuestionMsg
    = FetchQuestion (Result Http.Error Question)

