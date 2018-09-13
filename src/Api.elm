module Api exposing (Cred, application, storeCredWith, username, viewerChanges)

import Avatar exposing (Avatar)
import Browser
import Browser.Navigation as Nav
import Json.Decode as Decode exposing (Decoder, Value, decodeString, field, string)
import Json.Decode.Pipeline as Pipeline exposing (optional, required)
import Json.Encode as Encode
import Ports exposing (onStoreChange, storeCache)
import Url exposing (Url)
import Username exposing (Username)


{-| This module is responsible for communicating to the Conduit API.
It exposes an opaque Endpoint type which is guaranteed to point to the correct URL.
-}
type Cred
    = Cred Username String


username : Cred -> Username
username (Cred val _) =
    val


{-| It's important that this is never exposed!
We epxose `login` and `application` instead, so we can be certain that if anyone
ever has access to a `Cred` value, it came from either the login API endpoint
or was passed in via flags.
-}
credDecoder : Decoder Cred
credDecoder =
    Decode.succeed Cred
        |> required "username" Username.decoder
        |> required "token" Decode.string


application :
    Decoder (Cred -> viewer)
    ->
        { init : Maybe viewer -> Url -> Nav.Key -> ( model, Cmd msg )
        , onUrlChange : Url -> msg
        , onUrlRequest : Browser.UrlRequest -> msg
        , subscriptions : model -> Sub msg
        , update : msg -> model -> ( model, Cmd msg )
        , view : model -> Browser.Document msg
        }
    -> Program Value model msg
application viewerDecoder config =
    let
        init flags url navKey =
            let
                maybeViewer =
                    Decode.decodeValue Decode.string flags
                        |> Result.andThen (Decode.decodeString (storageDecoder viewerDecoder))
                        |> Result.toMaybe
            in
            config.init maybeViewer url navKey
    in
    Browser.application
        { init = init
        , onUrlChange = config.onUrlChange
        , onUrlRequest = config.onUrlRequest
        , subscriptions = config.subscriptions
        , update = config.update
        , view = config.view
        }


storageDecoder : Decoder (Cred -> viewer) -> Decoder viewer
storageDecoder viewerDecoder =
    Decode.field "user" (decoderFromCred viewerDecoder)


decoderFromCred : Decoder (Cred -> a) -> Decoder a
decoderFromCred decoder =
    Decode.map2 (\fromCred cred -> fromCred cred)
        decoder
        credDecoder



-- PERSISTANCE


viewerChanges : (Maybe viewer -> msg) -> Decoder (Cred -> viewer) -> Sub msg
viewerChanges toMsg decoder =
    onStoreChange (\value -> toMsg (decodeFromChange decoder value))


decodeFromChange : Decoder (Cred -> viewer) -> Value -> Maybe viewer
decodeFromChange viewerDecoder val =
    -- It's stored in localStorage as a JSON String;
    -- first decode the Value as a String, then
    -- decode that String as JSON.
    Decode.decodeValue (storageDecoder viewerDecoder) val
        |> Result.toMaybe


storeCredWith : Cred -> Avatar -> Cmd msg
storeCredWith (Cred uname token) avatar =
    let
        json =
            Encode.object
                [ ( "user"
                  , Encode.object
                        [ ( "username", Username.encode uname )
                        , ( "token", Encode.string token )
                        , ( "image", Avatar.encode avatar )
                        ]
                  )
                ]
    in
    storeCache (Just json)
