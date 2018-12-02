module Components.Frontpage.View exposing (view)

import Components.Chatroom.Model exposing (Chatroom)
import Html exposing (Html, h3, text)
import Material.Button as Button
import Material.Card as Card
import Material.Color as Color
import Material.Elevation as Elevation
import Material.Grid as Grid exposing (Device(..), cell, grid, size)
import Material.Options as Options exposing (cs, css, when)
import Material.Textfield as Textfield
import Material.Tooltip as Tooltip
import Messages exposing (Msg(..))
import Model exposing (Model)
import RemoteData
import Shared.View exposing (createErrorMessage, dynamic, viewError, white)


view : Model -> Html Msg
view model =
    grid [ Options.css "max-width" "1080px" ]
        [ cell
            [ size All 12
            , Options.css "align-items" "center"
            , Options.css "padding" "32px 32px"
            , Options.css "display" "flex"
            , Options.css "flex-direction" "column"
            ]
            [ chatroomIdInput model
            ]
        , cell
            [ size All 4
            , size Tablet 8
            , Options.css "padding" "32px 32px"
            , Options.css "align-items" "center"
            ]
            [ grid [ Grid.noSpacing ]
                [ cell
                    [ size All 4
                    , size Tablet 4
                    , size Desktop 12
                    ]
                    [ viewChatroomsOrError model
                    , Options.div
                        [ size All 1
                        , css "height" "32px"
                        ]
                        []
                    ]
                ]
            ]
        ]


viewChatroomsOrError : Model -> Html Msg
viewChatroomsOrError model =
    case model.allChatrooms of
        RemoteData.NotAsked ->
            text "No Chatrooms are requested. Feen free to press F5 or Ctrl+R / Cmd+R"

        RemoteData.Loading ->
            h3 [] [ text "Loading..." ]

        RemoteData.Success allChatrooms ->
            viewChatroomCards allChatrooms model

        RemoteData.Failure httpError ->
            viewError (createErrorMessage httpError)


viewChatroomCards : List Chatroom -> Model -> Html Msg
viewChatroomCards chatroom model =
    Html.table [] (List.map (chatroomCard model) chatroom)


chatroomCard : Model -> Chatroom -> Html Msg
chatroomCard model chatroom =
    Card.view
        [ dynamic chatroom.id model
        , css "width" "195px"
        ]
        [ Card.title
            [ css "min-height" "50px"
            , css "padding" "0"
            ]
            [ Card.head
                [ white
                , css "padding" "16px 16px"
                , css "background" "#02236A"
                , css "width" "100%"
                , Tooltip.attach Mdl [ chatroom.id ]
                ]
                [ text chatroom.name ]
            , Tooltip.render Mdl
                [ chatroom.id ]
                model.mdl
                [ Tooltip.bottom
                , Tooltip.large
                ]
                [ text "This button will load the chatroom" ]
            ]
        , Card.text []
            [ text (toString chatroom.id) ]
        , Card.actions
            [ Card.border ]
            [ Button.render Mdl
                [ 1, 0 ]
                model.mdl
                [ Button.ripple
                , Button.accent
                , Options.onClick (SendHttpRequestChatroomWithQuestions (toString chatroom.id))
                ]
                [ text "Show Chatroom" ]
            ]
        ]


chatroomIdInput : Model -> Html Msg
chatroomIdInput model =
    Card.view
        [ dynamic 0 model
        , css "width" "400px"
        ]
        [ Card.title
            [ css "min-height" "60px"
            , css "padding" "0"
            , css "align-items" "center"
            , css "background" "#02236A"

            -- Clear default padding to encompass scrim
            ]
            [ Card.head
                [ white
                , css "padding" "16px 16px"
                , css "align-items" "center"

                -- Restore default padding inside scrim
                , css "width" "100%"
                , Tooltip.attach Mdl [ 0 ]
                ]
                [ text "Enter a chatroom based on its ID" ]
            , Tooltip.render Mdl
                [ 0 ]
                model.mdl
                [ Tooltip.bottom
                , Tooltip.large
                ]
                [ text "Here you can enter a chatroom id if you want to enter a hidden chatroom" ]
            ]
        , Card.text []
            [ Textfield.render Mdl
                [ 0 ]
                model.mdl
                [ Textfield.label "Enter chatroom id"
                , Textfield.floatingLabel
                , Textfield.text_
                , Options.onInput SetChatroomTextInput
                , Textfield.value model.chatroomInProgress
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
                , Options.onClick (SendHttpRequestChatroomWithQuestions model.chatroomInProgress)
                ]
                [ text "Query chatroom" ]
            ]
        ]
