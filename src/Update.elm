module Update exposing (update, urlUpdate)

import Components.Chatroom.Commands as ChatroomCommands
import Components.Chatroom.Model exposing (Chatroom)
import Components.Question.Decoder as QuestionDecoder
import Components.Question.Model exposing (AutomaticAnswer, Question, UserAnswer)
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
                        |> Phoenix.Push.onOk ReceiveQuestion
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

        SendReply questionId ->
            let
                payload =
                    JsEncode.object
                        [ ( "body", JsEncode.string model.replyInProgress )
                        , ( "question_id", JsEncode.string (toString questionId) )
                        ]

                phxPush =
                    Phoenix.Push.init "newReply" "room:lobby"
                        |> Phoenix.Push.withPayload payload
                        |> Phoenix.Push.onOk ReceiveUserAnswer
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

        ReceiveQuestion raw ->
            let
                questionDecoder =
                    QuestionDecoder.questionDecoder

                somePayload =
                    JsDecode.decodeValue questionDecoder raw
            in
            case somePayload of
                Ok payload ->
                    let
                        ( chatroom, cmd ) =
                            RemoteData.update (updateChatroomQuestions payload) model.chatroom
                    in
                    ( { model | chatroom = chatroom }, cmd )

                Err error ->
                    ( model, Cmd.none )

        ReceiveUserAnswer raw ->
            let
                userAnswerDecoder =
                    QuestionDecoder.userAnswerDecoder

                somePayload =
                    JsDecode.decodeValue userAnswerDecoder raw
            in
            case somePayload of
                Ok payload ->
                    let
                        ( chatroom, cmd ) =
                            RemoteData.update (updateChatroomUserAnswer payload) model.chatroom
                    in
                    ( { model | chatroom = chatroom }, cmd )

                Err error ->
                    ( model, Cmd.none )

        ReceiveAutomaticAnswer raw ->
            let
                automaticAnswerDecoder =
                    QuestionDecoder.automaticAnswerDecoder

                somePayload =
                    JsDecode.decodeValue automaticAnswerDecoder raw
            in
            case somePayload of
                Ok payload ->
                    let
                        ( chatroom, cmd ) =
                            RemoteData.update (updateChatroomAutomaticAnswer payload) model.chatroom
                    in
                    ( { model | chatroom = chatroom }, cmd )

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

        ExpandQuestion maybeInt ->
            case maybeInt of
                Just int ->
                    { model | expandedQuestion = Just int } ! []

                _ ->
                    { model | expandedQuestion = Nothing } ! []


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


updateChatroomQuestions : Question -> Chatroom -> ( Chatroom, Cmd msg )
updateChatroomQuestions newQuestion chatroom =
    let
        questions = List.append chatroom.questions ( List.singleton newQuestion )
    in
    ( { chatroom | questions = questions }, Cmd.none )


updateChatroomUserAnswer : UserAnswer -> Chatroom -> ( Chatroom, Cmd msg )
updateChatroomUserAnswer newUserAnswer chatroom =
    let
        updateUserAnswer question =
            if question.id == newUserAnswer.question_id then
                { question | userAnswers = newUserAnswer :: question.userAnswers }

            else
                question

        questions =
            List.map updateUserAnswer chatroom.questions
    in
    ( { chatroom | questions = questions }, Cmd.none )


updateChatroomAutomaticAnswer : AutomaticAnswer -> Chatroom -> ( Chatroom, Cmd msg )
updateChatroomAutomaticAnswer newAutomaticAnswer chatroom =
    let
        updateAutomaticAnswer question =
            if question.id == newAutomaticAnswer.question_id then
                { question | automaticAnswers = newAutomaticAnswer :: question.automaticAnswers }

            else
                question

        questions =
            List.map updateAutomaticAnswer chatroom.questions
    in
    ( { chatroom | questions = questions }, Cmd.none )
    