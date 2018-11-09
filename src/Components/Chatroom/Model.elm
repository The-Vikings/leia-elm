module Components.Chatroom.Model exposing (Chatroom)

type alias Chatroom = 
    { id : ChatroomId
    , name : String
    , level : Int
    }

type alias ChatroomId =
    String