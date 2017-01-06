module Spotify exposing (..)

import Json.Decode exposing (..)
import Types exposing (..)
import QueryString as QS
import Http


baseUrl : String
baseUrl =
    "https://api.spotify.com/v1/search"


artistDecoder : Decoder String
artistDecoder =
    index 0 (field "name" string)


thumbDecoder : Decoder Thumb
thumbDecoder =
    map3 Thumb
        (field "width" int)
        (field "height" int)
        (field "url" string)


albumDecoder : Decoder Album
albumDecoder =
    map5 Album
        (field "name" string)
        (field "artists" artistDecoder)
        (at [ "external_urls", "spotify" ] string)
        (field "images" (list thumbDecoder))
        (succeed Spotify)


albumSearchDecoder : Decoder (List Album)
albumSearchDecoder =
    at [ "albums", "items" ] (list albumDecoder)


albumSearch : String -> Cmd Msg
albumSearch q =
    let
        params =
            QS.empty
                |> QS.add "q" ("album:" ++ q)
                |> QS.add "type" "album"
                |> QS.render

        req =
            Http.get (baseUrl ++ params) albumSearchDecoder
    in
        Http.send SearchResult req