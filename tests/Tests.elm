module Tests exposing (..)

import Expect
import Main exposing (..)
import Test exposing (..)



-- Check out https://package.elm-lang.org/packages/elm-explorations/test/latest to learn more about testing in Elm!


gulagSuccess : Test
gulagSuccess =
    describe "gulagSuccess"
        [ test "Fraction of two lists emptys" <|
            \_ ->
                Expect.equal "0/0" (gulagSuccessString [] [])
        , test "Fraction of two lists error" <|
            \_ ->
                Expect.equal "Gulagissa virhe" (gulagSuccessString [ 0 ] [])
        , test "Fraction of two lists zeros" <|
            \_ ->
                Expect.equal "0/1" (gulagSuccessString [ 0 ] [ 0 ])
        , test "Fraction of two lists ones" <|
            \_ ->
                Expect.equal "1/1" (gulagSuccessString [ 1 ] [ 1 ])
        , test "Fraction of two lists" <|
            \_ ->
                Expect.equal "12/20"
                    (gulagSuccessString
                        [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0 ]
                        [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1 ]
                    )
        , test "Fraction of two lists improved" <|
            \_ ->
                Expect.equal "14/20"
                    (gulagSuccessString
                        [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0 ]
                        [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1 ]
                    )
        ]
