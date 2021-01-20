module Main exposing (..)

import Browser
import Html exposing (Html, text, div, ul, li)
import Html.Attributes exposing (class)
import RemoteData exposing (WebData)
import Http
import Json.Decode exposing (..)
import Array exposing (Array)

---- MODEL ----
type alias Model = {
    tokenAndUrl: WebData TokenAndUrl 
    }


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
    kuolemat: List Int,
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
    Json.Decode.map5 TokenAndUrl
        (field "vormi" Json.Decode.string)
        (field "tapot" (Json.Decode.list Json.Decode.int))
        (field "kuolemat" (Json.Decode.list Json.Decode.int))
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

textBlock : String -> Html msg
textBlock string = div [] [text string] 

page : TokenAndUrl -> Html Msg
page tokenAndUrl = 
    div [] [
                div [] 
                [ textBlock ("Vormi: ")
                , textBlock (tokenAndUrl.vormi)
                , textBlock "Viimeisten viiden pelin statsit:"
                , textBlock (" Keskiarvo: " ++ String.fromFloat tokenAndUrl.keskiarvo)
                , textBlock (" K/D: " ++ String.fromFloat tokenAndUrl.kd)
                ],
                div [ class "box"] 
                [ div [class "flexList"] 
                    [ text ("Tapot:" )
                    , ul [] (listTapot tokenAndUrl.tapot)
                    ],
                  div [class "flexList"] 
                    [ text ("Kuolemat:" )
                    , ul [] (listTapot tokenAndUrl.kuolemat)
                    ]
                ]
            ]

listTapot : List Int -> List (Html Msg)
listTapot tapot = 
    List.map tappoElem tapot 

tappoElem : Int -> Html msg
tappoElem tappo = 
   li [] [text (String.fromInt tappo )] 


---- PROGRAM ----
main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }