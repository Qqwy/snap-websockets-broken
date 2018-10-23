module OurPrelude (module Protolude, module Pipe, module Control.Arrow,  concat, andThen) where

import Protolude hiding (concat)
import Pipe
import Control.Arrow ((>>>))


concat :: Monoid a => [a] -> a
concat = mconcat

{-| Non-cryptic naming for =<<,
    which is nicely pipeable!
|-}
andThen :: Monad m => (a -> m b) -> m a -> m b
andThen = (=<<)
