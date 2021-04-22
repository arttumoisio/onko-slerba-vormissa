module Users exposing (..)


type Status
    = Fetched
    | NotFetched


type alias User =
    { short : String, user : String, fetched : Status }


users : List User
users =
    [ { short = "Kyntö", user = "mouqq", fetched = NotFetched }
    , { short = "Slerba", user = "nepagell", fetched = NotFetched }
    , { short = "Juutalaine", user = "Pageli", fetched = NotFetched }
    , { short = "Hojo", user = "hojozza", fetched = NotFetched }
    , { short = "Kupperi", user = "kupperi", fetched = NotFetched }
    ]
