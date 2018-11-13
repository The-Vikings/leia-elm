module Components.Question.view exposing (view)

import Components.Question.Model exposing (Question)
import Model exposing (Model)
import Html exposing (Html, text)
import Messages exposing (Msg)


view : Model -> Html Msg
view model = 
    text "Question-component-view"