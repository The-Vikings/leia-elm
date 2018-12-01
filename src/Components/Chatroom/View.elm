module Components.Chatroom.View exposing (view)

import Components.Question.Model exposing (Question, QuestionId)
import Components.Question.View exposing (view)
import Html exposing (Html, div, h3, li, table, tbody, td, text, th, thead, tr, ul)
import Material.Button as Button
import Material.Card as Card
import Material.Color as Color
import Material.Elevation as Elevation
import Material.Grid as Grid exposing (Device(..), cell, grid, size)
import Material.Icon as Icon
import Material.Options as Options exposing (cs, css, when)
import Material.Textfield as Textfield
import Material.Tooltip as Tooltip
import Messages exposing (Msg(..))
import Model exposing (Model)
import RemoteData
import Shared.View exposing (createErrorMessage, dynamic, viewError, white)


view : Model -> Html Msg
view model =
    grid [ Options.css "max-width" "720px" ]
        [ cell
            [ size All 12
            , Options.css "align-items" "center"
            , Options.css "padding" "32px 32px"
            , Options.css "display" "flex"
            , Options.css "flex-direction" "column"
            ]
            [ questionInput model
            ]
        , cell
            [ size All 12
            , Options.css "padding" "32px 32px"
            , Options.css "display" "flex"
            , Options.css "flex-direction" "column"
            , Options.css "align-items" "center"
            ]
            [ viewQuestionsOrError model
            ]
        ]


viewQuestionsOrError : Model -> Html Msg
viewQuestionsOrError model =
    case model.chatroom of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            h3 [] [ text "Loading..." ]

        RemoteData.Success chatroom ->
            viewQuestionCards chatroom.questions model

        RemoteData.Failure httpError ->
            viewError (createErrorMessage httpError)


viewQuestionCards : List Question -> Model -> Html Msg
viewQuestionCards questions model =
    Html.table [] (List.map (questionCardOrExpandedCard model) questions)

questionCardOrExpandedCard : Model -> Question -> Html Msg
questionCardOrExpandedCard model question = 
    case model.expandedQuestion of 
        Just value ->
            if question.id == value then
                questionCard model question -- Will be exchanged with the view function for when a card should be expanded with it's replies
            else 
                questionCard model question
        Nothing -> 
            questionCard model question

questionCard : Model -> Question -> Html Msg
questionCard model question =
    Card.view
        [ Elevation.e2
        , Tooltip.attach Mdl [ question.id ]
        , css "width" "600px"
        , css "height" "192px"
        ]
        [ Card.title
            [ css "min-height" "10px"
            , css "padding" "0"
            , Options.css "align-items" "center"

            -- Clear default padding to encompass scrim
            , Color.background <| Color.color Color.Blue Color.S900
            ]
            [ Card.head
                [ white
                , Options.scrim 0.75
                , css "padding" "16px"
                , css "align-items" "center"

                -- Restore default padding inside scrim
                , css "width" "100%"
                , Tooltip.attach Mdl [ (negate question.id) ]
                ]
                [ text (toString question.votesNumber) ]
            ]
        , Card.text []
            [ text question.text ]
        , Card.actions
            [ Card.border ]
            [ Button.render Mdl
                [ 1, 0 ]
                model.mdl
                [ Button.ripple, Button.accent ]
                --Add message to set expanded card here ]
                [ text "Show Replies" ]
            ]
        , Card.menu []
            [ Button.render Mdl
                [ 0, 0 ]
                model.mdl
                [ Button.icon, Button.ripple, white, Tooltip.attach Mdl [ (negate question.id) ] ]
                [ Icon.i "thumb_up" ]
            , Tooltip.render Mdl
                [ (negate question.id) ]
                model.mdl
                [ Tooltip.left
                , Tooltip.large
                ]
                [ text "Press here to upvote this question" ]
            , Button.render Mdl
                [ 0, 0 ]
                model.mdl
                [ Button.icon, Button.ripple, white, Tooltip.attach Mdl [ question.id ] ]
                [ Icon.i "message" ]
            , Tooltip.render Mdl
                [ question.id ]
                model.mdl
                [ Tooltip.left
                , Tooltip.large
                ]
                [ text "This badge shows the amount of unread replies" ]
            ]
        ]


questionInput : Model -> Html Msg
questionInput model =
    Card.view
        [ Elevation.e2 -- add dynamic
        , css "width" "400px"
        , css "height" "120px"
        ]
        [ Card.text []
            [ Textfield.render Mdl
                [ 1 ]
                model.mdl
                [ Textfield.label "Write your question"
                , Textfield.floatingLabel
                , Textfield.text_
                , Options.onInput SetQuestionTextInput
                , Textfield.value model.questionInProgress
                ]
                []
            ]
        , Card.actions
            [ Card.border ]
            [ Button.render Mdl
                [ 1, 0 ]
                model.mdl
                [ Button.ripple
                , Button.accent
                , Options.onClick SendQuestion
                ]
                [ text "Send question" ]
            ]
        ]
