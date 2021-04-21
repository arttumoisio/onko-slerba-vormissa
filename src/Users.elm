module Users exposing (..)


type Status
    = Fetched
    | NotFetched


type alias User =
    { short : String, user : String, acti : String, fetched : Status }


users : List User
users =
    [ { short = "Kyntö", user = "mouqq", acti = "kyntö#1293018", fetched = NotFetched }
    , { short = "Slerba", user = "nepagell", acti = "rekyylireijo33#5266178", fetched = NotFetched }
    , { short = "Juutalaine", user = "Pageli", acti = "TuhoojaTommi33#5266178", fetched = NotFetched }
    , { short = "Hojo", user = "hojozza", acti = "hojozza#2398418", fetched = NotFetched }
    , { short = "Kupperi", user = "kupperi", acti = "kupperi#3370706", fetched = NotFetched }
    ]


users2 : List User
users2 =
    [ { short = "Kyntö", user = "mouqq", acti = "kyntö#1293018", fetched = Fetched }
    , { short = "Slerba", user = "nepagell", acti = "rekyylireijo33#5266178", fetched = Fetched }
    , { short = "Juutalaine", user = "Pageli", acti = "TuhoojaTommi33#5266178", fetched = Fetched }
    , { short = "Hojo", user = "hojozza", acti = "hojozza#2398418", fetched = Fetched }
    , { short = "Kupperi", user = "kupperi", acti = "kupperi#3370706", fetched = Fetched }
    ]



-- users=slerbatron33%234084536&users=hojozza%232398418
