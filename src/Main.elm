module Main exposing (..)

-- Press buttons to increment and decrement a counter.
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/buttons.html
--
import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import String exposing (slice)

-- MAIN
main : Program () Model Msg
main =
  Browser.sandbox { init = init, update = update, view = view }

-- MODEL
type alias Model = String

init : Model
init =
  ""

-- UPDATE
type Msg
  = FetchVormi

update : Msg -> Model -> Model
update msg model =
  case msg of
    FetchVormi ->
      "No vittu onKÖ"

-- VIEW
view : Model -> Html Msg
view model =
  div []
    [ button [ onClick FetchVormi ] [ text "Kato onko Slerba vormissa" ]
    , div [] [ text ( model) ]
    ]