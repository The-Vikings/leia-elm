module View exposing (view)

import Components.Chatroom.View
import Components.PhoenixTest.View
import Dict exposing (Dict)
import Html exposing (Html, div, h1, header, section, text)
import Html.Attributes exposing (class, href, style)
import Html.Events exposing (onClick, onInput, onSubmit)
import Material.Badge as Badge
import Material.Button as Button
import Material.Color as Color
import Material.Layout as Layout
import Material.List as List
import Material.Options as Options exposing (cs, css, when)
import Material.Scheme
import Material.Snackbar as Snackbar
import Messages exposing (Msg)
import Model exposing (Model)


view : Model -> Html Msg
view model =
    Material.Scheme.topWithScheme Color.Teal Color.LightGreen <|
        Layout.render Messages.Mdl
            model.mdl
            [ Layout.fixedHeader
            , Layout.onSelectTab Messages.SelectTab
            , Layout.selectedTab model.selectedTab
            , Options.css "display" "flex !important"
            , Options.css "flex-direction" "row"
            , Options.css "align-items" "center"
            ]
            { header = [ h1 [ style [ ( "padding", "0rem" ) ] ] [ text "Leia chatroom" ] ]
            , drawer = []
            , tabs = ( [ text "All chatrooms", text "Current Chatroom" ], [ Color.background (Color.color Color.Teal Color.S400) ] )
            , main =
                [ viewBody model
                ]
            }



{--
viewHeader : Model -> Html Msg
viewHeader model =
    Layout.row
        [ Color.background <| Color.color Color.Green Color.S100
        , Color.text <| Color.color Color.Orange Color.S900
        ]
        [ Layout.title [] [ text "Chatroom message system demonstration" ]
        , Layout.spacer
        , Layout.navigation []
            []
        ]
--}

viewBody : Model -> Html Msg
viewBody model =
    case model.selectedTab of
        0 ->
            phoenixtest model

        1 ->
            view2 model

        _ ->
            text "404"



phoenixtest : Model -> Html Msg
phoenixtest model =
    Components.PhoenixTest.View.view model


page : Model -> Html Msg
page model =
    Components.Chatroom.View.view model


view2 : Model -> Html Msg
view2 model =
    Components.Chatroom.View.view2 model


styles : String
styles =
    """
   .demo-options .mdl-checkbox__box-outline {
      border-color: rgba(255, 255, 255, 0.89);
    }
   .mdl-layout__drawer {
      border: none !important;
   }
   .mdl-layout__drawer .mdl-navigation__link:hover {
      background-color: #00BCD4 !important;
      color: #37474F !important;
    }
   """
