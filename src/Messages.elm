module Messages exposing (Msg(..))

import Components.Chatroom.Messages exposing (ChatroomMsg)
import Components.Chatroom.Model exposing (Chatroom)
import Components.Question.Model exposing (Question)
import Contact.Messages exposing (ContactMsg)
import ContactList.Messages exposing (ContactListMsg)
import Http
import Json.Encode as JsEncode
import Material
import Material.Snackbar as Snackbar
import Navigation
import Phoenix.Socket
import RemoteData exposing (WebData)
import Routing exposing (Route)


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
    | OnLocationChange Navigation.Location
    | FetchChatroomWithQuestions (WebData Chatroom)
    | FetchAllChatrooms (WebData (List Chatroom))
    | SendHttpRequestAllChatrooms
    | SendHttpRequestChatroomWithQuestions String
    | SelectTab Int
