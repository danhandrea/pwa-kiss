module Page exposing (..)

{-| Determines which navbar link (if any) will be rendered as active.
Note that we don't enumerate every page here, because the navbar doesn't
have links for every page. Anything that's not part of the navbar falls
under Other.
-}

import Browser exposing (Document)
import Html exposing (Html, a, button, div, footer, i, img, li, nav, p, span, text, ul)
import Html.Attributes exposing (class, classList, href, style)
import Route exposing (Route)
import Viewer exposing (Viewer)


type Page
    = Other
    | Home
    | About


{-| Take a page's Html and frames it with a header and footer.
The caller provides the current user, so we can display in either
"signed in" (rendering username) or "signed out" mode.
isLoading is for determining whether we should show a loading spinner
in the header. (This comes up during slow page transitions.)
-}
view : Maybe Viewer -> Page -> { title : String, content : Html msg } -> Document msg
view maybeViewer page { title, content } =
    { title = title ++ " - Conduit"
    , body = viewHeader page maybeViewer :: content :: [ viewFooter ]
    }


viewHeader : Page -> Maybe Viewer -> Html msg
viewHeader page maybeViewer =
    nav [ class "navbar navbar-light" ]
        [ div [ class "container" ]
            [ a [ class "navbar-brand", Route.href Route.Home ]
                [ text "conduit" ]
            , ul [ class "nav navbar-nav pull-xs-right" ] <|
                navbarLink page Route.Home [ text "Home" ]
                    :: viewMenu page maybeViewer
            ]
        ]


viewMenu : Page -> Maybe Viewer -> List (Html msg)
viewMenu page maybeViewer =
    let
        linkTo =
            navbarLink page 
    in
    case maybeViewer of
        Just viewer ->
            let
                username =
                    Viewer.username viewer

                avatar =
                    Viewer.avatar viewer
            in
            [ linkTo Route.About [ i [] [], text "\u{00A0}About" ]
            ]

        Nothing -> 
            [ linkTo Route.About [ text "About" ]
            -- , linkTo Route.Register [ text "Sign up" ]
            ]


viewFooter : Html msg
viewFooter =
    footer []
        [ div [ class "container" ]
            [ a [ class "logo-font", href "/" ] [ text "conduit" ]
            , span [ class "attribution" ]
                [ text "An interactive learning project from "
                , a [ href "https://thinkster.io" ] [ text "Thinkster" ]
                , text ". Code & design licensed under MIT."
                ]
            ]
        ]

navbarLink : Page -> Route -> List (Html msg) -> Html msg
navbarLink page route linkContent =
    li [ classList [ ( "nav-item", True ), ( "active", isActive page route ) ] ]
        [ a [ class "nav-link", Route.href route ] linkContent ]


isActive : Page -> Route -> Bool
isActive page route =
    case ( page, route ) of
        ( Home, Route.Home ) ->
            True

        ( About, Route.About ) ->
            True

        _ ->
            False