module Reporter.Boolean.Eval where

--  $Id$

import Reporter.Boolean.Data
import Reporter.Type
import Reporter.Stream
import Reporter.Iterator
import Reporter.Proof

import Output
import ToDoc

build :: Boolean ( Iterator Proof )
     -> Reporter.Stream.Type
build f @ ( Atomic i ) = make ( toDoc f ) i
build f @ ( Uf up x ) = 
    let fun = case up of 
	    Not -> nicht ; Success -> erfolg
    in  fun ( toDoc f ) $ build x
build f @ ( Bof op xs ) = 
    let fun = case op of 
	    And -> und ; Or -> oder ; Par -> erster
    in  fun ( toDoc f ) $ map build xs

eval :: Boolean ( Iterator Proof )
     -> Reporter ( Either Output Proof )
eval = exec . build



