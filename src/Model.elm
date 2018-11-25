module Model exposing (ChatMessagePayload, Model, RemoteData(..), init)

import Components.Chatroom.Commands exposing (fetchAllChatrooms)
import Components.Chatroom.Model exposing (Chatroom)
import Components.Question.Model exposing (Question)
import Contact.Model exposing (Contact)
import ContactList.Model exposing (ContactList)
import Material
import Material.Snackbar as Snackbar
import Messages exposing (Msg(Mdl))
import Navigation
import Phoenix.Channel
import Phoenix.Socket
import RemoteData exposing (WebData, RemoteData)
import Routing


type RemoteData error value
    = Failure error
    | NotRequested
    | Requesting
    | Success value


type alias Model =
    { mdl : Material.Model
    , snackbar : Snackbar.Model (Maybe Msg)
    , contact : RemoteData String Contact
    , contactList : RemoteData String ContactList
    , route : Routing.Route
    , search : String
    , messageInProgress : String
    , messages : List String
    , phxSocket : Phoenix.Socket.Socket Msg
    , chatroom : RemoteData String Chatroom
    , allChatrooms : List Chatroom
    , errorMessage : Maybe String
    , questionsWithAnswers : WebData (List Question)
    }


type alias ChatMessagePayload =
    { message : String
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        channel =
            Phoenix.Channel.init "room:lobby"

        ( initSocket, phxCmd ) =
            Phoenix.Socket.init "ws://localhost:80/socket/websocket"
                |> Phoenix.Socket.withDebug
                |> Phoenix.Socket.on "shout" "room:lobby" Messages.ReceiveMessage
                |> Phoenix.Socket.join channel

        model =
            { phxSocket = initSocket
            , messageInProgress = ""
            , messages = [ "Test message", "test message 2" ]
            , mdl = Material.model
            , snackbar = Snackbar.model
            , contact = NotRequested
            , contactList = NotRequested
            , route = location |> Routing.parse
            , search = ""
            , chatroom = NotRequested
            , allChatrooms = []
            , errorMessage = Nothing
            , questionsWithAnswers = RemoteData.NotAsked
            }
    in
    ( model, Cmd.batch [ Cmd.map Messages.PhoenixMsg phxCmd, fetchAllChatrooms ] )
