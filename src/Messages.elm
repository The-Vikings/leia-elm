module Messages exposing (Msg(..))

import Contact.Messages exposing (ContactMsg)
import ContactList.Messages exposing (ContactListMsg)
import Json.Encode as JsEncode
import Material
import Material.Snackbar as Snackbar
import Navigation
import Phoenix.Socket
import Routing exposing (Route)


type Msg
    = Mdl (Material.Msg Msg)
    | Snackbar (Snackbar.Msg (Maybe Msg))
    | ContactMsg ContactMsg
    | ContactListMsg ContactListMsg
    | NavigateTo Route
    | UpdateSearchQuery String
    | UrlChange Navigation.Location
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | SetMessage String
    | SendMessage
    | ReceiveMessage JsEncode.Value
    | HandleSendError JsEncode.Value
