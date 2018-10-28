module Components.QuestionInput.View exposing (view)

import Components.QuestionInput.Model exposing (QuestionInput)
import Model exposing (Model)
import Html exposing (Html, text)
import Messages exposing (Msg)

view : Model -> Html Msg
view model = 
    text "QuestionInput-component-view"