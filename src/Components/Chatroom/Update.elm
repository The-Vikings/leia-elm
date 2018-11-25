module Components.Chatroom.Update exposing (update)

import Commands exposing (chatroomsApiUrl)
import Components.Chatroom.Commands exposing (fetchAllChatrooms)
import Components.Chatroom.Messages exposing (ChatroomMsg(..))
import Components.Chatroom.Model exposing (Chatroom)
import Components.Question.Model exposing (Question)
import Http
import Json.Decode exposing (Decoder, decodeString, field, list, map3, string, int)
import Messages exposing (Msg)
import Model exposing (Model, RemoteData(Failure, Success))


update : ChatroomMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchChatroom (Ok response) ->
            ( { model | chatroom = Success response }, Cmd.none )

        FetchChatroom (Err _) ->
            ( { model | chatroom = Failure "Chatroom not found" }, Cmd.none )
