module Autolib.ENFA.Link where

--  $Id$

import Autolib.ENFA.Data
import Autolib.ENFA.Op
import qualified Autolib.Relation as Relation
import Control.Monad ( guard )

-- | add completely fresh path
-- if length == 0: add_eps
-- if length == 1: add transition
-- if length  > 1: generating new states 
add_path :: NFAC c Int
     => ENFA c Int
     -> (Int, [c], Int) -- ^  from , labels, to
     -> ENFA c Int
add_path a (from, [], to) = add_eps a [(from, to)]
add_path a (from, w , to) = links a $ do
    let top = maximum $ lstates a
	mids = [ top + 1 .. top + length w - 1 ]
    zip3 ( [ from ] ++ mids ) 
	 w 
	 ( mids ++ [ to ] )
	 
links :: NFAC c a
      => ENFA c a
      -> [ (a, c, a) ]
      -> ENFA c a
links a steps = 
    let qs = mkSet $ do ( p, c, q ) <- steps ; [ p, q ]
        cs = mkSet $ do ( p, c, q ) <- steps ; [ c    ]
    in  a { alphabet = union ( alphabet a ) cs
	  , states   = union ( states   a ) qs
	  , trans    = addListToFM_C ( plusFM_C union ) ( trans a ) $ do
              ( p, c, q ) <- steps
	      return (p, listToFM [(c, unitSet q)] )
	  , mirror_trans    = 
                       addListToFM_C ( plusFM_C union ) ( mirror_trans a ) $ do
              ( p, c, q ) <- steps
	      return (q, listToFM [(c, unitSet p)] )
          , eps        = Relation.plus ( eps a ) ( Relation.empty qs )
          , mirror_eps = Relation.plus ( mirror_eps a ) ( Relation.empty qs )
	  }

link  :: NFAC c a
      => ENFA c a
      -> (a, c, a)
      -> ENFA c a
link a step = links a [ step ]
