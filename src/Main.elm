module Main exposing (Flags, Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Dict exposing (Dict)
import Html exposing (Html, div, option, select, text)
import Html.Attributes exposing (selected)
import Html.Events exposing (on)
import Json.Decode


{-| Entry point and standard wiring for Browser.element
-}
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


{-| Record type (struct?) of what i'm recieving from js/ruby
-}
type alias Person =
    { org : String
    , name : String
    }


{-| Record type (struct?) of my app state
-}
type alias Model =
    { people : List Person
    , chosenOrg : Maybe String
    }


{-| Record type (struct?) of by app constructor (see `init`)
-}
type alias Flags =
    { people : List Person
    }


{-| define complete list of `Msg` that `update` has to handle
-}
type Msg
    = OrgChanged String


{-| App constructor (receive Flag from js; see `Elm.Main.init` in `views/index.erb`)
-}
init : Flags -> ( Model, Cmd Msg )
init flags =
    ( Model flags.people Nothing, Cmd.none )


{-| aka `render`; consist of 1 text label and 2x `<select>...</select>`
-}
view : Model -> Html Msg
view model =
    div []
        [ text "Organisation: "
        , orgSelector model
        , peopleSelector model
        ]


{-| returns `<select>..</select>` for choosing org

`orgNames` is a unique list of `person[:org]`; we use a dictionary (key/value)
`optionTag` is a local helper function to output `<option..>` with `selected=true` when this orgName matches model.chosenOrg

notice the final `select` is trapping `on change`; fire off `OrgChanged <value>` for `update` to handle

-}
orgSelector : Model -> Html Msg
orgSelector { chosenOrg, people } =
    let
        orgNames =
            people
                -- people.inject(Dict.empty) {|dict,person| dict.merge(person.org => person.org) }
                |> List.foldl (\person dict -> Dict.insert person.org person.org dict) Dict.empty
                -- .keys
                |> Dict.keys

        optionTag orgName =
            option [ selected (Just orgName == chosenOrg) ] [ text orgName ]
    in
    select [ on "change" (Json.Decode.map OrgChanged Html.Events.targetValue) ] <|
        List.map optionTag orgNames


{-| returns a `<select>..</select>` for choosing people

but only people where `person[:org]` matches our model.chosenOrg

-}
peopleSelector : Model -> Html Msg
peopleSelector { chosenOrg, people } =
    let
        orgPeople =
            -- people.filter {|person| person.org ~= chosenOrg }
            List.filter (\person -> Just person.org == chosenOrg) people
    in
    select [] <|
        List.map (\person -> option [] [ text person.name ]) orgPeople


{-| When we receive a `OrgChanged <value>` interaction, we just update our `model.chosenOrg`
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OrgChanged newOrg ->
            ( { model | chosenOrg = Just newOrg }, Cmd.none )


{-| unused
-}
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
