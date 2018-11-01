module Update exposing (update, urlUpdate)

import Contact.Commands
import Contact.Update
import ContactList.Commands
import ContactList.Update
import Json.Decode as JsDecode
import Json.Encode as JsEncode
import Material
import Material.Snackbar as Snackbar
import Messages
    exposing
        ( Msg
            ( ContactListMsg
            , ContactMsg
            , HandleSendError
            , Mdl
            , NavigateTo
            , PhoenixMsg
            , ReceiveMessage
            , SendMessage
            , SetMessage
            , Snackbar
            , UpdateSearchQuery
            , UrlChange
            )
        )
import Model exposing (Model, RemoteData(NotRequested, Requesting))
import Navigation
import Phoenix.Push
import Phoenix.Socket
import Routing
    exposing
        ( Route(ListContactsRoute, ShowContactRoute)
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdl msg ->
            Material.update Mdl msg model

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
            ( model, Navigation.newUrl (Routing.toPath route) )

        UpdateSearchQuery value ->
            ( { model | search = value }, Cmd.none )

        UrlChange location ->
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

        SetMessage message ->
            ( { model | messageInProgress = message }, Cmd.none )

        SendMessage ->
            let
                payload =
                    JsEncode.object
                        [ ( "message", JsEncode.string model.messageInProgress )
                        ]

                phxPush =
                    Phoenix.Push.init "shout" "room:lobby"
                        |> Phoenix.Push.withPayload payload
                        |> Phoenix.Push.onOk ReceiveMessage
                        |> Phoenix.Push.onError HandleSendError

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.push phxPush model.phxSocket
            in
            ( { model
                | phxSocket = phxSocket
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


urlUpdate : Model -> ( Model, Cmd Msg )
urlUpdate model =
    case model.route of
        ListContactsRoute ->
            case model.contactList of
                NotRequested ->
                    ( model, ContactList.Commands.fetchContactList 1 "" )

                _ ->
                    ( model, Cmd.none )

        ShowContactRoute id ->
            ( { model | contact = Requesting }
            , Contact.Commands.fetchContact id
            )

        _ ->
            ( model, Cmd.none )
