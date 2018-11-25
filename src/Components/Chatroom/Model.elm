module Components.Chatroom.Model exposing (Chatroom, ChatroomPayload)

import Components.Question.Model exposing (Question)

type alias Chatroom = 
    { name : String
    , id : ChatroomId
    }

type alias ChatroomId =
    Int

type alias ChatroomPayload = 
    { data : List Chatroom
    }