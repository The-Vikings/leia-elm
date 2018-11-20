module Components.Question.view exposing (view)

import Components.Question.Model exposing (Question)
import Html exposing (Html, div, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class)
import Messages exposing (Msg)
import RemoteData exposing (WebData)


view : WebData (List Question) -> Html Msg
view response =
    div []
        [ nav
        , maybeList response
        ]

nav : Html Msg
nav =
    div [ class "clearfix mb2 white bg-black" ]
        [ div [ class "left p2" ] [ text "Questions" ] ]


maybeList : WebData (List Question) -> Html Msg
maybeList response =
    case response of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success questions ->
            list questions

        RemoteData.Failure error ->
            text (toString error)


list : List Question -> Html Msg
list questions =
    div [ class "p2" ]
        [ table []
            [ thead []
                [ tr []
                    [ th [] [ text "Id" ]
                    , th [] [ text "Name" ]
                    , th [] [ text "Actions" ]
                    ]
                ]
            , tbody [] (List.map questionRow questions)
            ]
        ]


questionRow : Question -> Html Msg
questionRow question =
    tr []
        [ td [] [ text question.id ]
        , td [] [ text question.name ]
        , td []
            []
        ]