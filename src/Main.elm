module Main exposing (..)

import Browser
import Html exposing (Html, text, div, ul, li)
import Html.Attributes exposing (class)
import RemoteData exposing (WebData)
import Http
import Json.Decode as Decode exposing (Decoder, float, string, list, int)
import Json.Decode.Pipeline exposing (required)
import Html exposing (br)
import List exposing (sum)

---- MODEL ----
type alias Model = {
    wzData: WebData WZData,
    someOtherVal: String
    }


init : ( Model, Cmd Msg )
init =
    ( Model RemoteData.NotAsked "Maybe.Nothing", callFunction)


---- UPDATE ----
type Msg
    = FetchMoreData
    | FunctionResponse (WebData WZData)

type alias WZData = 
    { vormi: String
    , tapot: List Int
    , kuolemat: List Int
    , keskiarvo: Float
    , kd: Float
    , damaget: List Int
    , otetut: List Int
    , gulagKills: List Int
    , gulagDeaths: List Int
    }

type alias WZDataFields = 
    { vormi: String
    , tapot: String
    , kuolemat: String
    , keskiarvo: String
    , kd: String
    , damaget: String
    , otetut: String
    , gulagKills: String
    , gulagDeaths: String
    }


constFields : WZDataFields
constFields = 
    WZDataFields 
        "vormi"
        "tapot"
        "kuolemat"
        "keskiarvo"
        "kd"
        "damaget"
        "otetut"
        "gulagKills"
        "gulagDeaths"
    

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FunctionResponse wzData ->
            ( { model | wzData = wzData }, Cmd.none)
        FetchMoreData ->
            ( model, Cmd.none )


callFunction: Cmd Msg
callFunction =
    Http.get { 
        expect = Http.expectJson (RemoteData.fromResult >> FunctionResponse) decodeWZData,
        url = ".netlify/functions/call-api" 
    }

decodeWZData : Decoder WZData
decodeWZData =
    Decode.succeed WZData
        |> required constFields.vormi string
        |> required constFields.tapot (list int)
        |> required constFields.kuolemat (list int)
        |> required constFields.keskiarvo float
        |> required constFields.kd float
        |> required constFields.damaget (list int)
        |> required constFields.otetut (list int)
        |> required constFields.gulagKills (list int)
        |> required constFields.gulagDeaths (list int)

---- VIEW ----
view : Model -> Html Msg
view model =
    case model.wzData of
        RemoteData.NotAsked -> 
            div [] [text "Initialising."]

        RemoteData.Loading -> 
            div [] [text "Loading..."]
            
        RemoteData.Failure _ -> 
            div [] [text "Error..." ]

        RemoteData.Success wzData -> 
            page wzData

textBlock : String -> Html msg
textBlock string = div [] [text string] 

lenToString : List a -> String
lenToString list =
    let
        len = List.length list
    in
    case len of 
        5 -> "viiden"
        20 -> "parinkytä"
        _ -> ""

fractionOfTwoLists: List Int -> List Int -> String
fractionOfTwoLists eka toka =
    let
        sum = List.sum eka
        tot = List.sum eka + List.sum toka
    in
    String.fromInt sum ++ "/" ++ String.fromInt tot

page : WZData -> Html Msg
page wzData = 
    div [] 
        [ div [] 
            [ textBlock ("Vormi: ")
            , textBlock (wzData.vormi)
            , textBlock <| "Viimeisten " ++ (lenToString wzData.gulagDeaths) ++ " pelin statsit:"
            , textBlock (" Keskiarvo: " ++ String.fromFloat wzData.keskiarvo)
            , textBlock (" K/D: " ++ String.fromFloat wzData.kd)
            , textBlock (" Gulagit: " ++ fractionOfTwoLists wzData.gulagKills wzData.gulagDeaths)
            ]
        , br [] []
        , div [ class "box"] 
            [ flexElem "Tapot:" wzData.tapot
            , flexElem "Kuolemat:" wzData.kuolemat
            , flexElem "Damaget:" wzData.damaget
            , flexElem "Imetyt damaget:" wzData.otetut
            ]
    ]

flexElem : String -> List Int -> Html Msg
flexElem otsikko data =
    div [class "flexList"] 
        [ text otsikko
        , ul [] <| listAndAverageAndMax data
        ]

listAndAverageAndMax : List Int -> List (Html Msg)
listAndAverageAndMax data = listTapot data ++ liAverage data ++ liMax data

listTapot : List Int -> List (Html Msg)
listTapot tapot = 
    List.map tappoElem tapot 

liMax : List Int -> List (Html Msg)
liMax data = 
    [ text "Max:"
    , li [] [text <| String.fromInt <| maxOfList data]
    ]
liAverage : List Int -> List(Html Msg)
liAverage data = 
    [ text "Avg:"
    , li [] [text <| String.fromFloat <| averageOfList data]
    ]

maxOfList : List Int -> Int
maxOfList list = 
    let
        max = List.maximum list
    in
    case max of
       Maybe.Nothing -> 0
       Maybe.Just m -> m
averageOfList : List Int -> Float
averageOfList list =   
    let
        sum = toFloat <| List.sum list
        len = toFloat <| List.length list
    in
        sum / len
    
  
  
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