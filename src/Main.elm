module Main exposing (..)

import Browser
import Html exposing (Html, text, div, h1, img, p)
import Html.Attributes exposing (src)
import RemoteData exposing (WebData)
import Http
import Json.Decode exposing (..)
import Array exposing (Array)

---- MODEL ----
type alias Model = {
    tokenAndUrl: WebData TokenAndUrl }


init : ( Model, Cmd Msg )
init =
    ( Model RemoteData.NotAsked, callFunction)


---- UPDATE ----
type Msg
    = NoOp
    | FunctionResponse (WebData TokenAndUrl)

type alias TokenAndUrl = {
    vormi: String,
    tapot: List Int,
    keskiarvo: Float,
    kd: Float
    }
    

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FunctionResponse tokenAndUrl ->
            ( { model | tokenAndUrl = tokenAndUrl }, Cmd.none)
        _ ->
            ( model, Cmd.none )


callFunction: Cmd Msg
callFunction =
    Http.get { 
        expect = Http.expectJson (RemoteData.fromResult >> FunctionResponse) decodeTokenAndUrl,
        url = ".netlify/functions/call-api" 
    }

decodeTokenAndUrl : Decoder TokenAndUrl
decodeTokenAndUrl =
    Json.Decode.map4 TokenAndUrl
        (field "vormi" Json.Decode.string)
        (field "tapot" (Json.Decode.list Json.Decode.int))
        (field "keskiarvo" Json.Decode.float)
        (field "kd" Json.Decode.float)

---- VIEW ----
view : Model -> Html Msg
view model =
    case model.tokenAndUrl of
        RemoteData.NotAsked -> 
            div [] [text "Initialising."]

        RemoteData.Loading -> 
            div [] [text "Loading."]
            
        RemoteData.Failure err -> 
            div [] [text "Error..."]

        RemoteData.Success tokenAndUrl -> 
            page tokenAndUrl
            
page : TokenAndUrl -> Html Msg
page tokenAndUrl = 
    div [] [
                div [] [
                    text ("Vormi: " ++ tokenAndUrl.vormi)
                ],
                div [] [
                    text "Viimeisten viiden pelin statsit:"
                ],
                div [] [
                    text (" Keskiarvo: " ++ String.fromFloat tokenAndUrl.keskiarvo)
                ],
                div [] [
                    text (" K/D: " ++ String.fromFloat tokenAndUrl.kd)
                ],
                div [] (
                    [div [] [text ("Tapot:" )]]
                    ++ listTapot tokenAndUrl.tapot)
            ]

listTapot : List Int -> List (Html Msg)
listTapot tapot = 
    List.map tappoElem tapot

tappoElem : Int -> Html msg
tappoElem tappo = 
   div [] [text (String.fromInt tappo )] 


---- PROGRAM ----
main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }