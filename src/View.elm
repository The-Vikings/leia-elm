module View exposing (view)

import Components.Chatroom.View
import Components.Frontpage.View
import Components.PhoenixTest.View
import Html exposing (Html, div, h1, header, section, text)
import Html.Attributes exposing (class, href, style)
import Material.Color as Color
import Material.Layout as Layout
import Material.Options as Options exposing (cs, css, when)
import Material.Scheme
import Messages exposing (Msg)
import Model exposing (Model)


view : Model -> Html Msg
view model =
    Material.Scheme.topWithScheme Color.Indigo Color.Blue <|
        Layout.render Messages.Mdl
            model.mdl
            [ Layout.fixedHeader
            , Layout.waterfall True
            , Layout.onSelectTab Messages.SelectTab
            , Layout.selectedTab model.selectedTab
            , Options.css "display" "flex !important"
            , Options.css "flex-direction" "row"
            , Options.css "align-items" "center"
            ]
            { header = [ h1 [ style [ ( "padding", "0rem" ) ] ] [] ]
            , drawer = []
            , tabs = ( [ text "All chatrooms", text "Current Chatroom" ], [ Color.background (Color.color Color.Blue Color.S800) ] )
            , main =
                [ viewBody model
                ]
            }


viewBody : Model -> Html Msg
viewBody model =
    case model.selectedTab of
        0 ->
            frontpage model

        1 ->
            currentChatroom model

        _ ->
            text "404"


frontpage : Model -> Html Msg
frontpage model =
    Components.Frontpage.View.view model


phoenixtest : Model -> Html Msg
phoenixtest model =
    Components.PhoenixTest.View.view model


currentChatroom : Model -> Html Msg
currentChatroom model =
    Components.Chatroom.View.view model
