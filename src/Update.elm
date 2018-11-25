module Update exposing (update, urlUpdate)

import Commands exposing (chatroomsApiUrl)
import Components.Chatroom.Commands as ChatroomCommands
import Components.Chatroom.Model exposing (Chatroom, ChatroomPayload)
import Components.Chatroom.Update as ChatroomUpdate
import Components.Question.Model exposing (AutomaticAnswer, Question, UserAnswer)
import Contact.Update
import ContactList.Update
import Http
import Json.Decode as JsDecode exposing (Decoder, decodeString, field, int, list, map, map2, map3, map5, string)
import Json.Encode as JsEncode
import Material
import Material.Snackbar as Snackbar
import Messages exposing (Msg(..))
import Model exposing (Model, RemoteData(Failure, NotRequested, Requesting, Success))
import Navigation
import Phoenix.Push
import Phoenix.Socket
import Routing
    exposing
        ( Route(ChatroomRoute, FrontpageMenuRoute, ListContactsRoute, ShowContactRoute)
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

        ChatroomMsg chatroomMsg ->
            ChatroomUpdate.update chatroomMsg model

        NavigateTo route ->
            ( model, Navigation.newUrl (Routing.chatroomPath route) )

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

        OnFetchChatrooms response ->
            --        ( { model | allChatrooms = response }, Cmd.none )
            ( model, Cmd.none )

        OnFetchQuestionsWithAnswers response ->
            ( { model | questionsWithAnswers = response }, Cmd.none )

        FetchChatroom (Ok response) ->
            ( { model | chatroom = Success response }, Cmd.none )

        FetchChatroom (Err _) ->
            ( { model | chatroom = Failure "Chatroom not found" }, Cmd.none )

        SendHttpRequest ->
            ( model, httpCommand )

        FetchAllChatrooms (Ok chatroomPayload) ->
            ( { model
                | allChatrooms = chatroomPayload.data
                , errorMessage = Nothing
              }
            , Cmd.none
            )

        FetchAllChatrooms (Err httpError) ->
            ( { model
                | errorMessage = Just (createErrorMessage httpError)
              }
            , Cmd.none
            )


urlUpdate : Model -> ( Model, Cmd Msg )
urlUpdate model =
    case model.route of
        FrontpageMenuRoute ->
            case model.allChatrooms of
                [] ->
                    ( model, ChatroomCommands.fetchAllChatrooms )

                _ ->
                    ( model, Cmd.none )

        ChatroomRoute id ->
            ( { model | chatroom = Requesting }
            , ChatroomCommands.fetchChatroom id
            )

        _ ->
            ( model, Cmd.none )


createErrorMessage : Http.Error -> String
createErrorMessage httpError =
    case httpError of
        Http.BadUrl message ->
            message

        Http.Timeout ->
            "Server is taking too long to respond. Please try again later."

        Http.NetworkError ->
            "It appears you don't have an Internet connection right now."

        Http.BadStatus response ->
            response.status.message

        Http.BadPayload message response ->
            message


httpCommand : Cmd Msg
httpCommand =
    payloadDecoder
        |> Http.get chatroomsApiUrl
        |> Http.send FetchAllChatrooms


payloadDecoder : Decoder ChatroomPayload
payloadDecoder =
    map ChatroomPayload
        (field "data" (list testDecoder))


listDecoder : Decoder (List Chatroom)
listDecoder =
    list testDecoder


testDecoder : Decoder Chatroom
testDecoder =
    map2 Chatroom
        (field "name" string)
        (field "id" int)