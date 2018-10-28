module Components.AnswerFeed.view exposing (view)

import Components.AnswerFeed.Model exposing (AnswerFeed)
import Model exposing (Model)
import Html exposing (Html, text)
import Messages exposing (Msg)


view : Model -> Html Msg
view model = 
    text "AnswerFeed-component-view"