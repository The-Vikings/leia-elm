module Components.Chatroom.Update exposing (update)

import Components.Chatroom.Messages exposing (ChatroomMsg(FetchChatroom))
import Messages exposing (Msg)
import Model exposing (Model, RemoteData(Failure, Success))


update : ChatroomMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchChatroom (Ok response) ->
            ( { model | chatroom = Success response }, Cmd.none )

        FetchChatroom (Err _) ->
            ( { model | chatroom = Failure "Chatroom not found" }, Cmd.none )
