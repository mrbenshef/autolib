{-# LANGUAGE TemplateHaskell, OverlappingInstances, IncoherentInstances #-}

--   $Id$

module Autolib.ENFA.Data

( module Autolib.ENFA.Data
, NFAC
, module Autolib.Informed
, module Autolib.FiniteMap
, module Autolib.Set
)

where

import Autolib.Size
import Autolib.Letters

import Autolib.NFA.Data ( NFAC )
import qualified Autolib.Relation

import Autolib.ToDoc
import Autolib.Informed
import Autolib.Set
import Autolib.FiniteMap
import Autolib.Reader
import Autolib.Hash

import Autolib.Symbol

import Control.Monad (guard)
import Data.Typeable

type Trans c s =  FiniteMap s ( FiniteMap c ( Set s ))

data NFAC c s => ENFA c s = ENFA 
         { enfa_info   :: Doc   -- ^ wird nicht gelesen und auch nicht geprintet
	 , alphabet :: Set c
	 , states :: Set s
	 , starts :: Set s
	 , finals :: Set s

	 -- , trans  :: FiniteMap (s, c) (Set s)
	 , trans :: Trans c s
	 , mirror_trans :: Trans c s

	 , eps :: Autolib.Relation.Type s s 
	 , mirror_eps :: Autolib.Relation.Type s s 

	 -- | yes: is transitive and reflexive
	 , eps_is_trans_reflex :: Bool
	 }
    deriving Typeable


mirror :: NFAC c s
       => ENFA c s
       -> ENFA c s
mirror a = a { trans = mirror_trans a
	     , mirror_trans = trans a
	     , eps = mirror_eps a
	     , mirror_eps = eps a
	     }

tcollect :: NFAC c s 
	 => [ (s, c, s) ] 
	 -> Trans c s
tcollect pcqs = addListToFM_C ( plusFM_C union ) emptyFM $ do
    ( p, c, q ) <- pcqs
    return ( p, listToFM [ (c, unitSet q) ] )

mitcollect :: NFAC c s 
	 => [ (s, c, s) ] 
	 -> Trans c s
mitcollect pcqs = tcollect $ do (p,c,q) <- pcqs ; return (q,c,p)

tunCollect :: NFAC c s
	   => Trans c s
	   -> [ (s, c, s) ]
tunCollect t = do
    ( p, fm ) <- fmToList t
    ( c, qs ) <- fmToList fm   
    q <- setToList qs
    return ( p, c, q )


{-# DEPRECATE eps #-}

$(derives [makeReader, makeToDoc] [''ENFA])

lstates :: NFAC c a => ENFA c a -> [ a ]
lstates = setToList . states
lstarts :: NFAC c a => ENFA c a -> [ a ]
lstarts = setToList . starts
lfinals :: NFAC c a => ENFA c a -> [ a ]
lfinals = setToList . finals

eclosure :: NFAC c s => ENFA c s -> s -> Set s
eclosure a =
    if eps_is_trans_reflex a 
    then Autolib.Relation.images              (eps a)
    else Autolib.Relation.trans_reflex_images (eps a)

leclosure :: NFAC c s => ENFA c s -> s -> [s]
leclosure a = setToList . eclosure a 

instance NFAC c s    => Informed (ENFA c s) where
    info = enfa_info
    informed i a = a { enfa_info = i }

instance NFAC c s    => Size (ENFA c s) where 
    size = cardinality . states

instance NFAC c s    => Hash ( ENFA c s ) where
    hash  = hash . essence

instance NFAC c s    => Eq ( ENFA c s ) where
    a == b  =  essence a == essence b

essence a = ( states a, starts a, finals a, trans a 
	    , Autolib.Relation.pairs $ eps a 
	    -- FIXME: what if they're not transitive
	    )


-- Local Variables:
-- mode: haskell
-- End:

