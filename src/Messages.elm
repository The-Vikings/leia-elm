module Messages exposing (Msg(..))

import Contact.Messages exposing (ContactMsg)
import ContactList.Messages exposing (ContactListMsg)
import Json.Encode as JsEncode
import Material
import Material.Snackbar as Snackbar
import Navigation
import Phoenix.Socket
import RemoteData exposing (WebData)
import Routing exposing (Route)
import Components.Chatroom.Model exposing (Chatroom)


type Msg
    = Mdl (Material.Msg Msg)
    | Snackbar (Snackbar.Msg (Maybe Msg))
    | ContactMsg ContactMsg
    | ContactListMsg ContactListMsg
    | NavigateTo Route
    | UpdateSearchQuery String
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | SetMessage String
    | SendMessage
    | ReceiveMessage JsEncode.Value
    | HandleSendError JsEncode.Value
    | OnFetchChatrooms (WebData (List Chatroom))
    | OnLocationChange Navigation.Location
    
