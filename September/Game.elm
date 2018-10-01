module Game exposing (..)
import Html exposing (Html, program)
import Dict exposing (empty)

import Data.Msg exposing (Msg)
import Data.Model exposing (Model)
import Data.GameState exposing (GameState(StartMenu))

main : Program Never Model Msg
main =
  program
    { init = init
    , subscriptions = subscriptions
    , update = update
    , view = view
    }

init : (Model, Cmd Msg)
init =
  ({ balls = []
  , blocks = []
  , field = empty
  , gameState = StartMenu
  , paddles = []
  , powerUps = []
  }, Cmd.none)

view : Model -> Html.Html Msg
view state =
  Html.div [] [
    Html.text "Test"
  ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg state =
  (state, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions state =
  Sub.none
