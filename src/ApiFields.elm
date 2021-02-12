module ApiFields exposing (..)

import Dict exposing (Dict)


type alias WZDataDict =
    Dict String WZData


type alias WZData =
    { tapot : List Int
    , kuolemat : List Int
    , damaget : List Int
    , otetut : List Int
    , gulagKills : List Int
    , gulagDeaths : List Int
    , mode : List String
    }


constWZData : WZData
constWZData =
    WZData [] [] [] [] [] [] []


constWZDataDict : WZDataDict
constWZDataDict =
    Dict.singleton "a" constWZData


type alias WZDataFields =
    { vormi : String
    , tapot : String
    , kuolemat : String
    , damaget : String
    , otetut : String
    , gulagKills : String
    , gulagDeaths : String
    , mode : String
    }


constFields : WZDataFields
constFields =
    { vormi = "vormi"
    , tapot = "tapot"
    , kuolemat = "kuolemat"
    , damaget = "damaget"
    , otetut = "otetut"
    , gulagKills = "gulagKills"
    , gulagDeaths = "gulagDeaths"
    , mode = "mode"
    }
