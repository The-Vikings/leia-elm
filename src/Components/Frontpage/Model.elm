module Components.Frontpage.Model exposing (Frontpage)

import Components.Chatroom.Model exposing (Chatroom)

type alias Frontpage = 
    { entries : List Chatroom
    , totalEntries : Int
    }