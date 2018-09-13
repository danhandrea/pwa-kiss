module Page.Home exposing (view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Html exposing (Html)


view : { title : String, content : Html msg }
view =
    { title = "home"
    , content = Html.text "home"
    }
