module Main exposing (..)

import Html exposing (Html, program, div, text)
import Svg exposing (Svg, svg, circle, rect)
import Svg.Attributes exposing (width, height, cx, cy, r, fill, x, y)
import Time exposing (Time, millisecond)
import Keyboard exposing (downs, KeyCode)
import Char


-- We making Pong. We such good game dev.
-- Type declarations


type alias Model =
    { ball : Ball
    , paddles : List Paddle
    , lastTick : Time
    }


type alias Position =
    { x : Int
    , y : Int
    }


type alias Ball =
    { position : Position
    , ballColor : Color
    , ballSpeed : Speed
    }


type alias Speed =
    { cX : Int
    , cY : Int
    }


type alias Color =
    String


type alias Paddle =
    { position : Position
    , color : Color
    , owner : Player
    , width : Int
    }


type Player
    = PlayerOne Int
    | PlayerTwo Int


type Msg
    = NoP
    | Tick Time
    | KeyDown KeyCode



-- Initial Model for GameState


initialBall : Ball
initialBall =
    { position =
        { x = 20
        , y = 35
        }
    , ballColor = "#fff"
    , ballSpeed =
        { cX = 5
        , cY = -5
        }
    }


initState : Model
initState =
    { ball = initialBall
    , paddles =
        [ { position =
                { x = 10
                , y = 25
                }
          , color = "#bb6633"
          , owner = PlayerOne 0
          , width = initialPaddleWidth
          }
        , { position =
                { x = 435
                , y = 25
                }
          , color = "#bb6633"
          , owner = PlayerTwo 0
          , width = initialPaddleWidth
          }
        ]
    , lastTick = 0
    }


initialPaddleWidth : Int
initialPaddleWidth =
    50


timeToPoll : Time
timeToPoll =
    1000 / 24 * millisecond


rCode : KeyCode
rCode =
    Char.toCode 'R'


wCode : KeyCode
wCode =
    Char.toCode 'W'


sCode : KeyCode
sCode =
    Char.toCode 'S'


downArrowCode : KeyCode
downArrowCode =
    40


upArrowCode : KeyCode
upArrowCode =
    38



-- Update Function


ballMomentum : Time -> Ball -> Position
ballMomentum t { ballSpeed, position } =
    let
        { cX, cY } =
            ballSpeed

        { x, y } =
            position

        dT =
            t / (1000 / 24)
    in
        { x = (floor <| toFloat cX * dT) + x
        , y = (floor <| toFloat cY * dT) + y
        }


clampBounds : Position -> Position
clampBounds { x, y } =
    { x = clamp 0 445 x, y = clamp 5 295 y }


hasCollided : Speed -> Position -> Paddle -> Bool
hasCollided { cX } { x, y } { owner, position, width } =
    case owner of
        PlayerOne _ ->
            cX < 0 && x <= 20 && y >= position.y && y <= position.y + width

        PlayerTwo _ ->
            cX > 0 && x >= 429 && y >= position.y && y <= position.y + width


hasSideCollisions : Position -> Speed -> Bool
hasSideCollisions { y } { cY } =
    (y == 5 && cY < 0) || (y >= 295 && cY > 0)


updatePosition : Time -> Ball -> Position
updatePosition t =
    ballMomentum t >> clampBounds


isBallLegal : Position -> Bool
isBallLegal { x, y } =
    x > 5 && x < 445


handleScore : Position -> List Paddle -> List Paddle
handleScore position paddles =
    let
        changePaddleScore : Paddle -> Paddle
        changePaddleScore paddle =
            { paddle | owner = addScore position paddle.owner }
    in
        List.map changePaddleScore paddles


handleSpeed : Speed -> Bool -> Bool -> Speed
handleSpeed { cX, cY } paddleCollision sideCollision =
    let
        xScalar =
            if paddleCollision then
                -1
            else
                1

        yScalar =
            if sideCollision then
                -1
            else
                1
    in
        { cX = cX * xScalar, cY = cY * yScalar }


addScore : Position -> Player -> Player
addScore { x, y } player =
    case player of
        PlayerOne score ->
            if x > 5 then
                PlayerOne (score + 1)
            else
                player

        PlayerTwo score ->
            if x <= 5 then
                PlayerTwo (score + 1)
            else
                player


movePaddle : Paddle -> Speed -> Paddle
movePaddle paddle { cY } =
    let
        { position } =
            paddle

        { y } =
            position

        newPosition =
            { position | y = clamp 5 395 (y + cY) }
    in
        { paddle | position = newPosition }


moveCorrectPaddle : KeyCode -> Speed -> Paddle -> Paddle
moveCorrectPaddle code speed paddle =
    if List.member code [ wCode, sCode ] then
        case paddle.owner of
            PlayerOne _ ->
                movePaddle paddle speed

            PlayerTwo _ ->
                paddle
    else
        case paddle.owner of
            PlayerTwo _ ->
                movePaddle paddle speed

            PlayerOne _ ->
                paddle


handleKeys : KeyCode -> Model -> Model
handleKeys code state =
    if code == rCode then
        initState
    else if List.member code [ wCode, sCode, upArrowCode, downArrowCode ] then
        let
            speed =
                if code == wCode || code == upArrowCode then
                    { cX = 0, cY = -5 }
                else if code == sCode || code == downArrowCode then
                    { cX = 0, cY = 5 }
                else
                    { cX = 0, cY = 0 }
        in
            { state | paddles = List.map (moveCorrectPaddle code speed) state.paddles }
    else
        state


update : Msg -> Model -> ( Model, Cmd Msg )
update msg state =
    case msg of
        NoP ->
            ( state
            , Cmd.none
            )

        KeyDown code ->
            ( handleKeys code state, Cmd.none )

        Tick t ->
            let
                ball =
                    state.ball

                ballOk =
                    isBallLegal ball.position

                timeDelta =
                    if state.lastTick /= 0 then
                        t - state.lastTick
                    else
                        0
            in
                if ballOk then
                    let
                        paddleCollisions =
                            List.map (hasCollided ball.ballSpeed ball.position) state.paddles

                        sideCollisions =
                            hasSideCollisions ball.position ball.ballSpeed

                        newSpeed =
                            (handleSpeed ball.ballSpeed <|
                                List.any identity paddleCollisions
                            )
                                sideCollisions

                        newBall =
                            { ball
                                | position = updatePosition timeDelta ball
                                , ballSpeed = newSpeed
                            }
                    in
                        ( { state
                            | ball = newBall
                            , lastTick = t
                          }
                        , Cmd.none
                        )
                else
                    ( { state
                        | ball = initialBall
                        , paddles = handleScore ball.position state.paddles
                      }
                    , Cmd.none
                    )


boardHeight : String
boardHeight =
    "300"


boardWidth : String
boardWidth =
    "450"



-- View Function State -> (???, ???)


renderPaddle : Paddle -> Html Msg
renderPaddle paddle =
    rect
        [ x <| toString paddle.position.x
        , y <| toString paddle.position.y
        , width "5"
        , height <| toString paddle.width
        , fill paddle.color
        ]
        []


renderScore : Paddle -> Html Msg
renderScore { owner } =
    case owner of
        PlayerOne score ->
            div [] [ text <| "Player One: " ++ toString score ]

        PlayerTwo score ->
            div [] [ text <| "Player Two: " ++ toString score ]


view : Model -> Html Msg
view { ball, paddles } =
    div
        []
    <|
        [ svg
            [ width boardWidth, height boardHeight ]
          <|
            [ rect
                [ width boardWidth
                , height boardHeight
                , x "0"
                , y "0"
                , fill "black"
                ]
                []
            ]
                ++ List.map renderPaddle paddles
                ++ [ circle
                        [ cx <| toString ball.position.x
                        , cy <| toString ball.position.y
                        , r "5"
                        , fill ball.ballColor
                        ]
                        []
                   ]
        ]
            ++ List.map renderScore paddles



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every timeToPoll Tick
        , downs KeyDown
        ]



-- main function to do all the things.


main : Program Never Model Msg
main =
    Html.program
        { init = ( initState, Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
