module Components.Chatroom.Model exposing (Chatroom, ChatroomId)

import Components.Question.Model exposing (Question)

type alias Chatroom = 
    { questions : List Question
    , name : String
    , id : ChatroomId
    }

type alias ChatroomId =
    Int
