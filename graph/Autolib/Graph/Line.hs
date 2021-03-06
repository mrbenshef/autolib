module Autolib.Graph.Line where

--  $Id$

import Autolib.Graph.Graph

import Autolib.Set

import Autolib.FiniteMap
import Control.Monad ( guard )

line_graph :: ( GraphC a , GraphC ( Kante a ) ) 
	   => Graph a -> Graph ( Kante a )
line_graph g = 
    let v = kanten g
	e = mkSet $ do 
	       [ u, v ] <- teilfolgen 2 $ setToList $ kanten g
	       let inhalt k = mkSet [ von k, nach k ]
	       guard $ not $ isEmptySet $ inhalt u `intersect` inhalt v
	       return $ kante u v
    in Graph { graph_info = funni "L" [ info g ]
	     , graph_texinfo = "{\\mathrm{L}(" ++ texinfo g ++ ")}"
	     , knoten = v
	     , kanten = e 
	     , graph_layout = listToFM $ do 
	           k <- setToList v
		   let u = von k
		       v = nach k
		   let pos = lookupWithDefaultFM 
			     (graph_layout g) (error "edge_graph")
		   return ( k, 0.5 * (pos u + pos v) )
	     , bounding = bounding g         
	     , layout_hints = [  ]
	     , layout_program = Dot
	     , show_labels = False
	     }	       




