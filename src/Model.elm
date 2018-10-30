module Model exposing (Model, RemoteData(..), initialModel)

import Contact.Model exposing (Contact)
import ContactList.Model exposing (ContactList)
import Material
import Material.Snackbar as Snackbar
import Messages exposing (Msg(Mdl))


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
    }


initialModel : Route -> Model
initialModel route =
    { mdl = Material.model
    , snackbar = Snackbar.model
    , contact = NotRequested
    , contactList = NotRequested
    , route = route
    , search = ""
    }
