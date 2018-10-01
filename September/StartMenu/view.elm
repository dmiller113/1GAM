module StartMenu.View exposing (..)

import Data.GameState exposing (GameState(StartMenu))
import Data.Model exposing (Model)
import Data.Msg exposing (Msg)
import Html exposing (Html, div, h2, span, text)
import Html.Attributes exposing (class)

view : Model -> Html Msg
view state =
  div
    []
    [ header
    , text "\x025B6"
    , span
      [ class "separator" ]
      []
    , text "START"
    ]


header =
  h2
    []
    [ span
      []
      [ text "Arkanoid" ]
    , text " "
    , span
      [ class "small-header"]
      [ text "in elm" ]
    ]
