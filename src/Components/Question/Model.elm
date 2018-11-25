module Components.Question.Model exposing (AutomaticAnswer, Question, UserAnswer)


type alias Question =
    { id : QuestionId
    , votes : Int
    , text : String
    , automaticAnswers : List AutomaticAnswer
    , userAnswers : List UserAnswer
    }


type alias QuestionId =
    Int


type alias AutomaticAnswer =
    { id : AutomaticAnswerId
    , votes : Int
    , text : String
    }


type alias AutomaticAnswerId =
    Int


type alias UserAnswer =
    { id : UserAnswerId
    , votes : Int
    , text : String
    }


type alias UserAnswerId =
    Int
