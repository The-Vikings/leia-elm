module Model exposing (ChatMessagePayload, Model, RemoteData(..), init)

import Components.Chatroom.Commands exposing (fetchAllChatrooms, fetchChatroomWithQuestions)
import Components.Chatroom.Model exposing (Chatroom)
import Components.Question.Model exposing (Question, QuestionId)
import Contact.Model exposing (Contact)
import ContactList.Model exposing (ContactList)
import Dict exposing (Dict)
import Material
import Material.Layout as Layout
import Material.Snackbar as Snackbar
import Messages exposing (Msg(Mdl))
import Navigation
import Phoenix.Channel
import Phoenix.Socket
import Ports
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
    , notificationsEnabled : Bool
    , contact : RemoteData String Contact
    , contactList : RemoteData String ContactList
    , route : Routing.Route
    , search : String
    , chatroomInProgress : String
    , questionInProgress : String
    , replyInProgress : String
    , messages : List String
    , phxSocket : Phoenix.Socket.Socket Msg
    , chatroom : WebData Chatroom
    , allChatrooms : WebData (List Chatroom)
    , questionsWithAnswers : WebData (List Question)
    , selectedTab : Int
    , toggles : Dict (List Int) Bool
    , raised : Int
    , expandedQuestion : Maybe QuestionId
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
                |> Phoenix.Socket.on "newQuestion" "room:lobby" Messages.ReceiveQuestion
                |> Phoenix.Socket.on "newReply" "room:lobby" Messages.ReceiveUserAnswer
                |> Phoenix.Socket.on "newAutoAnswer" "room:lobby" Messages.ReceiveAutomaticAnswer
                |> Phoenix.Socket.join channel

        model =
            { phxSocket = initSocket
            , chatroomInProgress = ""
            , questionInProgress = ""
            , replyInProgress = ""
            , messages = [ "Test message", "test message 2" ]
            , mdl = Material.model
            , snackbar = Snackbar.model
            , notificationsEnabled = True
            , contact = NotRequested
            , contactList = NotRequested
            , route = location |> Routing.parse
            , search = ""
            , chatroom = RemoteData.NotAsked
            , allChatrooms = RemoteData.NotAsked
            , questionsWithAnswers = RemoteData.NotAsked
            , selectedTab = 0
            , toggles = Dict.empty
            , raised = -1
            , expandedQuestion = Nothing
            }
    in
    ( { model | mdl = Layout.setTabsWidth 1384 model.mdl }, Cmd.batch [ Cmd.map Messages.PhoenixMsg phxCmd, fetchAllChatrooms, Layout.sub0 Mdl, Ports.setTitle (Routing.forRoute (location |> Routing.parse)) ] )
