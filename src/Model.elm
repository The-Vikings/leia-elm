module Model exposing (ChatMessagePayload, Model, RemoteData(..), init)

import Components.Chatroom.Commands exposing (fetchAllChatrooms)
import Components.Chatroom.Model exposing (Chatroom)
import Components.Question.Model exposing (Question)
import Contact.Model exposing (Contact)
import ContactList.Model exposing (ContactList)
import Material
import Material.Layout as Layout
import Material.Snackbar as Snackbar
import Messages exposing (Msg(Mdl))
import Navigation
import Phoenix.Channel
import Phoenix.Socket
import RemoteData exposing (WebData)
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
    , chatroom : WebData Chatroom
    , allChatrooms : WebData (List Chatroom)
    , questionsWithAnswers : WebData (List Question)
    , selectedTab : Int
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
            , chatroom = RemoteData.NotAsked
            , allChatrooms = RemoteData.NotAsked
            , questionsWithAnswers = RemoteData.NotAsked
            , selectedTab = 0
            }
    in
    ( { model | mdl = Layout.setTabsWidth 1384 model.mdl }, Cmd.batch [ Cmd.map Messages.PhoenixMsg phxCmd, fetchAllChatrooms, Layout.sub0 Mdl ] )
