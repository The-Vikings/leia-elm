module Components.UserAnswer.view exposing (view)

import Components.UserAnswer.Model exposing (UserAnswer)
import Model exposing (Model)
import Html exposing (Html, text)
import Messages exposing (Msg)


view : Model -> Html Msg
view model = 
    text "UserAnswer-component-view"