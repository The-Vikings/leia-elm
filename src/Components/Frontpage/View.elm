module Components.Frontpage.View exposing (view)

import Components.Chatroom.Model exposing (Chatroom)
import Html exposing (Html, h3, text)
import Material.Button as Button
import Material.Card as Card
import Material.Color as Color
import Material.Elevation as Elevation
import Material.Grid as Grid exposing (Device(..), cell, grid, size)
import Material.Options as Options exposing (cs, css, when)
import Material.Tooltip as Tooltip
import Messages exposing (Msg(..))
import Model exposing (Model)
import RemoteData
import Shared.View exposing (createErrorMessage, dynamic, viewError, white)


view : Model -> Html Msg
view model =
    grid [ Options.css "max-width" "1080px" ]
        [ cell
            [ size All 4
            , size Tablet 8
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
            text ""

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
        [ Elevation.e2
        , Tooltip.attach Mdl [ chatroom.id ]
        , css "width" "100%"
        ]
        [ Card.title
            [ css "min-height" "50px"
            , css "padding" "0"

            -- Clear default padding to encompass scrim
            , Color.background <| Color.color Color.Blue Color.S900
            ]
            [ Card.head
                [ white
                , Options.scrim 0.75
                , css "padding" "16px"

                -- Restore default padding inside scrim
                , css "width" "100%"
                ]
                [ text chatroom.name ]
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
                , Tooltip.attach Mdl [ chatroom.id ]
                ]
                [ text "Show Chatroom" ]
            , Tooltip.render Mdl
                [ chatroom.id ]
                model.mdl
                [ Tooltip.top
                , Tooltip.large
                ]
                [ text "This button will load the chatroom" ]
            ]
        ]
