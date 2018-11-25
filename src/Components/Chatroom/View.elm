module Components.Chatroom.View exposing (view, view2)

import Components.Chatroom.Model exposing (Chatroom)
import Html exposing (Html, div, h3, li, table, tbody, td, text, th, thead, tr, ul)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Messages exposing (Msg(..))
import Model exposing (Model)
import RemoteData exposing (WebData)


view : (List Chatroom) -> Html Msg
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
        [ Html.button [ onClick Messages.SendHttpRequest ]
            [ text "Get data from server" ]
        , viewChatnamesOrError model
        ]


viewChatnamesOrError : Model -> Html Msg
viewChatnamesOrError model =
    case model.errorMessage of
        Just message ->
            viewError message

        Nothing ->
            viewChatnames model.allChatrooms


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
        [ h3 [] [ text "Decode api call" ]
        , ul [] (List.map viewChatname chatnames)
        ]


viewChatname : Chatroom -> Html Msg
viewChatname chatname =
    li [] [ text (toString chatname.id) ]
