module Components.Chatroom.View exposing (view, view2)

import Components.Chatroom.Commands exposing (..)
import Components.Chatroom.Model exposing (Chatroom)
import Html exposing (Html, div, h3, li, table, tbody, td, text, th, thead, tr, ul)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Messages exposing (Msg(..))
import Model exposing (Model)
import RemoteData
import Http


view : Model -> Html Msg
view response =
    div []
        [ nav
        ]


nav : Html Msg
nav =
    div [ class "clearfix mb2 white bg-black" ]
        [ div [ class "left p2" ] [ text "Chatrooms" ] ]


view2 : Model -> Html Msg
view2 model =
    div []
        [ Html.button [ onClick Messages.SendHttpRequestAllChatrooms ]
            [ text "Get data from server" ]
        , viewChatnamesOrError model
        , text (toString fetchAllChatrooms)
        , text (toString (fetchChatroomWithQuestions "1"))
        ]


viewChatnamesOrError : Model -> Html Msg
viewChatnamesOrError model =
    case model.allChatrooms of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            h3 [] [ text "Loading..." ]

        RemoteData.Success allChatrooms ->
            viewChatnames allChatrooms

        RemoteData.Failure httpError ->
            viewError (createErrorMessage httpError)

viewError : String -> Html Msg
viewError errorMessage =
    let
        errorHeading =
            "Couldn't fetch chatnames at this time."
    in
    div []
        [ h3 [] [ text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]


viewChatnames : List Chatroom -> Html Msg
viewChatnames chatnames =
    div []
        [ h3 [] [ text "Chatnames" ]
        , table []
            ([ viewTableHeader ] ++ List.map viewChatname chatnames)
        ]

viewTableHeader : Html Msg
viewTableHeader =
    tr []
        [ th []
            [ text "ID" ]
        , th []
            [ text "Name" ]
        ]

viewChatname : Chatroom -> Html Msg
viewChatname chatname =
    tr []
        [ td []
            [ text (toString chatname.id) ]
        , td []
            [ text chatname.name ]
        ]

createErrorMessage : Http.Error -> String
createErrorMessage httpError =
    case httpError of
        Http.BadUrl message ->
            message

        Http.Timeout ->
            "Server is taking too long to respond. Please try again later."

        Http.NetworkError ->
            "It appears you don't have an Internet connection right now."

        Http.BadStatus response ->
            response.status.message

        Http.BadPayload message response ->
            message