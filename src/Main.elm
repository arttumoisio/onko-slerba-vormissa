module Main exposing (..)

import Browser
import Html exposing (Html, br, button, div, li, text, ul)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http exposing (Error(..))
import Json.Decode as Decode exposing (Decoder, float, int, list, string)
import Json.Decode.Pipeline exposing (required)
import List exposing (sum)
import RemoteData exposing (WebData)
import Round



---- MODEL ----


type alias Model =
    { wzData : WebData WZData
    , someOtherVal : String
    }


init : ( Model, Cmd Msg )
init =
    ( Model RemoteData.NotAsked "Maybe.Nothing", callFunction )



---- UPDATE ----


type Msg
    = FetchMoreData
    | FunctionResponse (WebData WZData)


type alias WZData =
    { vormi : String
    , tapot : List Int
    , kuolemat : List Int
    , keskiarvo : Float
    , kd : Float
    , damaget : List Int
    , otetut : List Int
    , gulagKills : List Int
    , gulagDeaths : List Int
    , mode : List String
    }


type alias WZDataFields =
    { vormi : String
    , tapot : String
    , kuolemat : String
    , keskiarvo : String
    , kd : String
    , damaget : String
    , otetut : String
    , gulagKills : String
    , gulagDeaths : String
    , mode : String
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
        "mode"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FunctionResponse wzData ->
            ( { model | wzData = wzData }, Cmd.none )

        FetchMoreData ->
            ( { model | wzData = RemoteData.Loading }, callFunction )


callFunction : Cmd Msg
callFunction =
    Http.get
        { expect = Http.expectJson (RemoteData.fromResult >> FunctionResponse) decodeWZData
        , url = ".netlify/functions/call-api"
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
        |> required constFields.mode (list string)



---- VIEW ----


view : Model -> Html Msg
view model =
    case model.wzData of
        RemoteData.NotAsked ->
            div [] [ text "Initialising." ]

        RemoteData.Loading ->
            div [] [ text "Loading..." ]

        RemoteData.Failure err ->
            div [] [ text <| errorToString err ]

        RemoteData.Success wzData ->
            page wzData


errorToString : Http.Error -> String
errorToString error =
    case error of
        BadUrl url ->
            "The URL " ++ url ++ " was invalid"

        Timeout ->
            "Unable to reach the server, try again"

        NetworkError ->
            "Unable to reach the server, check your network connection"

        BadStatus 500 ->
            "The server had a problem, try again later"

        BadStatus 400 ->
            "Verify your information and try again"

        BadStatus _ ->
            "Unknown error"

        BadBody errorMessage ->
            errorMessage


textBlock : String -> Html msg
textBlock string =
    div [] [ text string ]


lenToString : List a -> String
lenToString list =
    let
        len =
            List.length list
    in
    case len of
        5 ->
            "viiden"

        17 ->
            "seittemäntoista"

        18 ->
            "kaheksantoista"

        19 ->
            "yheksäntoista"

        20 ->
            "parinkytä"

        _ ->
            ""


precentageOfTwoLists : List Int -> List Int -> String
precentageOfTwoLists eka toka =
    let
        sum =
            toFloat <| List.sum eka

        tot =
            toFloat <| List.sum eka + List.sum toka
    in
    Round.round 1 (100 * sum / tot)


gulagSuccessString : List Int -> List Int -> String
gulagSuccessString eka toka =
    if List.length eka /= List.length toka then
        "Gulagissa virhe"

    else
        let
            sum =
                List.sum eka

            tot =
                List.length eka
        in
        String.fromInt sum ++ "/" ++ String.fromInt tot


page : WZData -> Html Msg
page wzData =
    div []
        [ div []
            [ textBlock "Vormi: "
            , textBlock wzData.vormi
            , textBlock <| "Viimeisten " ++ lenToString wzData.gulagDeaths ++ " pelin statsit:"
            , textBlock (" Keskiarvo: " ++ String.fromFloat wzData.keskiarvo)
            , textBlock (" K/D: " ++ String.fromFloat wzData.kd)
            , textBlock (" Gulagit: " ++ gulagSuccessString wzData.gulagKills wzData.gulagDeaths)
            , textBlock (" Gulag-%: " ++ precentageOfTwoLists wzData.gulagKills wzData.gulagDeaths)
            ]
        , br [] []
        , div [ class "box" ]
            [ flexIntElem "Tapot:" wzData.tapot
            , flexIntElem "Kuolemat:" wzData.kuolemat
            , flexIntElem "Damaget:" wzData.damaget
            , flexIntElem "Imetyt damaget:" wzData.otetut
            , flexIntElem "Gulag tapot:" wzData.gulagKills
            , flexIntElem "Gulag kuolemat:" wzData.gulagDeaths
            , flexStringElem "Mode:" wzData.mode
            ]
        , button [ onClick FetchMoreData ] [ text "Päivitä" ]
        ]


flexStringElem : String -> List String -> Html Msg
flexStringElem otsikko data =
    div [ class "flexList" ]
        [ text otsikko
        , ul [] <| List.map (\n -> li [] [ text n ]) data
        ]


flexIntElem : String -> List Int -> Html Msg
flexIntElem otsikko data =
    div [ class "flexList" ]
        [ text otsikko
        , ul [] <| listAndAverageAndMax data
        ]


listAndAverageAndMax : List Int -> List (Html Msg)
listAndAverageAndMax data =
    listTapot data ++ liAverage data ++ liMax data ++ liMin data


listTapot : List Int -> List (Html Msg)
listTapot tapot =
    List.map tappoElem tapot


liMax : List Int -> List (Html Msg)
liMax data =
    [ text "Max:"
    , li [] [ text <| String.fromInt <| maxOfList data ]
    ]


liMin : List Int -> List (Html Msg)
liMin data =
    [ text "Min:"
    , li [] [ text <| String.fromInt <| minOfList data ]
    ]


liAverage : List Int -> List (Html Msg)
liAverage data =
    [ text "Avg:"
    , li [] [ text <| Round.round 2 <| averageOfList data ]
    ]


maxOfList : List Int -> Int
maxOfList list =
    case List.maximum list of
        Maybe.Nothing ->
            0

        Maybe.Just m ->
            m


minOfList : List Int -> Int
minOfList list =
    case List.minimum list of
        Maybe.Nothing ->
            0

        Maybe.Just m ->
            m


averageOfList : List Int -> Float
averageOfList list =
    let
        sum =
            toFloat <| List.sum list

        len =
            toFloat <| List.length list
    in
    sum / len


tappoElem : Int -> Html msg
tappoElem tappo =
    li [] [ text (String.fromInt tappo) ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
