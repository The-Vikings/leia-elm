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
    , automaticAnswers : List AutomaticAnswer
    }


type alias QuestionId =
    Int


type alias AutomaticAnswer =
    { updated_at : String
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


{--
{"data":
{"questions":
[{"votes":
[{"value":1,"user_id":1,"updated_at":"2018-11-28T05:50:57.255974","question_id":1,"inserted_at":"2018-11-28T05:50:57.255945"}],
"user_id":1,"updated_at":"2018-11-28T05:50:57.221341",
"replies":[{"user_id":1,"updated_at":"2018-11-28T05:50:57.228999","question_id":1,"inserted_at":"2018-11-28T05:50:57.228977","body":"A dummy reply to the dummy question, by user 1"}],
"inserted_at":"2018-11-28T05:50:57.221314","id":1,"body":"Dummy question?",
"autoanswers":[{"updated_at":"2018-11-28T05:50:57.246784","question_id":1,"inserted_at":"2018-11-28T05:50:57.246734","body":"An automatic answer to the dummy question"}]
}],"name":"Dummy room","id":1}}
--}