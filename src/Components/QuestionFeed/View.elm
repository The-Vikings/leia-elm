module Components.QuestionFeed.view exposing (view)

import Components.QuestionFeed.Model exposing (QuestionFeed)
import Model exposing (Model)
import Html exposing (Html, text)
import Messages exposing (Msg)


view : Model -> Html Msg
view model = 
    text "QuestionFeed-component-view"