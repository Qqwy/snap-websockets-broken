module SnapWebsocketsBroken (site) where

import OurPrelude

import           Control.Applicative ((<|>))

import           Snap.Core (Snap, route, ifTop, dir, redirect)
import qualified Snap.Core
import           Snap.Util.FileServe (serveFile, serveDirectory)

import qualified SnapWebsocketsBroken.WebSockets

import Control.Monad (void)

site :: Snap ()
site = do
  (websocket_route <|>
   frontend_routes)
  where
    websocket_route =
      route [("ws", SnapWebsocketsBroken.WebSockets.handler)]
    frontend_routes =
      ifTop (serveFile "./public/index.html") <|>
      route
        [ (":unknown", serveFile "./public/index.html")
        ]
