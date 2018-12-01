module Shared.View exposing (backToHomeLink, createErrorMessage, dynamic, viewError, warningMessage, white)

import Html exposing (Html, a, div, h4, i, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import Material.Color as Color
import Material.Elevation as Elevation
import Material.Options as Options exposing (cs, css, when)
import Messages exposing (Msg(..))
import Model exposing (Model)
import Routing exposing (Route(ListContactsRoute))


warningMessage : String -> String -> Html Msg -> Html Msg
warningMessage iconClasses message content =
    div [ class "warning" ]
        [ span [ class "fa-stack" ]
            [ i [ class iconClasses ] [] ]
        , h4 []
            [ text message ]
        , content
        ]


backToHomeLink : Html Msg
backToHomeLink =
    a [ onClick (NavigateTo ListContactsRoute) ]
        [ text "←  Back to contact list" ]


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


viewError : String -> Html Msg
viewError errorMessage =
    let
        errorHeading =
            "Couldn't fetch chatnames at this time."
    in
    Html.div []
        [ Html.h3 [] [ text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]


white : Options.Property c m
white =
    Color.text Color.white


dynamic : Int -> Model -> Options.Style Msg
dynamic k model =
    [ if model.raised == k then
        Elevation.e8

      else
        Elevation.e2
    , Elevation.transition 250
    , Options.onMouseEnter (Raise k)
    , Options.onMouseLeave (Raise -1)
    ]
        |> Options.many
