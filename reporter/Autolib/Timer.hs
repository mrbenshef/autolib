module Autolib.Timer where

import Autolib.Reporter.Type
import Autolib.Output
import Control.Concurrent
import Control.Exception

-- | if timer expires,
-- insert default result

timed_run :: Render r
	  => Int -- ^ wait that many seconds
	  -> Reporter a -- ^ default reporter
	  -> Reporter a -- ^ time-consuming reporter
	  -> IO ( Maybe a, r )
timed_run d def r = do
    (a,o) <- timed d ( run  def) $ run r
    return ( a, render o )

-- | TODO: das ist eventuell zu lazy?
-- wenn die action einen nicht ganz ausgewerteten wert schreibt?

timed :: Int -> IO a -> IO a -> IO a
timed d def action = do
    ch <- newChan

    apid <- forkIO $ do
         x <- action
	 writeChan ch x

    tpid <- forkIO $ do
         sleep d
         y <- def
	 writeChan ch y

    x <- readChan ch
    let ignore act = Control.Exception.catch act 
          $ \ ( _ :: SomeException) -> return () 
    ignore $ killThread apid 
    ignore $ killThread tpid 
    return x

sleep d = sequence_ $ do
             i <- [ 1 .. d ]
	     return $ do threadDelay $ 10^6
			 yield


