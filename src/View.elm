module View exposing (view)

import Components.Chatroom.View
import Components.Frontpage.View
import Components.PhoenixTest.View
import Html exposing (Html, div, h1, header, section, text)
import Html.Attributes exposing (class, href, style)
import Material.Color as Color
import Material.Dialog as Dialog
import Material.Icon as Icon
import Material.Layout as Layout
import Material.Menu as Menu
import Material.Options as Options exposing (cs, css, when)
import Material.Scheme
import Messages exposing (Msg(..))
import Model exposing (Model)
import Routing exposing (Route(..))


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
            , drawer = [ drawerHeader model, viewDrawer model ]
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


viewDrawer : Model -> Html Msg
viewDrawer model =
    Layout.navigation
        [ Color.background <| Color.color Color.BlueGrey Color.S800
        , Color.text <| Color.color Color.BlueGrey Color.S50
        , Options.css "flex-grow" "1"
        ]
    <|
        List.map (viewDrawerMenuItem model) menuItems
            ++ [ Layout.spacer
               , Layout.link
                    [ Dialog.openOn "click"
                    ]
                    [ Icon.view "help"
                        [ Color.text <| Color.color Color.BlueGrey Color.S500
                        ]
                    ]
               ]


drawerHeader : Model -> Html Msg
drawerHeader model =
    Options.styled Html.header
        [ css "display" "flex"
        , css "box-sizing" "border-box"
        , css "justify-content" "flex-end"
        , css "padding" "16px"
        , css "height" "151px"
        , css "flex-direction" "column"
        , cs "demo-header"
        , Color.background <| Color.color Color.BlueGrey Color.S900
        , Color.text <| Color.color Color.BlueGrey Color.S50
        ]
        [ Options.styled Html.img
            [ Options.attribute <| Html.Attributes.src "https://cdn-images-1.medium.com/max/1600/1*PulJgoDtSE5eWBAjaLO6Wg.png"
            , css "width" "48px"
            , css "height" "48px"
            , css "border-radius" "24px"
            ]
            []
        , Options.styled Html.div
            [ css "display" "flex"
            , css "flex-direction" "row"
            , css "align-items" "center"
            , css "width" "100%"
            , css "position" "relative"
            ]
            [ Html.span [] []
            , Layout.spacer
            , Menu.render Mdl
                [ 1, 2, 3, 4 ]
                model.mdl
                [ Menu.ripple
                , Menu.bottomRight
                , Menu.icon "arrow_drop_down"
                ]
                [ Menu.item
                    []
                    [ text "Professor" ]
                , Menu.item
                    []
                    [ text "Student" ]
                , Menu.item
                    []
                    [ text "Sysadmin" ]
                ]
            ]
        ]


type alias MenuItem =
    { text : String
    , iconName : String
    , route : Maybe Route
    }


menuItems : List MenuItem
menuItems =
    [ { text = "Dashboard", iconName = "dashboard", route = Just FrontpageRoute }
    , { text = "Users", iconName = "group", route = Just (ChatroomRoute "0") }
    , { text = "Last Activity", iconName = "alarm", route = Nothing }
    , { text = "Reports", iconName = "list", route = Nothing }
    , { text = "Chatrooms", iconName = "store", route = Nothing }
    , { text = "Settings", iconName = "settings", route = Nothing }
    ]


viewDrawerMenuItem : Model -> MenuItem -> Html Msg
viewDrawerMenuItem model menuItem =
    Layout.link
        [ Color.background <| Color.color Color.BlueGrey Color.S600
        , Options.css "color" "rgba(255, 255, 255, 0.56)"
        , Options.css "font-weight" "500"
        ]
        [ Icon.view menuItem.iconName
            [ Color.text <| Color.color Color.BlueGrey Color.S500
            , Options.css "margin-right" "32px"
            ]
        , text menuItem.text
        ]
