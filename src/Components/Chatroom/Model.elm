module Components.Chatroom.Model exposing (Chatroom)

import Components.Question.Model exposing (Question)

type alias Chatroom = 
    { id : ChatroomId
    , questions : List Question
    }

type alias ChatroomId =
    String