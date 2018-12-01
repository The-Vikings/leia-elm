module Update exposing (update, urlUpdate)

import Components.Chatroom.Commands as ChatroomCommands
import Contact.Update
import ContactList.Update
import Dict
import Json.Decode as JsDecode exposing (Decoder, decodeString, field, int, list, map, map2, map3, map5, string)
import Json.Encode as JsEncode
import Material
import Material.Snackbar as Snackbar
import Messages exposing (Msg(..))
import Model exposing (Model, RemoteData(Failure, NotRequested, Requesting, Success))
import Navigation
import Phoenix.Push
import Phoenix.Socket
import Ports
import RemoteData
import Routing
    exposing
        ( Route(ChatroomRoute, FrontpageRoute, ListContactsRoute, ShowContactRoute)
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdl msg ->
            Material.update Mdl msg model

        SelectTab num ->
            { model | selectedTab = num } ! []

        Snackbar msg ->
            let
                ( snackbar, snackCmd ) =
                    Snackbar.update msg model.snackbar
            in
            { model | snackbar = snackbar } ! [ Cmd.map Snackbar snackCmd ]

        ContactMsg contactMsg ->
            Contact.Update.update contactMsg model

        ContactListMsg contactListMsg ->
            ContactList.Update.update contactListMsg model

        NavigateTo route ->
            ( model, Cmd.batch [ Navigation.newUrl (Routing.forRoute route), Ports.setTitle (Routing.forRoute route) ] )

        UpdateSearchQuery value ->
            ( { model | search = value }, Cmd.none )

        OnLocationChange location ->
            let
                currentRoute =
                    Routing.parse location
            in
            urlUpdate { model | route = currentRoute }

        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
            ( { model | phxSocket = phxSocket }
            , Cmd.map PhoenixMsg phxCmd
            )

        SetChatroomTextInput message ->
            ( { model | chatroomInProgress = message }, Cmd.none )

        SetQuestionTextInput message ->
            ( { model | questionInProgress = message }, Cmd.none )

        SetReplyTextInput message ->
            ( { model | replyInProgress = message }, Cmd.none )

        SendQuestion ->
            let
                payload =
                    JsEncode.object
                        [ ( "body", JsEncode.string model.questionInProgress )
                        ]

                phxPush =
                    Phoenix.Push.init "newQuestion" "room:lobby"
                        |> Phoenix.Push.withPayload payload
                        |> Phoenix.Push.onOk ReceiveMessage
                        |> Phoenix.Push.onError HandleSendError

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.push phxPush model.phxSocket
            in
            ( { model
                | phxSocket = phxSocket
                , questionInProgress = ""
              }
            , Cmd.map PhoenixMsg phxCmd
            )

        SendReply ->
            let
                payload =
                    JsEncode.object
                        [ ( "body", JsEncode.string model.replyInProgress )
                        ]

                phxPush =
                    Phoenix.Push.init "newReply" "room:lobby"
                        |> Phoenix.Push.withPayload payload
                        |> Phoenix.Push.onOk ReceiveMessage
                        |> Phoenix.Push.onError HandleSendError

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.push phxPush model.phxSocket
            in
            ( { model
                | phxSocket = phxSocket
                , replyInProgress = ""
              }
            , Cmd.map PhoenixMsg phxCmd
            )

        ReceiveMessage raw ->
            let
                messageDecoder =
                    JsDecode.field "message" JsDecode.string

                somePayload =
                    JsDecode.decodeValue messageDecoder raw
            in
            case somePayload of
                Ok payload ->
                    ( { model | messages = payload :: model.messages }
                    , Cmd.none
                    )

                Err error ->
                    ( model, Cmd.none )

        HandleSendError _ ->
            let
                message =
                    "Failed to Send Message"
            in
            ( { model | messages = message :: model.messages }, Cmd.none )

        SendHttpRequestAllChatrooms ->
            ( { model | allChatrooms = RemoteData.Loading }, ChatroomCommands.fetchAllChatrooms )

        SendHttpRequestChatroomWithQuestions input ->
            ( { model | chatroom = RemoteData.Loading, selectedTab = 1 }, ChatroomCommands.fetchChatroomWithQuestions input )

        FetchAllChatrooms chatroomsPayload ->
            ( { model | allChatrooms = chatroomsPayload }, Cmd.none )

        FetchChatroomWithQuestions chatroomPayload ->
            ( { model | chatroom = chatroomPayload }, Cmd.none )

        Toggle index ->
            let
                toggles =
                    case Dict.get index model.toggles of
                        Just v ->
                            Dict.insert index (not v) model.toggles

                        Nothing ->
                            Dict.insert index True model.toggles
            in
            { model | toggles = toggles } ! []

        Raise k ->
            { model | raised = k } ! []


urlUpdate : Model -> ( Model, Cmd Msg )
urlUpdate model =
    case model.route of
        FrontpageRoute ->
            case model.allChatrooms of
                RemoteData.NotAsked ->
                    ( model, ChatroomCommands.fetchAllChatrooms )

                _ ->
                    ( model, Cmd.none )

        ChatroomRoute id ->
            ( { model | chatroom = RemoteData.Loading }
            , ChatroomCommands.fetchChatroomWithQuestions id
            )

        _ ->
            ( model, Cmd.none )
