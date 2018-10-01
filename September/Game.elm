module Game exposing (..)
import Html exposing (Html, program)
import Dict exposing (Dict(..), empty)

type alias Position = (Int, Int)

type alias ID = Int

type alias Model =
  { balls : List ID
  , blocks : List ID
  , field : Dict Position ID
  , gameState : GameState
  , paddles : List ID
  , powerUps : List ID
  }

type Msg
  = Nop

type GameState
  = Menu
  | GameStart
  | Playing
  | GameOver

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
  , gameState = Menu
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
