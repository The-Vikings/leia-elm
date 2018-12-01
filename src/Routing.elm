module Routing exposing
    ( Route(ChatroomRoute, FrontpageRoute, ListContactsRoute, NotFoundRoute, ShowContactRoute)
    , forRoute
    , parse
    )

import Navigation exposing (Location)
import UrlParser exposing ((</>), Parser, int, map, oneOf, s, top)


type Route
    = ListContactsRoute
    | NotFoundRoute
    | ShowContactRoute Int
    | ChatroomRoute String
    | FrontpageRoute


forRoute : Route -> String
forRoute route =
    case route of
        ListContactsRoute ->
            "/listcontacts/"

        ShowContactRoute id ->
            "/contacts/" ++ toString id

        NotFoundRoute ->
            "/not-found"

        ChatroomRoute id ->
            "/chatroom/" ++ toString id

        FrontpageRoute ->
            "/Frontpage"

        


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


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map FrontpageRoute top
        , map ListContactsRoute (s "")
        , map ShowContactRoute (s "contacts" </> int)
        , map ChatroomRoute (s "chatroom" </> UrlParser.string)
        ]
