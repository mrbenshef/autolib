{-# OPTIONS -fallow-overlapping-instances -fallow-undecidable-instances -fglasgow-exts #-}

module Autolib.ToDoc.Class 

( module Autolib.ToDoc.Class
-- , module Text.PrettyPrint.HughesPJ
, module Autolib.Multilingual.Doc
)

where

-- import Text.PrettyPrint.HughesPJ 
import Autolib.Multilingual.Doc

-- | should be re-readable with Reader
class ToDoc a where 
    toDoc :: a -> Doc
    -- default:
    toDoc = toDocPrec 0 -- useful?

    toDocPrec :: Int -> a -> Doc
    -- default:
    toDocPrec p = toDoc -- dangerous?

-- | like ToDoc, but not intended to be re-readable
class ToDoc a => Nice a where 
    nicePrec :: Int -> a -> Doc
    nicePrec p = toDocPrec p

    nice :: a -> Doc
    nice = nicePrec 0

instance ToDoc a => Nice a

{-
-- | mutual default instances
-- so that you only have to define one of them
instance Show a => ToDoc a where 
    toDocPrec p x = text ( showsPrec p x "" )
-}

-- ghc-7.4.1 does not like this because Data.Set is in "safe" mode
-- so we can't overlap their Show instance:
-- instance ToDoc a => Show a where 
--    showsPrec p x cs = render ( toDocPrec p x ) ++ cs

docParen :: Bool -> Doc -> Doc
docParen f = if f then parens else id

-- | zur ausgabe ohne zeilenschaltungen
-- TODO: sollte besser gehen (anderen renderer wählen?)
showDoc :: Doc -> String
showDoc = unwords . words . render


-- | funcall precedence
fcp = 10 :: Int
