module Spotify exposing (..)

import Album
import Country
import Http
import Json.Decode exposing (..)
import QueryString as QS
import RemoteData
import Types exposing (..)


baseUrl : String
baseUrl =
    "https://ms-api.fullyforged.com/search/spotify"


artistDecoder : Decoder String
artistDecoder =
    index 0 (field "name" string)


imgDecoder : Decoder String
imgDecoder =
    (field "url" string)


idDecoder : Decoder Int
idDecoder =
    map2 Album.hash
        (field "artists" artistDecoder)
        (field "name" string)


providerTransformer : Url -> List Provider
providerTransformer url =
    [ Spotify url ]


albumDecoder : Decoder Album
albumDecoder =
    map7 Album
        idDecoder
        (field "name" string)
        (field "artists" artistDecoder)
        (field "images" (index 2 (imgDecoder)))
        (field "images" (index 1 (imgDecoder)))
        (succeed Nothing)
        (at [ "external_urls", "spotify" ] (map providerTransformer string))


albumSearchDecoder : Decoder (List Album)
albumSearchDecoder =
    at [ "albums", "items" ] (list albumDecoder)


albumSearch : String -> Country -> Cmd Msg
albumSearch q country =
    let
        params =
            QS.empty
                |> QS.add "q" q
                |> QS.add "type" "album"
                |> QS.add "market" (Country.toString country)
                |> QS.render
    in
        Http.get (baseUrl ++ params) albumSearchDecoder
            |> RemoteData.sendRequest
            |> Cmd.map SearchResult
