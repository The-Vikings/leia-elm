module Messages exposing (Msg(..))

import Components.Chatroom.Messages exposing (ChatroomMsg)
import Components.Chatroom.Model exposing (Chatroom, ChatroomPayload)
import Components.Question.Model exposing (Question)
import Contact.Messages exposing (ContactMsg)
import ContactList.Messages exposing (ContactListMsg)
import Json.Encode as JsEncode
import Material
import Material.Snackbar as Snackbar
import Navigation
import Phoenix.Socket
import RemoteData exposing (WebData)
import Routing exposing (Route)
import Http


type Msg
    = Mdl (Material.Msg Msg)
    | Snackbar (Snackbar.Msg (Maybe Msg))
    | ContactMsg ContactMsg
    | ContactListMsg ContactListMsg
    | ChatroomMsg ChatroomMsg
    | NavigateTo Route
    | UpdateSearchQuery String
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | SetMessage String
    | SendMessage
    | ReceiveMessage JsEncode.Value
    | HandleSendError JsEncode.Value
    | OnFetchChatrooms (WebData (List Chatroom))  -- fjernes, logikk flyttes til "chatroom"
    | OnLocationChange Navigation.Location
    | OnFetchQuestionsWithAnswers (WebData (List Question))
    | FetchChatroom (Result Http.Error Chatroom)
    | FetchAllChatrooms (Result Http.Error (ChatroomPayload))
    | SendHttpRequest