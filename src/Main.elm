module Main exposing (main)

import Browser exposing (document)
import Html exposing (button, div, input, text)
import Html.Attributes exposing (placeholder, value)
import Html.Events exposing (onInput, onClick)
import Json.Decode exposing (Decoder, field, string, int, bool, list, succeed)
import Json.Decode.Pipeline exposing (required)
import Http


main =
    document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init () =
    ( initialModel, Cmd.none )


initialModel =
    { name = "Peter"
    , gender = Male
    , todos = []
    }


type alias Model =
    { name : String
    , gender : Gender
    , todos: Todos
    }


type alias Todo =
    { userId : Int
    , id : Int
    , title : String
    , completed : Bool
    }

type alias Todos = List Todo

type Gender
    = Female
    | Male



view model =
    { title = "My First Elm Page!"
    , body =
        [ div []
            [ text model.name
            , div [] [ text "" ]
            , button [onClick RequestTodos] [text "Click Me!"]
            , div []
                <| List.map (\ todo -> text todo.title) model.todos
            ]
        ]
    }


update msg model =
    case msg of
        RequestTodos ->
            (model, performRequestTodos)
        GotTodos result ->
            case result of
                Result.Ok todos -> ({model | todos = todos}, Cmd.none)
                _ -> (model, Cmd.none)

performRequestTodos =
    Http.get
      { url = "https://jsonplaceholder.typicode.com/todos"
      , expect = Http.expectJson GotTodos todosDecoder
      }


subscriptions model =
    Sub.none

todosDecoder = 
    succeed Todo
        |> required "userId" int
        |> required "id" int
        |> required "title" string
        |> required "completed" bool
        |> list



type Message = RequestTodos | GotTodos (Result Http.Error Todos)
