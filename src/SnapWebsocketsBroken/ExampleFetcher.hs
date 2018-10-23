{-# LANGUAGE QuasiQuotes #-}
module SnapWebsocketsBroken.ExampleFetcher where

import OurPrelude

import qualified Data.Maybe

import Text.RawString.QQ -- Used for example XML snippet
import Data.String (String) -- Only used for TagSoup matcher

import qualified Text.HTML.TagSoup as TagSoup
import Text.HTML.TagSoup ((~==), (~/=), Tag(TagOpen))

import qualified Debug

import SnapWebsocketsBroken.Models (SearchRequest(..), ExampleProduct(..))

exampleFetch :: SearchRequest -> IO [ExampleProduct]
exampleFetch _ =
  fakeXML
  |> parseProducts
  |> Data.Maybe.catMaybes
  |> return
  -- let result_of_remote_request = "[]"
  -- let res = [ ExampleProduct {name = "Test42", price= 10}
  --           , ExampleProduct {name = "Test2", price= 11}
  --           , ExampleProduct {name = "Test3", price= 12}
  --           , ExampleProduct {name = "Test4", price= 13}
  --           , ExampleProduct {name = "Test5", price= 14}
  --           , ExampleProduct {name = "Test6", price= 15}
  --           ]
  -- putText $ show res
  -- return res


fakeXML :: LByteString
fakeXML =
  [r|
 <?xml version="1.0" encoding="UTF-8"?>
<searchResults>
  <resultCount>405168</resultCount>
  <Product>
    <name>Test</name>
    <price>10</price>
  </Product>
  <Product>
    <name>Test 2</name>
    <price>11</price>
  </Product>
  <Product>
    <name>Test 3</name>
    <price>11</price>
  </Product>
  <Product>
    <name>Test 4</name>
    <price>11</price>
  </Product>
  <Product>
    <name>Test 5</name>
    <price>11</price>
  </Product>
  <Product>
    <name>Product with malformed &#195; name</name>
    <price>42</price>
  </Product>
  <Product>
    <name>Another Product. Will never be reached.</name>
    <price>11</price>
  </Product>
  </searchResults>
  |]

parseProducts :: LByteString -> [Maybe ExampleProduct]
parseProducts products_xml =
  products_xml
  |> TagSoup.parseTags
  |> TagSoup.sections (~== ("<Product>" :: String))
  |> map parseProduct

parseProduct :: [TagSoup.Tag LByteString] -> Maybe ExampleProduct
parseProduct product_xml = do
  let name = xmlInnerText "name" product_xml
  price <- xmlRead "price" product_xml

  return ExampleProduct {name = name, price = price}

xmlRead :: Read a => LByteString -> [TagSoup.Tag LByteString] -> Maybe a
xmlRead elem_name xml =
  xmlInnerText elem_name xml
  |> map toS
  |> andThen readMaybe

xmlInnerText :: LByteString -> [TagSoup.Tag LByteString] -> Maybe Text
xmlInnerText elem_name xml = do
  subject <- fetchXMLElem elem_name xml
  subject
    -- |> (\x -> Debug.trace  ("SUBJECT: " <> (show x) :: Text) x)
    |> TagSoup.innerText
    |> toS
    |> return

fetchXMLElem :: LByteString -> [TagSoup.Tag LByteString] -> Maybe [TagSoup.Tag LByteString]
fetchXMLElem elem_name xml =
  let
    subject =
      xml
      |> dropWhile (~/= TagOpen elem_name [])
      |> take 2
  in
    case subject of
      [] -> Nothing
      [_empty_tag] -> Nothing
      [_tag_open, _contents] ->
        Just subject
      _ -> Nothing
