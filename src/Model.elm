module Model exposing (Model, RemoteData(..), init, initialModel)

import Contact.Commands
import ContactList.Commands
import Navigation
import Routing exposing (Route(ListContactsRoute, ShowContactRoute))
import Contact.Model exposing (Contact)
import ContactList.Model exposing (ContactList)
import Material
import Material.Snackbar as Snackbar
import Messages exposing (Msg(Mdl))

import Phoenix.Socket

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
    }


initialModel : Route -> Model
initialModel route =
    { mdl = Material.model
    , snackbar = Snackbar.model
    , contact = NotRequested
    , contactList = NotRequested
    , route = route
    , search = ""
    , messageInProgress = ""
    , messages = [ "Test message" ]
    , phxSocket = Phoenix.Socket.init "ws://localhost:80/socket/websocket" |> Phoenix.Socket.withDebug |> Phoenix.Socket.on "shout" "room:lobby" Messages.ReceiveMessage
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    (location
        |> Routing.parse
        |> initialModel
    )
        ! [ Material.init Mdl ]