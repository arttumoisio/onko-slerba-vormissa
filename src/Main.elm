module Main exposing (..)

import ApiFields exposing (WZData, constFields)
import Browser
import Debug exposing (toString)
import Html exposing (Html, br, button, div, li, text, ul)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Http exposing (Error(..))
import Json.Decode as Decode exposing (Decoder, float, int, list, string)
import Json.Decode.Pipeline exposing (required)
import List exposing (sum)
import ListUtil
import RemoteData exposing (WebData)
import Round
import Url.Builder as UrlBuilder exposing (relative)
import Users exposing (Status(..), User, users)



---- MODEL ----


type alias Model =
    { wzData : WebData WZData
    , activeUser : User
    }


init : ( Model, Cmd Msg )
init =
    ( Model RemoteData.NotAsked (User "Slerba" "slerbatron33#4084536" NotFetched), callFunction )



---- UPDATE ----


type Msg
    = FetchMoreData
    | FunctionResponse (WebData WZData)
    | ChangeActive User


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FunctionResponse wzData ->
            let
                activeUser =
                    model.activeUser

                newUser =
                    { activeUser | fetched = Fetched }

                _ =
                    Debug.log (toString model)
            in
            ( { model | wzData = wzData, activeUser = newUser }, Cmd.none )

        FetchMoreData ->
            ( { model | wzData = RemoteData.Loading }, callFunctionWUser model.activeUser )

        ChangeActive newUser ->
            ( { model | activeUser = newUser, wzData = RemoteData.Loading }, callFunctionWUser newUser )


callFunction : Cmd Msg
callFunction =
    Http.get
        { expect = Http.expectJson (RemoteData.fromResult >> FunctionResponse) decodeWZData
        , url = relative [ ".netlify", "functions", "call-api" ] []
        }


callFunctionWUser : User -> Cmd Msg
callFunctionWUser user =
    Http.get
        { expect = Http.expectJson (RemoteData.fromResult >> FunctionResponse) decodeWZData
        , url =
            relative [ ".netlify", "functions", "call-api" ] [ UrlBuilder.string "user" user.user ]
        }


decodeWZData : Decoder WZData
decodeWZData =
    Decode.succeed WZData
        |> required constFields.vormi string
        |> required constFields.keskiarvo float
        |> required constFields.kd float
        |> required constFields.tapot (list int)
        |> required constFields.kuolemat (list int)
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
            div []
                [ headerSelection model.activeUser
                , text "Initialising."
                ]

        RemoteData.Loading ->
            div []
                [ headerSelection model.activeUser
                , text "Loading..."
                ]

        RemoteData.Failure err ->
            div [] [ text <| errorToString err ]

        RemoteData.Success wzData ->
            page wzData model.activeUser


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


page : WZData -> User -> Html Msg
page wzData activeUser =
    div []
        [ headerSelection activeUser
        , br [] []
        , upperData wzData
        , br [] []
        , dataTaulukko wzData
        , button [ onClick FetchMoreData ] [ text "Päivitä" ]
        , br [] []
        , selectedHighlight activeUser.short
        ]


headerSelection : User -> Html Msg
headerSelection activeUser =
    div [ class "selection" ] <|
        List.map
            (selectionElem activeUser.user)
            users


selectionElem : String -> User -> Html Msg
selectionElem activeUser user =
    div
        [ onClick <| ChangeActive user
        , classList
            [ ( "activeUser", activeUser == user.user )
            , ( "selectionElem", True )
            ]
        ]
        (case user.fetched of
            Fetched ->
                [ text user.short
                , text "+"
                ]

            NotFetched ->
                [ text user.short ]
        )


selectedHighlight : String -> Html Msg
selectedHighlight name =
    div []
        [ text name
        ]


upperData : WZData -> Html Msg
upperData wzData =
    div []
        [ textBlock "Vormi: "
        , textBlock wzData.vormi
        , textBlock <| "Viimeisten " ++ ListUtil.lenToString wzData.gulagDeaths ++ " pelin statsit:"
        , textBlock (" Keskiarvo: " ++ String.fromFloat wzData.keskiarvo)
        , textBlock (" K/D: " ++ String.fromFloat wzData.kd)
        , textBlock (" Gulagit: " ++ gulagSuccessString wzData.gulagKills wzData.gulagDeaths)
        , textBlock (" Gulag-%: " ++ precentageOfTwoLists wzData.gulagKills wzData.gulagDeaths)
        ]


dataTaulukko : WZData -> Html Msg
dataTaulukko wzData =
    div [ class "box" ]
        [ flexIntElem "Tapot:" wzData.tapot
        , flexIntElem "Kuolemat:" wzData.kuolemat
        , flexIntElem "Damaget:" wzData.damaget
        , flexIntElem "Imetyt damaget:" wzData.otetut
        , flexIntElem "Gulag tapot:" wzData.gulagKills
        , flexIntElem "Gulag kuolemat:" wzData.gulagDeaths
        , flexStringElem "Mode:" wzData.mode
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
    , li [] [ text <| String.fromInt <| ListUtil.max data ]
    ]


liMin : List Int -> List (Html Msg)
liMin data =
    [ text "Min:"
    , li [] [ text <| String.fromInt <| ListUtil.min data ]
    ]


liAverage : List Int -> List (Html Msg)
liAverage data =
    [ text "Avg:"
    , li [] [ text <| Round.round 2 <| ListUtil.average data ]
    ]


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
