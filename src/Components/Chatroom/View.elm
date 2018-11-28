module Components.Chatroom.View exposing (view, view2)

import Components.Chatroom.Commands exposing (..)
import Components.Chatroom.Model exposing (Chatroom)
import Html exposing (Html, div, h3, li, table, tbody, td, text, th, thead, tr, ul)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import Material.Card as Card
import Material.Color as Color
import Material.Options as Options exposing (cs, css, when)
import Messages exposing (Msg(..))
import Model exposing (Model)
import RemoteData


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
        [ Html.button [ onClick (Messages.SendHttpRequestAllChatrooms) ]
            [ text "Get allChatrooms data from server" ]
        , Html.button [ onClick (Messages.SendHttpRequestChatroomWithQuestions "170" ) ]
            [ text "Get chatroomWithQuestions from server" ]
        , viewChatnameOrError model
        , viewChatnamesOrError model

        --       , viewCard model.mdl
        ]


viewChatnameOrError : Model -> Html Msg
viewChatnameOrError model =
    case model.chatroom of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            h3 [] [ text "Loading..." ]

        RemoteData.Success allChatrooms ->
            viewChatname allChatrooms

        RemoteData.Failure httpError ->
            viewError (createErrorMessage httpError)



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
        [ h3 [] [ text "Verify functionality" ]
        , table []
            ([ viewTableHeader ] ++ List.map viewChatname chatnames)
        ]


viewTableHeader : Html Msg
viewTableHeader =
    Html.div []
        [ Html.ul []
            [ tr []
                [ th []
                    [ text "ID" ]
                , th []
                    [ text "Name" ]
                ]
            ]
        ]


viewChatname : Chatroom -> Html Msg
viewChatname chatname =
    Html.div []
        [ Html.ul []
            [ tr []
                [ td []
                    [ text (toString chatname.id) ]
                , td []
                    [ text chatname.name ]
                ]
            ]
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



-- Mdl helper methods


white : Options.Property c m
white =
    Color.text Color.white



{--
viewCard : Model -> Html Msg
viewCard model = 
    Card.view
        [ css "height" "128px"
        , css "width" "128px"
        , Color.background (Color.color Color.Brown Color.S500)
        -- Elevation
        , if model.raised == k then Elevation.e8 else Elevation.e2
        , Elevation.transition 250
        , Options.onMouseEnter (Raise k)
        , Options.onMouseLeave (Raise -1)
        ]
        [ Card.title [] [ Card.head [ white ] [ text "Hover here" ] ] ]
--}
