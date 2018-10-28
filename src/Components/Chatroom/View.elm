module Components.Chatroom.view exposing (view)

import Components.Chatroom.Model exposing (Chatroom)
import Model exposing (Model)
import Html exposing (Html, text)
import Messages exposing (Msg)


view : Model -> Html Msg
view model = 
    text "Chatroom-component-view"