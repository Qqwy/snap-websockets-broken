module Waldbooks.HttpClient where

import OurPrelude


import qualified Network.Http.Client
import qualified System.IO.Streams as Streams
import qualified Blaze.ByteString.Builder as Builder
import qualified Snap.Core

get :: ByteString -> [(ByteString, ByteString)] -> IO LByteString
get url params = do
  let full_url = buildUrl url params
  putText $ toS full_url
  Network.Http.Client.get full_url lazyConcatHandler

buildUrl :: ByteString -> [(ByteString, ByteString)] -> ByteString
buildUrl url params =
  let
    params_str = params
                 |> map (\(key, val) -> key <> "=" <> Snap.Core.urlEncode(val))
                 |> intersperse "&"
                 |> concat
  in
    url <> params_str

lazyConcatHandler :: Network.Http.Client.Response -> Streams.InputStream ByteString -> IO LByteString
lazyConcatHandler _ i1 = do
    i2 <- Streams.map Builder.fromByteString i1
    x <- Streams.fold mappend mempty i2
    return $ Builder.toLazyByteString x
