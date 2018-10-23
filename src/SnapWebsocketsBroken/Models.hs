{-# LANGUAGE DeriveGeneric, StandaloneDeriving, DeriveAnyClass #-}
module SnapWebsocketsBroken.Models where

import OurPrelude

import Data.Scientific (Scientific)
import Data.Aeson (ToJSON, FromJSON)

data SearchRequest =
  SearchRequest
  { query :: Text
  , shipping_country :: Text
  }
  deriving (Eq, Show, Generic, FromJSON)

data ExampleProduct = ExampleProduct
 {name :: Maybe Text
 , price :: Scientific
 }
  deriving (Eq, Show, Generic, ToJSON)

data SearchResponse =
  ProductResponse ExampleProduct
  | FinishedResponding
  deriving (Eq, Show, Generic, ToJSON)

