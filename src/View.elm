module View exposing (view)

import Components.Chatroom.View
import Components.PhoenixTest.View
import Html exposing (Html, div, h1, header, section, text)
import Material.Button as Button
import Material.Color as Color
import Material.Layout as Layout
import Material.Options as Options exposing (cs, css, when)
import Material.Scheme
import Material.Snackbar as Snackbar
import Messages exposing (Msg)
import Model exposing (Model)


view : Model -> Html Msg
view model =
    Material.Scheme.top <|
        Layout.render Messages.Mdl
            model.mdl
            [ Layout.fixedHeader
            , Layout.fixedDrawer
            , Options.css "display" "flex !important"
            , Options.css "flex-direction" "row"
            , Options.css "align-items" "center"
            ]
            { header = []
            , drawer = []
            , tabs = ( [], [] )
            , main =
                [ viewHeader model
                , Snackbar.view model.snackbar |> Html.map Messages.Snackbar
                , viewSource model
                , Html.div []
                    [ Html.ul []
                        [ Html.li []
                            [ phoenixtest model
                            ]
                        ]
                    ]
                , Html.div []
                    [ page model ]
                ]
            }


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


viewSource : Model -> Html Msg
viewSource model =
    Button.render Messages.Mdl
        [ 5, 6, 6, 7 ]
        model.mdl
        [ css "position" "fixed"
        , css "display" "block"
        , css "left" "10"
        , css "bottom" "0"
        , css "margin-left" "0px"
        , css "margin-bottom" "40px"
        , css "z-index" "900"
        , Color.text Color.white
        , Button.ripple
        , Button.colored
        , Button.raised
        ]
        [ text "View Source" ]


phoenixtest : Model -> Html Msg
phoenixtest model =
    Components.PhoenixTest.View.view model


page : Model -> Html Msg
page model =
    Components.Chatroom.View.view model.chatrooms


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
