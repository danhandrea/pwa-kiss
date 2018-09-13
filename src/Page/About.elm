module Page.About exposing (view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Html exposing (Html)


view : { title : String, content : Html msg }
view =
    { title = "about"
    , content = Html.text "about"
    }
