module Autolib.Exp.Read where

import Autolib.Exp.Type
import Autolib.Symbol

import Data.Char

import Autolib.Reader

import Text.ParserCombinators.Parsec
import Text.ParserCombinators.Parsec.Expr

import Autolib.Exp.MyTokens

----------------------------------------------------
express :: Symbol c
	=> Parser (RX c, String)
express = do 
    whiteSpace
    x <- expression
    rest <- getInput
    return (x, rest)

expression :: Symbol c => Parser (RX c)
expression =  buildExpressionParser operators catenation

operators =
    [ [ op "*" Dot          AssocLeft 
      , op "\\" Left_Quotient     AssocLeft 
      , op "/" Right_Quotient     AssocLeft 
      ]
    , [ op "$" Shuffle      AssocLeft ]
    , [ op "&" Intersection AssocLeft ]
    , [ op "+" Union AssocLeft
      , op "-" Difference AssocLeft  
      , op "<>" SymDiff AssocLeft  
      ]
    ]
    where
      op name f assoc   = 
	 Infix ( do { symbol name; return f }  ) assoc

catenation :: Symbol c => Parser (RX c)
catenation = do
    ps <- many1 monomial
    return $ foldr1 Dot ps

monomial :: Symbol c => Parser (RX c)
monomial = do
    x <- atom
    fs <- many $
	    do symbol "^" 
	       (     do symbol  "+" ; return $ PowerPlus  
		 <|> do symbol  "*" ; return $ PowerStar   
		 <|> do e <- natural; return $ Power e
		     -- TODO: "hoch mod n"
                 <|> do symbol "omega" ; return $ PowerOmega    
		 ) 
    return $ foldl (.) id (reverse fs) $ x

atom :: Symbol c => Parser (RX c)
atom =      do b <- basic ; whiteSpace; return b
       <|>  parens expression 

basic :: Symbol c => Parser (RX c)
basic = do c <- satisfy isUpper 
	   cs <- many alphaNum
	   return $ Ref (c : cs)
    <|> do x <- symbol_reader
	   return $ Letter x

--------------------------------------------------------------------------

instance Symbol c => Reader (RX c) where
    readerPrec p = expression






