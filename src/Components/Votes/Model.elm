module Components.Votes.Model exposing (Votes)

type alias Votes = 
    { value : String  
    , user_id : UserId
    , updated_at : String
    , question_id : Int
    , inserted_at : String
    }

type alias UserId = 
    Int   