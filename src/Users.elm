module Users exposing (..)


type Status
    = Fetched
    | NotFetched


type alias User =
    { short : String, user : String, fetched : Status }


users : List User
users =
    [ { short = "Slerba", user = "slerbatron33#4084536", fetched = NotFetched }
    , { short = "Kyntö", user = "kyntö#1293018", fetched = NotFetched }
    , { short = "Hojo", user = "hojozza#2398418", fetched = NotFetched }
    , { short = "Kupperi", user = "kupperi#3370706", fetched = NotFetched }
    ]


users2 : List User
users2 =
    [ { short = "Slerba", user = "slerbatron33#4084536", fetched = Fetched }
    , { short = "Kyntö", user = "kyntö#1293018", fetched = Fetched }
    , { short = "Hojo", user = "hojozza#2398418", fetched = Fetched }
    , { short = "Kupperi", user = "kupperi#3370706", fetched = Fetched }
    ]
