module Autolib.Relation.Basic where

--   $Id$

import Autolib.Relation.Type
import Autolib.Relation.Ops


empty :: Ord a => Set a -> Type a a
empty s = Make { source = s, target = s
	       , unRelation = emptyFM, inverse_unRelation = emptyFM
	       }

flat :: Ord a => Set a -> Type a a
flat s = reflex $ empty s

linear :: Ord a => [a] -> Type a a
linear xs =
    let s = mkSet xs
    in  reflex_trans $ ( make $ zip xs $ tail xs ) { source = s, target = s }

