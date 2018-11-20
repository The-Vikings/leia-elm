module Components.Chatroom.View exposing (view)

import Components.Chatroom.Model exposing (Chatroom)
import Html exposing (Html, div, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class)
import Messages exposing (Msg)
import RemoteData exposing (WebData)


view : WebData (List Chatroom) -> Html Msg
view response =
    div []
        [ nav
        , maybeList response
        ]


nav : Html Msg
nav =
    div [ class "clearfix mb2 white bg-black" ]
        [ div [ class "left p2" ] [ text "Chatrooms" ] ]


maybeList : WebData (List Chatroom) -> Html Msg
maybeList response =
    case response of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success chatrooms ->
            list chatrooms

        RemoteData.Failure error ->
            text (toString error)


list : List Chatroom -> Html Msg
list chatrooms =
    div [ class "p2" ]
        [ table []
            [ thead []
                [ tr []
                    [ th [] [ text "Id" ]
                    ]
                ]
            , tbody [] (List.map chatroomRow chatrooms)
            ]
        ]


chatroomRow : Chatroom -> Html Msg
chatroomRow chatroom =
    tr []
        [ td [] [ text chatroom.id ]
        ]



{--
questionInput : Chatroom -> Html Msg
questionInput chatroom = 
    div
        [ ]
        --}
