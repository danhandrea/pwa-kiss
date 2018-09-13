module Main exposing (..)

import Api exposing (Cred)
import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src)
import Json.Decode as Decode exposing (Value)
import Page exposing (Page)
import Page.Blank as Blank
import Page.Home as Home
import Page.NotFound as NotFound
import Route exposing (Route)
import Session exposing (Session)
import Url exposing (Url)
import Viewer exposing (Viewer)


---- MODEL ----


type Model
    = Redirect Session
    | NotFound Session
    | Home Session


init : Maybe Viewer -> Url -> Nav.Key -> ( Model, Cmd Msg )
init maybeViewer url navKey =
    changeRouteTo (Route.fromUrl url)
        (Redirect (Session.fromViewer navKey maybeViewer))



---- VIEW ----


view : Model -> Document Msg
view model =
    let
        viewPage page toMsg config =
            let
                { title, body } =
                    Page.view (Session.viewer (toSession model)) page config
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model of
        Redirect _ ->
            viewPage Page.Other (\_ -> Ignored) Blank.view

        NotFound _ ->
            viewPage Page.Other (\_ -> Ignored) NotFound.view

        Home _ ->
            viewPage Page.Home (\_ -> Ignored) Home.view



---- UPDATE ----


type Msg
    = Ignored
    | ChangedRoute (Maybe Route)
    | ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotSession Session


toSession : Model -> Session
toSession page =
    case page of
        Redirect session ->
            session

        NotFound session ->
            session

        Home session ->
            session


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        session =
            toSession model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )

        Just Route.Root ->
            ( model, Route.replaceUrl (Session.navKey session) Route.Home )

        Just Route.Home ->
            ( model, Route.replaceUrl (Session.navKey session) Route.Home )

        Just Route.About ->
            ( model, Route.replaceUrl (Session.navKey session) Route.About )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        NotFound _ ->
            Sub.none

        Redirect _ ->
            Session.changes GotSession (Session.navKey (toSession model))

        Home _ ->
            Sub.none



-- Settings settings ->
--     Sub.map GotSettingsMsg (Settings.subscriptions settings)
-- Home home ->
--     Sub.map GotHomeMsg (Home.subscriptions home)
-- Login login ->
--     Sub.map GotLoginMsg (Login.subscriptions login)
-- Register register ->
--     Sub.map GotRegisterMsg (Register.subscriptions register)
-- Profile _ profile ->
--     Sub.map GotProfileMsg (Profile.subscriptions profile)
-- Article article ->
--     Sub.map GotArticleMsg (Article.subscriptions article)
-- Editor _ editor ->
--     Sub.map GotEditorMsg (Editor.subscriptions editor)
---- MAIN


main : Program Value Model Msg
main =
    Api.application Viewer.decoder
        { init = init
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
