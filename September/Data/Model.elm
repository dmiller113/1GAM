module Data.Model exposing (Model)

import Data.GameState exposing (GameState)
import Data.ID exposing (ID)
import Data.Position exposing (Position)
import Dict exposing (Dict(..))

type alias Model =
  { balls : List ID
  , blocks : List ID
  , field : Dict Position ID
  , gameState : GameState
  , paddles : List ID
  , powerUps : List ID
  }
