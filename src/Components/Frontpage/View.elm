module Components.Frontpage.view exposing (view)

import Components.Frontpage.Model exposing (Frontpage)
import Model exposing (Model)
import Html exposing (Html, text)
import Messages exposing (Msg)


view : Model -> Html Msg
view model = 
    text "Frontpage-component-view"