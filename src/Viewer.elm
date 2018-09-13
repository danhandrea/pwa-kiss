module Viewer exposing (..)

{-| The logged-in user currently viewing this page. It stores enough data to
be able to render the menu bar (username and avatar), along with Cred so it's
impossible to have a Viewer if you aren't logged in.
-}

import Api exposing (Cred)
import Avatar exposing (Avatar)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (custom, required)
import Username exposing (Username)


-- TYPES


type Viewer
    = Viewer Avatar Cred



-- INFO


username : Viewer -> Username
username (Viewer _ val) =
    Api.username val


avatar : Viewer -> Avatar
avatar (Viewer val _) =
    val



-- SERIALIZATION


decoder : Decoder (Cred -> Viewer)
decoder =
    Decode.succeed Viewer
        |> custom (Decode.field "image" Avatar.decoder)


store : Viewer -> Cmd msg
store (Viewer avatarVal credVal) =
    Api.storeCredWith
        credVal
        avatarVal
