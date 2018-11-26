module Components.Question.Model exposing (AutomaticAnswer, Question, UserAnswer)

import Components.Votes.Model exposing (Votes)

type alias Question =
    { votes : List Votes
    , user_id : Int
    , updated_at : String
    , userAnswers : List UserAnswer
    , inserted_at : String
    , id : QuestionId
    , text : String
    }


type alias QuestionId =
    Int


type alias AutomaticAnswer =
    { userId : UserId
    , updated_at : String
    , question_id : Int
    , inserted_at : String
    , text : String
    }


type alias UserAnswer =
    { userId : UserId
    , updated_at : String
    , question_id : Int
    , inserted_at : String
    , text : String
    }


type alias UserId =
    Int