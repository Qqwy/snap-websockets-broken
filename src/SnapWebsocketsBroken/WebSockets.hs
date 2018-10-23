module SnapWebsocketsBroken.WebSockets (handler) where

import OurPrelude hiding (product)


import Data.String (String) -- Only used for internal parsing error messages!

import qualified Data.Aeson
import Data.Aeson (FromJSON, ToJSON)

import           Snap.Core (Snap)

import qualified Network.WebSockets
import Network.WebSockets (DataMessage)
import qualified Network.WebSockets.Snap

import qualified Control.Concurrent.Async as Async
import Data.Void (Void)

import SnapWebsocketsBroken.Models (SearchRequest(..), SearchResponse(..), ExampleProduct(..))
import qualified SnapWebsocketsBroken.ExampleFetcher

handler :: Snap ()
handler = Network.WebSockets.Snap.runWebSocketsSnap $ \pendingConn -> do
  putText $ "New Websocket connection!"
  conn <- Network.WebSockets.acceptRequest pendingConn
  Network.WebSockets.forkPingThread conn 10
  up <- receiveJSON conn
  handleWebsocketRequest conn up
  return ()

{-|
Implementation is slightly messy,
because we want to cancel a request whenever a new request comes in.
|-}
handleWebsocketRequest :: Network.WebSockets.Connection -> Either String SearchRequest -> IO Void
handleWebsocketRequest conn up = do
        putText $ "Received WebSocket message: " <> show up
        up' <- case up of
                  Left e -> do
                    putStrLn $ "Websocket parse error: " ++ e
                    putStrLn $ "On message: " ++ show up
                    up' <- receiveJSON conn
                    return up'
                  Right (search_request :: SearchRequest) -> do
                    putText $ "Fetching answers for request " <> show (query search_request)
                    either_res <- Async.race (receiveJSON conn) (returnResults conn search_request)
                    case either_res of
                      Left up' -> do
                        putText "Request cancelled by new incoming request"
                        return up'
                      Right _ -> do
                        putText $ "Finished serving WebSocket request " <> show search_request
                        up' <- receiveJSON conn
                        return up'
        handleWebsocketRequest conn up'

returnResults :: Network.WebSockets.Connection -> SearchRequest -> IO ()
returnResults conn search_request = do
  fetchAllProductsAsync_ search_request $ \(name, products) -> do
    putText $ "Look: " <> show products
    forM_ products (\product -> do
                      putText $ toS $ Data.Aeson.encode product
                      sendJSON conn (ProductResponse product))
    putText $ name <> ": Found " <> show (length products) <> " different products matching " <> show search_request <> "."
    sendJSON conn (FinishedResponding)
    putText $ "Finished sending results of provider " <> name


receiveJSON :: FromJSON a => Network.WebSockets.Connection -> IO (Either String a)
receiveJSON conn = do
    dm <- Network.WebSockets.receiveDataMessage conn
    let json = dm
          |> dataToByteString
          |> Data.Aeson.eitherDecode'
    return json

sendJSON :: ToJSON a => Network.WebSockets.Connection -> a -> IO ()
sendJSON conn v = v
                  |> Data.Aeson.encode
                  |> Network.WebSockets.sendTextData conn

dataToByteString :: DataMessage -> LByteString
dataToByteString (Network.WebSockets.Text bs _) = bs
dataToByteString (Network.WebSockets.Binary bs) = bs


fetchAllProductsAsync_ :: SearchRequest -> ((Text, [ExampleProduct]) -> IO b) -> IO ()
fetchAllProductsAsync_ search_request action =
  productFetchers
  |> Async.mapConcurrently_ runFetcher
  where
    runFetcher (name, fetcher) = do
      products <- fetcher search_request
      action (name, products)

productFetchers :: [(Text, SearchRequest -> IO [ExampleProduct])]
productFetchers =
  [("ExampleFetcher", SnapWebsocketsBroken.ExampleFetcher.exampleFetch)]
