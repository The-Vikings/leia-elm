module Subscriptions exposing (subscriptions)

import Material
import Messages exposing (Msg(..))
import Model exposing (Model)
import Phoenix.Socket


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Material.subscriptions Mdl model
        , Phoenix.Socket.listen model.phxSocket PhoenixMsg
        ]
