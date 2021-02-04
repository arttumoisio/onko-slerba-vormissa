module ApiFields exposing (..)


type alias WZData =
    { vormi : String
    , keskiarvo : Float
    , kd : Float
    , tapot : List Int
    , kuolemat : List Int
    , damaget : List Int
    , otetut : List Int
    , gulagKills : List Int
    , gulagDeaths : List Int
    , mode : List String
    }


constWZData : WZData
constWZData =
    WZData "" 0 0 [] [] [] [] [] [] []


type alias WZDataFields =
    { vormi : String
    , keskiarvo : String
    , kd : String
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
    , keskiarvo = "keskiarvo"
    , kd = "kd"
    , tapot = "tapot"
    , kuolemat = "kuolemat"
    , damaget = "damaget"
    , otetut = "otetut"
    , gulagKills = "gulagKills"
    , gulagDeaths = "gulagDeaths"
    , mode = "mode"
    }
