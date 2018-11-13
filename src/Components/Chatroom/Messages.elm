module Components.Chatroom.Messages exposing (ChatroomMsg(..))

import Components.Chatroom.Model exposing (Chatroom)
import Http

type ChatroomMsg
    = FetchChatroom (Result Http.Error Chatroom)
