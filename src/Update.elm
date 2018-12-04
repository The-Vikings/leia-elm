module Update exposing (update, urlUpdate)

import Array exposing (Array)
import Components.Chatroom.Commands as ChatroomCommands
import Components.Chatroom.Model exposing (Chatroom)
import Components.Question.Decoder as QuestionDecoder
import Components.Question.Model exposing (AutomaticAnswer, Question, UserAnswer)
import Contact.Update
import ContactList.Update
import Dict
import Html exposing (Html, div, h2, text)
import Json.Decode as JsDecode exposing (Decoder, decodeString, field, int, list, map, map2, map3, map5, string)
import Json.Encode as JsEncode
import Material
import Material.Color as Color
import Material.Elevation exposing (e2, e8)
import Material.Helpers exposing (cssTransitionStep, delay, map1st, map2nd, pure)
import Material.Options as Options exposing (Style, cs, css, nop)
import Material.Snackbar as Snackbar
import Messages exposing (Msg(..))
import Model exposing (Model, RemoteData(Failure, NotRequested, Requesting, Success), Square, Square_(..))
import Navigation
import Phoenix.Push
import Phoenix.Socket
import Platform.Cmd exposing (Cmd, none)
import Ports
import RemoteData
import Routing
    exposing
        ( Route(ChatroomRoute, FrontpageRoute, ListContactsRoute, ShowContactRoute)
        )
import Time exposing (Time, millisecond)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdl msg ->
            Material.update Mdl msg model

        SelectTab num ->
            { model | selectedTab = num } ! []

        AddToast content ->
            add (\k -> Snackbar.toast k <| "Notification: " ++ content) model

        Appear k ->
            ( model
                |> mapSquare k
                    (\sq ->
                        if sq == Appearing then
                            Growing

                        else
                            sq
                    )
            , delay transitionLength (Grown k)
            )

        Grown k ->
            model
                |> mapSquare k
                    (\sq ->
                        if sq == Growing then
                            Waiting

                        else
                            sq
                    )
                |> pure

        Snackbar (Snackbar.Begin k) ->
            model |> mapSquare k (always Active) |> pure

        Snackbar (Snackbar.End k) ->
            model
                |> mapSquare k
                    (\sq ->
                        if sq /= Disappearing then
                            Idle

                        else
                            sq
                    )
                |> pure

        Snackbar (Snackbar.Click k) ->
            ( model |> mapSquare k (always Disappearing)
            , delay transitionLength (Gone k)
            )

        Snackbar msg_ ->
            Snackbar.update msg_ model.snackbar
                |> map1st (\s -> { model | snackbar = s })
                |> map2nd (Cmd.map Snackbar)

        Gone k ->
            ( { model
                | snackbarSquares = List.filter (Tuple.first >> (/=) k) model.snackbarSquares
              }
            , none
            )

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
                        , ( "question_id", JsEncode.int questionId )
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

                        ( snackbar_, effect ) =
                            Snackbar.add ((\k -> Snackbar.toast k <| "Notification: New Question") model.snackbarCount) model.snackbar
                                |> map2nd (Cmd.map Snackbar)

                        model_ =
                            { model
                                | snackbar = snackbar_
                                , snackbarCount = model.snackbarCount + 1
                                , snackbarSquares = ( model.snackbarCount, Appearing ) :: model.snackbarSquares
                            }
                    in
                    ( { model_ | chatroom = chatroom }
                    , Cmd.batch
                        [ cssTransitionStep (Appear model.snackbarCount)
                        , effect
                        ]
                    )

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
                        ( snackbar_, effect ) =
                            Snackbar.add ((\k -> Snackbar.toast k <| "Notification: New reply to question - " ++ toString payload.question_id) model.snackbarCount) model.snackbar
                                |> map2nd (Cmd.map Snackbar)

                        ( chatroom, cmd ) =
                            RemoteData.update (updateChatroomUserAnswer payload) model.chatroom

                        model_ =
                            { model
                                | snackbar = snackbar_
                                , snackbarCount = model.snackbarCount + 1
                                , snackbarSquares = ( model.snackbarCount, Appearing ) :: model.snackbarSquares
                            }
                    in
                    ( { model_ | chatroom = chatroom }
                    , Cmd.batch
                        [ cssTransitionStep (Appear model.snackbarCount)
                        , effect
                        ]
                    )

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
        questions =
            List.append chatroom.questions (List.singleton newQuestion)
    in
    ( { chatroom | questions = questions }, Cmd.none )


updateChatroomUserAnswer : UserAnswer -> Chatroom -> ( Chatroom, Cmd msg )
updateChatroomUserAnswer newUserAnswer chatroom =
    let
        updateUserAnswer question =
            if question.id == newUserAnswer.question_id then
                { question | userAnswers = List.append question.userAnswers (List.singleton newUserAnswer) }

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
                { question | automaticAnswers = List.append question.automaticAnswers (List.singleton newAutomaticAnswer) }

            else
                question

        questions =
            List.map updateAutomaticAnswer chatroom.questions
    in
    ( { chatroom | questions = questions }, Cmd.none )



-- Snacbar helper functions


boxHeight : String
boxHeight =
    "48px"


boxWidth : String
boxWidth =
    "64px"


transitionLength : Time
transitionLength =
    150 * millisecond


mapSquare : Int -> (Square_ -> Square_) -> Model -> Model
mapSquare k f model =
    { model
        | snackbarSquares =
            List.map
                (\(( k_, sq ) as s) ->
                    if k /= k_ then
                        s

                    else
                        ( k_, f sq )
                )
                model.snackbarSquares
    }


add : (Int -> Snackbar.Contents Int) -> Model -> ( Model, Cmd Msg )
add f model =
    let
        ( snackbar_, effect ) =
            Snackbar.add (f model.snackbarCount) model.snackbar
                |> map2nd (Cmd.map Snackbar)

        model_ =
            { model
                | snackbar = snackbar_
                , snackbarCount = model.snackbarCount + 1
                , snackbarSquares = ( model.snackbarCount, Appearing ) :: model.snackbarSquares
            }
    in
    ( model_
    , Cmd.batch
        [ cssTransitionStep (Appear model.snackbarCount)
        , effect
        ]
    )


transitionInner : Style a
transitionInner =
    css "transition" <|
        "box-shadow 333ms ease-in-out 0s, "
            ++ "width "
            ++ toString transitionLength
            ++ "ms, "
            ++ "height "
            ++ toString transitionLength
            ++ "ms, "
            ++ "background-color "
            ++ toString transitionLength
            ++ "ms"


transitionOuter : Style a
transitionOuter =
    css "transition" <|
        "width "
            ++ toString transitionLength
            ++ "ms ease-in-out 0s, "
            ++ "margin "
            ++ toString transitionLength
            ++ "ms ease-in-out 0s"


clickView : Model -> Square -> Html a
clickView model ( k, square ) =
    let
        hue =
            Array.get ((k + 4) % Array.length Color.hues) Color.hues
                |> Maybe.withDefault Color.Teal

        shade =
            case square of
                Idle ->
                    Color.S100

                _ ->
                    Color.S500

        color =
            Color.color hue shade

        ( width, height, margin, selected ) =
            if square == Appearing || square == Disappearing then
                ( "0", "0", "16px 0", False )

            else
                ( boxWidth, boxHeight, "16px 16px", square == Active )
    in
    {- In order to get the box appearance and disappearance animations
       to start in the lower-left corner, we render boxes as an outer div (which
       animates only width, to cause reflow of surrounding boxes), and an
       absolutely positioned inner div (to force animation to start in the
       lower-left corner.
    -}
    Options.div
        [ css "height" boxHeight
        , css "width" width
        , css "position" "relative"
        , css "display" "inline-block"
        , css "margin" margin
        , css "z-index" "0"
        , transitionOuter
        ]
        [ Options.div
            [ Color.background color
            , Color.text Color.primaryContrast
            , if selected then
                e8

              else
                e2

            -- Center contents
            , css "display" "inline-flex"
            , css "align-items" "center"
            , css "justify-content" "center"
            , css "flex" "0 0 auto"

            -- Sizing
            , css "height" height
            , css "width" width
            , css "border-radius" "2px"
            , css "box-sizing" "border-box"

            -- Force appearance/disapparenace to be from/to lower-left corner.
            , css "position" "absolute"
            , css "bottom" "0"
            , css "left" "0"

            -- Transitions
            , transitionInner
            ]
            [ div [] [ text <| toString k ] ]
        ]
