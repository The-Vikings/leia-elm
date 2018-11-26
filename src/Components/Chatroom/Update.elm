module Components.Chatroom.Update exposing (update)

import Components.Chatroom.Messages exposing (ChatroomMsg(..))
import Components.Chatroom.Model exposing (..)

update : ChatroomMsg -> Chatroom -> ( Chatroom, Cmd ChatroomMsg )
update msg model =
    case msg of
        FetchChatroom -> 
            ( model, Cmd.none )