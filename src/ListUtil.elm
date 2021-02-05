module ListUtil exposing (..)

{-| Get the average value of a `List Int`, returns 0 if empty `List`

    ListUtil.average [ 1, 3, 2 ] == 2

    ListUtil.average [ 1, 2 ] == 1.5

    ListUtil.average [] == 0

-}


average : List Int -> Float
average list =
    let
        sum =
            toFloat (List.sum list)

        len =
            toFloat (List.length list)
    in
    case List.length list of
        0 ->
            0

        _ ->
            sum / len


{-| Get the maximum value of a `List Int`, returns 0 if empty `List`

    ListUtil.min [ 1, 3, 2 ] == 3

    ListUtil.min [] == 0

-}
max : List Int -> Int
max list =
    case List.maximum list of
        Maybe.Nothing ->
            0

        Maybe.Just m ->
            m


{-| Get the minimum value of a `List Int`, returns 0 if empty `List`

    ListUtil.min [ 1, 3, 2 ] == 1

    ListUtil.min [] == 0

-}
min : List Int -> Int
min list =
    case List.minimum list of
        Maybe.Nothing ->
            0

        Maybe.Just m ->
            m


{-| Get the 1st per 2nd value of two `List Int`'s, returns 0 if empty `List`,
List lengths must match

    ListUtil.kd [ 10, 10 ] [ 1, 1 ] == 10

    ListUtil.kd [ 3, 3 ] [ 2, 2 ] == 1.5

    ListUtil.kd [] [] == 0

    ListUtil.kd [ 1, 1 ] [ 1 ] == 0

    ListUtil.kd [ 1 ] [ 1, 1 ] == 0

-}
kd : List Int -> List Int -> Float
kd killsList deathsList =
    let
        kills =
            toFloat <| List.sum killsList

        deaths =
            toFloat <| List.sum deathsList

        kl =
            List.length killsList

        dl =
            List.length deathsList
    in
    if kl == 0 || kl /= dl then
        0.0

    else
        kills / deaths


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
