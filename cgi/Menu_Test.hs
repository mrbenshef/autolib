-- | start this executable, then browse to http://localhost:8000

import Autolib.CGI
import Happstack.Server

main = simpleHTTP nullConf $ do
    decodeBody ( defaultBodyPolicy "/tmp/" 4096 4096 4096 )
    render menu_test

menu_test = do
   h3 "menu_test"
   (n,c) <- table $ do
       n <- menu "pick a number" [ ("1", 1), ("2", 2), ("3", 3) ]
       c <- menu "pick a letter" [ ("a", 'a'), ("b", 'b'), ("c", 'c') ]
       return (n,c)
   text $ "combined selection:" ++ show (n,c) 
