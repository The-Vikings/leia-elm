module Model exposing (ChatMessagePayload, Model, RemoteData(..), init)

import Components.Chatroom.Model exposing (Chatroom)
import Contact.Model exposing (Contact)
import ContactList.Model exposing (ContactList)
import Material
import Material.Snackbar as Snackbar
import Messages exposing (Msg(Mdl))
import Navigation
import Phoenix.Channel
import Phoenix.Socket
import RemoteData exposing (WebData)
import Routing exposing (Route(ListContactsRoute, ShowContactRoute))


type RemoteData e a
    = Failure e
    | NotRequested
    | Requesting
    | Success a


type alias Model =
    { mdl : Material.Model
    , snackbar : Snackbar.Model (Maybe Msg)
    , contact : RemoteData String Contact
    , contactList : RemoteData String ContactList
    , route : Route
    , search : String
    , messageInProgress : String
    , messages : List String
    , phxSocket : Phoenix.Socket.Socket Msg
    , chatrooms : WebData (List Chatroom)
    }


type alias ChatMessagePayload =
    { message : String
    }


initialModel : Route -> Model
initialModel route =
    { mdl = Material.model
    , snackbar = Snackbar.model
    , contact = NotRequested
    , contactList = NotRequested
    , route = ListContactsRoute
    , search = ""
    , messageInProgress = ""
    , messages = [ "Test message" ]
    , phxSocket =
        Phoenix.Socket.init "ws://localhost:80/socket/websocket"
            |> Phoenix.Socket.withDebug
            |> Phoenix.Socket.on "shout" "room:lobby" Messages.ReceiveMessage

    --           |> Phoenix.Socket.join channel
    }



{--
init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    (location 
        |> Routing.parse
        |> initialModel
    )
        ! [ Material.init Mdl ]
--}


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
            , chatrooms = RemoteData.Loading
            }
    in
    ( model, Cmd.map Messages.PhoenixMsg phxCmd )



{--
let
        channel =
            Phoenix.Channel.init "room:lobby"

        ( initSocket, phxCmd ) =
            Phoenix.Socket.init "ws://localhost:80/socket/websocket"
                |> Phoenix.Socket.withDebug
                |> Phoenix.Socket.on "shout" "room:lobby" Messages.ReceiveMessage
                |> Phoenix.Socket.join channel
    in

--}
