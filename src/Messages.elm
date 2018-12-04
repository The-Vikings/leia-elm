module Messages exposing (Msg(..))

import Components.Chatroom.Messages exposing (ChatroomMsg)
import Components.Chatroom.Model exposing (Chatroom)
import Contact.Messages exposing (ContactMsg)
import ContactList.Messages exposing (ContactListMsg)
import Json.Encode as JsEncode
import Material
import Material.Snackbar as Snackbar
import Navigation
import Phoenix.Socket
import RemoteData exposing (WebData)
import Routing exposing (Route)


type Msg
    = Mdl (Material.Msg Msg)
    | Snackbar (Snackbar.Msg Int)
    | AddToast String
    | Appear Int
    | Grown Int 
    | Gone Int 
    | ContactMsg ContactMsg
    | ContactListMsg ContactListMsg
    | NavigateTo Route
    | UpdateSearchQuery String
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | SetChatroomTextInput String
    | SetQuestionTextInput String
    | SetReplyTextInput String
    | SendQuestion
    | SendReply Int
    | ReceiveQuestion JsEncode.Value
    | ReceiveUserAnswer JsEncode.Value
    | ReceiveAutomaticAnswer JsEncode.Value
    | HandleSendError JsEncode.Value
    | OnLocationChange Navigation.Location
    | FetchChatroomWithQuestions (WebData Chatroom)
    | FetchAllChatrooms (WebData (List Chatroom))
    | SendHttpRequestAllChatrooms
    | SendHttpRequestChatroomWithQuestions String
    | SelectTab Int
    | Toggle (List Int)
    | Raise Int
    | ExpandQuestion (Maybe Int)
