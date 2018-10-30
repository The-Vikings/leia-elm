module Main exposing (main)

import Messages exposing (Msg(..))
import Model exposing (Model)
import Navigation
import Update
import View


main : Program Never Model Msg
main =
    Navigation.program
        UrlChange
        { init = Model.init
        , view = View.view
        , update = Update.update
        , subscriptions = \_ -> Sub.none
        }


