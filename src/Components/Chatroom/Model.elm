module Components.Chatroom.Model exposing (Chatroom)

type alias Chatroom = 
    { id : ChatroomId
    , name : String
    }

type alias ChatroomId =
    String