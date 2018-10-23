module Main (main) where

import OurPrelude

import qualified Snap.Http.Server
import qualified SnapWebsocketsBroken

main :: IO ()
main = do
  putText "Starting the example server that shows how Snap Websockets do not log all errors!"
  Snap.Http.Server.quickHttpServe SnapWebsocketsBroken.site

