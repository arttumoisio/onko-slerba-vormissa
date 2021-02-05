module Main exposing (..)

import ApiFields exposing (WZData, WZDataDict, constFields)
import Browser
import Dict exposing (Dict)
import Html exposing (Html, br, button, div, li, text, ul)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Http exposing (Error(..))
import Json.Decode as Decode exposing (Decoder, dict, int, list, string)
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
    , allData : WebData WZDataDict
    , activeUser : User
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, callFunction )


initialModel : Model
initialModel =
    Model
        RemoteData.NotAsked
        RemoteData.NotAsked
        (User "Slerba" "slerbatron33#4084536" NotFetched)


initialDict : Dict String (WebData WZData)
initialDict =
    Dict.empty



---- UPDATE ----


type Msg
    = FetchMoreData
    | ChangeFunctionResponse (WebData WZData)
    | FunctionResponse (WebData WZData)
    | FetchAllDataResponse (WebData WZDataDict)
    | ChangeActive User


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeFunctionResponse wzData ->
            let
                activeUser =
                    model.activeUser

                newUser =
                    { activeUser | fetched = Fetched }
            in
            ( { model | wzData = wzData, activeUser = newUser }, Cmd.none )

        FunctionResponse wzData ->
            let
                activeUser =
                    model.activeUser

                newUser =
                    { activeUser | fetched = Fetched }
            in
            ( { model | wzData = wzData, activeUser = newUser }, callFunctionAllUsers users )

        FetchMoreData ->
            ( { model | wzData = RemoteData.Loading }, callFunctionWUser model.activeUser )

        FetchAllDataResponse newAllData ->
            ( { model | allData = newAllData }, Cmd.none )

        ChangeActive newUser ->
            case model.allData of
                RemoteData.Success allData ->
                    let
                        newData =
                            Dict.get newUser.user allData

                        newClenedData =
                            case newData of
                                Maybe.Nothing ->
                                    model.wzData

                                Just val ->
                                    RemoteData.Success val
                    in
                    ( { model | activeUser = newUser, wzData = newClenedData }, Cmd.none )

                _ ->
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
        { expect = Http.expectJson (RemoteData.fromResult >> ChangeFunctionResponse) decodeWZData
        , url =
            relative [ ".netlify", "functions", "call-api" ] [ UrlBuilder.string "user" user.user ]
        }


callFunctionAllUsers : List User -> Cmd Msg
callFunctionAllUsers users =
    Http.get
        { expect = Http.expectJson (RemoteData.fromResult >> FetchAllDataResponse) decodeWZDataDict
        , url =
            relative [ ".netlify", "functions", "karmiva-vitutus" ] <| List.map (\user -> UrlBuilder.string "users" user.user) users
        }


decodeWZDataDict : Decoder WZDataDict
decodeWZDataDict =
    dict decodeWZData


decodeWZData : Decoder WZData
decodeWZData =
    Decode.succeed WZData
        |> required constFields.vormi string
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
                , text <| "Initialising " ++ model.activeUser.short ++ "."
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
        , upperData wzData
        , br [] []
        , dataTaulukko wzData
        , button [ onClick FetchMoreData ] [ text "Päivitä" ]
        , br [] []
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
        , roundedAverageElem wzData.tapot
        , roundedKDElem wzData.tapot wzData.kuolemat
        , textBlock <| " Gulagit: " ++ gulagSuccessString wzData.gulagKills wzData.gulagDeaths
        , textBlock <| " Gulag-%: " ++ precentageOfTwoLists wzData.gulagKills wzData.gulagDeaths
        ]


roundedAverageElem : List Int -> Html msg
roundedAverageElem list =
    textBlock <| " Keskiarvo: " ++ (Round.round 2 <| ListUtil.average list)


roundedKDElem : List Int -> List Int -> Html msg
roundedKDElem list1 list2 =
    textBlock <| " K/D: " ++ (Round.round 2 <| ListUtil.kd list1 list2)


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
    listTapot data ++ liAverage data ++ liMaxElem data ++ liMinElem data


listTapot : List Int -> List (Html Msg)
listTapot tapot =
    List.map tappoElem tapot


liMaxElem : List Int -> List (Html Msg)
liMaxElem data =
    [ text "Max:"
    , li [] [ text <| String.fromInt <| ListUtil.max data ]
    ]


liMinElem : List Int -> List (Html Msg)
liMinElem data =
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


exampleData : String
exampleData =
    """
        { "slerbatron33#4084536":{"vormi":"EI OO VORMIA","tapot":[14,5,17,12,4,3,3,15,14,7,12,1,15,14,7,10,7,13],"kuolemat":[1,3,2,2,2,2,3,2,2,3,1,2,1,2,1,4,2,8],"damaget":[5616,2682,6404,4742,1299,1263,772,5323,6022,2777,5162,457,7273,4741,2736,4081,2618,3621],"otetut":[817,761,1172,492,492,356,756,731,1005,844,605,370,627,320,202,1347,813,1714],"gulagKills":[0,0,1,0,1,1,0,1,1,0,1,1,0,0,0,1,1,0],"gulagDeaths":[0,1,0,1,0,0,1,0,0,0,0,0,0,1,0,1,0,0],"mode":["br_brduos","br_brduos","br_brduos","br_brduos","br_brduos","br_brduos","br_brduos","br_brduos","br_brtrios","br_rebirth_rbrthtrios","br_brtrios","br_brtrios","br_brtrios","br_brduos","br_brtrios","br_brtrios","br_brtrios","br_dmz_plnbld"],"defaultUser":"slerbatron33#4084536"}
        , "hojozza#2398418"     :{"vormi":"EI OO VORMIA","tapot":[7,0,1,6,9,8,0,3,2,10,2,1,3,4,1,2,1,7,6,5],"kuolemat":[1,2,2,2,1,2,2,2,3,2,3,1,6,5,3,1,2,2,4,2],"damaget":[2773,493,745,2375,2066,3008,282,1721,1838,3339,951,293,1926,1525,509,1304,276,2655,2302,1992],"otetut":[791,351,547,449,186,655,774,688,908,758,1023,265,850,1413,776,341,557,715,1096,597],"gulagKills":[1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1],"gulagDeaths":[0,1,1,1,0,1,1,1,1,1,1,0,0,0,1,0,1,1,1,0],"mode":["br_brtrios","br_brtrios","br_brtrios","br_brbbquad","br_dmz_plnbld","br_brbbquad","br_brbbquad","br_brbbquad","br_brbbquad","br_brbbquad","br_brbbquad","br_brbbquad","br_dmz_plnbld","br_dmz_plnbld","br_brtrios","br_brbbquad","br_brbbquad","br_brbbquad","br_brbbquad","br_brduos"],"defaultUser":"slerbatron33#4084536"}
        }
    """
