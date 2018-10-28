module Components.Votes.view exposing (view)

import Components.Votes.Model exposing (Votes)
import Model exposing (Model)
import Html exposing (Html, text)
import Messages exposing (Msg)


view : Model -> Html Msg
view model = 
    text "Votes-component-view"