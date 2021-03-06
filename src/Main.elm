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
    { allData : WebData WZDataDict
    , activeUser : User
    , fetching : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, callFunctionDefaultUser )


initialModel : Model
initialModel =
    Model
        RemoteData.NotAsked
        (User
            ""
            ""
            NotFetched
        )
        True


initialDict : Dict String (WebData WZData)
initialDict =
    Dict.empty



---- UPDATE ----


type Msg
    = FetchMoreData
    | FetchAllDataResponse (WebData WZDataDict)
    | ChangeActive User
    | SetDefaultUser (WebData String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchMoreData ->
            ( { model | fetching = True }, callFunctionAllUsers users )

        FetchAllDataResponse newAllData ->
            ( { model | allData = newAllData, fetching = False }, Cmd.none )

        ChangeActive newUser ->
            ( { model | activeUser = newUser }, Cmd.none )

        SetDefaultUser defaultUserResponse ->
            processDefaultUserResponseMsg defaultUserResponse model


processDefaultUserResponseMsg : WebData String -> Model -> ( Model, Cmd Msg )
processDefaultUserResponseMsg res model =
    case res of
        RemoteData.Success userString ->
            let
                activeUser =
                    model.activeUser

                newUser =
                    case List.filter (\u -> u.user == userString) users of
                        [] ->
                            activeUser

                        x :: _ ->
                            x
            in
            ( { model | activeUser = newUser }, callFunctionAllUsers users )

        _ ->
            ( model, Cmd.none )


callFunctionAllUsers : List User -> Cmd Msg
callFunctionAllUsers users =
    Http.get
        { expect = Http.expectJson (RemoteData.fromResult >> FetchAllDataResponse) decodeWZDataDict
        , url =
            relative [ ".netlify", "functions", "karmiva-vitutus" ] <| List.map (\user -> UrlBuilder.string "users" user.user) users
        }


callFunctionDefaultUser : Cmd Msg
callFunctionDefaultUser =
    Http.get
        { expect = Http.expectJson (RemoteData.fromResult >> SetDefaultUser) string
        , url =
            relative [ ".netlify", "functions", "default-user" ] []
        }


decodeWZDataDict : Decoder WZDataDict
decodeWZDataDict =
    dict decodeWZData


decodeWZData : Decoder WZData
decodeWZData =
    Decode.succeed WZData
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
    case model.allData of
        RemoteData.NotAsked ->
            div []
                [ headerSelection model.activeUser
                , div [ class "initializediv" ] [ text <| "Initialising " ++ model.activeUser.short ++ "..." ]
                ]

        RemoteData.Loading ->
            div []
                [ headerSelection model.activeUser
                , text "Loading..."
                ]

        RemoteData.Failure err ->
            div [] [ text <| errorToString err ]

        RemoteData.Success wzDataDict ->
            case Dict.get model.activeUser.user wzDataDict of
                Maybe.Nothing ->
                    text "Error, active user not found in dict"

                Just wzData ->
                    page wzData model.activeUser model


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


precentageOfTwoLists : List Int -> String
precentageOfTwoLists eka =
    let
        sum =
            toFloat <| List.sum eka

        tot =
            toFloat <| List.length eka
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


page : WZData -> User -> Model -> Html Msg
page wzData activeUser model =
    div []
        [ headerSelection activeUser
        , div [ classList [ ( "initializediv", model.fetching ) ] ]
            [ upperData wzData
            , br [] []
            , dataTaulukko wzData
            , br [] []
            , button [ onClick FetchMoreData ] [ text "Päivitä" ]
            ]
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
        , textBlock <|
            if ListUtil.average wzData.tapot >= 10.0 then
                "ON VORMI"

            else
                "EI OO VORMIA"
        , textBlock <| "Viimeisten " ++ ListUtil.lenToString wzData.gulagDeaths ++ " pelin statsit:"
        , roundedAverageElem wzData.tapot
        , roundedKDElem wzData.tapot wzData.kuolemat
        , textBlock <| " Gulagit: " ++ gulagSuccessString wzData.gulagKills wzData.gulagDeaths
        , textBlock <| " Gulag-%: " ++ precentageOfTwoLists wzData.gulagKills
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
