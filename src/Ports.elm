port module Ports exposing (..)

import Json.Decode exposing (Value)


port storeCache : Maybe Value -> Cmd msg


port onStoreChange : (Value -> msg) -> Sub msg


port asdqweqw : (Value -> msg) -> Sub msg
