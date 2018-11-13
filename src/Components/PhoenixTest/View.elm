module Components.PhoenixTest.View exposing (..)

import Model exposing(Model)
import Messages exposing (Msg)
import Html exposing (Html)
import Html.Events exposing (onInput, onSubmit)


view : Model -> Html Msg
view model =
    let
        drawMessages messages =
            messages |> List.map drawMessage
    in
    Html.div []
        [ Html.ul [] (model.messages |> drawMessages)
        , Html.form [ onSubmit Messages.SendMessage ]
            [ Html.input [ onInput Messages.SetMessage ] 
                []
            , Html.button []
                [ Html.text "Submit"
                ]
            ]
        ]


drawMessage : String -> Html Msg
drawMessage message =
    Html.li []
        [ Html.text message
        ]