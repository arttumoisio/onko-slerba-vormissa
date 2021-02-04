module ListUtilTest exposing (..)

import Expect
import Fuzz exposing (..)
import ListUtil
import Test exposing (..)



-- Check out https://package.elm-lang.org/packages/elm-explorations/test/latest to learn more about testing in Elm!


listUtilMaxTest : Test
listUtilMaxTest =
    describe "Maximum"
        [ test "Basic list minimum" <|
            \_ ->
                Expect.equal 5 (ListUtil.max [ 3, 4, 5 ])
        , test "Empty list" <|
            \_ ->
                Expect.equal 0 (ListUtil.max [])
        , fuzz int "fuzz" <|
            \num ->
                Expect.equal num (ListUtil.max [ num ])
        ]


listUtilMinTest : Test
listUtilMinTest =
    describe "Minimum"
        [ test "Basic list minimum" <|
            \_ ->
                Expect.equal 3 (ListUtil.min [ 3, 4, 5 ])
        , test "Empty list" <|
            \_ ->
                Expect.equal 0 (ListUtil.min [])
        , fuzz int "fuzz" <|
            \num ->
                Expect.equal num (ListUtil.min [ num ])
        ]


listUtilAverageTest : Test
listUtilAverageTest =
    describe "averge of list"
        [ test "Simple list" <|
            \_ ->
                ListUtil.average [ 1, 2 ] |> Expect.within (Expect.Absolute 0.0000001) 1.5
        , test "Average of two lists emptys" <|
            \_ ->
                ListUtil.average [] |> Expect.equal 0.0
        , test "Longer list" <|
            \_ ->
                ListUtil.average [ 2, 2, 2, 2, 2 ] |> Expect.within (Expect.Absolute 0.0000001) 2
        , fuzz int "Fuzz list with one item" <|
            \num ->
                ListUtil.average [ num ] |> Expect.within (Expect.Absolute 0.0000001) (toFloat num)
        ]
