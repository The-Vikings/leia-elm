module Components.AutomaticAnswer.view exposing (view)

import Components.AutomaticAnswer.Model exposing (AutomaticAnswer)
import Model exposing (Model)
import Html exposing (Html, text)
import Messages exposing (Msg)


view : Model -> Html Msg
view model = 
    text "AutomaticAnswer-component-view"