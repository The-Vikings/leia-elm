module Components.UserAnswer.Model exposing (UserAnswer)

type alias UserAnswer = 
    { id : Int
    , votes : Int
    , text : String
    }