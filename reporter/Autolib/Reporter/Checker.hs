module Reporter.Checker where

--  $Id$

import Reporter.Type
import ToDoc
import Data.Maybe ( isJust )

data Type a =
     Make { nametag :: String
	     , condition :: Doc
	     , investigate :: a -> Reporter ()
	     }

instance Show ( Type a ) where 
    show = nametag

make :: String
	-> Doc 
	-> ( a -> Reporter () ) 
	-> Type a
make tag doc inv = Make { nametag = tag, condition = doc, investigate = inv }

wahr :: Type a
wahr = make "wahr" empty ( const $ return () )

-- | condition drucken, dann auswerten
run :: Type a -> a -> Reporter ()
run c g = do
    inform $ condition c
    nested 4 $ investigate c g

eval :: Type a -> a -> Bool
eval c g = 
    let ( mr, _ :: Doc ) = export $ investigate c g
    in	isJust mr

-- | beides ausf�hren, 
-- aber kurznamen nur vom rechten anzeigen
and_then :: Type a -> Type a
     -> Type a
and_then l r = Make
	 { nametag = nametag r
	 , condition = condition r
	 , investigate = \ a -> do
	       Reporter.Checker.run l a
	       Reporter.Checker.run r a
         }



