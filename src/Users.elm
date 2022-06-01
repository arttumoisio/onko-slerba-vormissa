module Users exposing (..)


type Status
    = Fetched
    | NotFetched


type alias User =
    { short : String, user : String, fetched : Status }


users : List User
users =
    [ 
    , { short = "AnaaliFisti", user = "mouqq", fetched = NotFetched }
    ,  {short = "RekyyliReijo", user = "nepagell", fetched = NotFetched }
    -- , { short = "Kupperi", user = "kupperi", fetched = NotFetched }
    -- , { short = "Juutalaine", user = "Pageli", fetched = NotFetched }
    -- , { short = "Hojo", user = "hojozza", fetched = NotFetched }
    ]
