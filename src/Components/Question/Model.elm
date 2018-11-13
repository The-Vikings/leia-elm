module Components.Question.Model exposing (Question)

import Components.AutomaticAnswer.Model exposing (AutomaticAnswer)
import Components.UserAnswer.Model exposing (UserAnswer)

type alias Question = 
    { id : Int
    , votes : Int
    , automaticAnswer : AutomaticAnswer
    , userAnswers : UserAnswer
    }
