module Routing
    exposing
        ( Route(ListContactsRoute, NotFoundRoute, ShowContactRoute)
        , parse
        , chatroomPath
        )

import Navigation exposing (Location)
import UrlParser exposing (Parser, (</>), int, map, oneOf, s, top)


type Route
    = ListContactsRoute
    | NotFoundRoute
    | ShowContactRoute Int
    | ChatroomRoute String
    | FrontpageMenuRoute


chatroomPath : Route -> String
chatroomPath route =
    case route of
        ListContactsRoute ->
            "/listcontacts/"   

        ShowContactRoute id ->
            "/contacts/" ++ toString id

        NotFoundRoute ->
            "/not-found"

        ChatroomRoute id ->
            "/chatroom/" ++ toString id

        FrontpageMenuRoute -> 
            "/"

questionsPath : Route -> String
questionsPath route = 
    "#questions"

questionPath : Route -> String
questionPath id = 
    "#questions/" ++ toString id

parse : Navigation.Location -> Route
parse location =
    case UrlParser.parsePath matchers location of    
        Just route ->
            route

        Nothing ->
            NotFoundRoute
 -- doublecheck if we shoul route by "parseHash" instead of "parsePath"


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map FrontpageMenuRoute top 
        , map ListContactsRoute (s "")
        , map ShowContactRoute (s "contacts" </> int)
        , map ChatroomRoute (s "chatroom" </> UrlParser.string )
        ]
