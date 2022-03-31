{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
module Paths_testproj (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/Users/macbook/Haskell/eugen1j/testproj/.stack-work/install/x86_64-osx/d44cbbb1cc35e9c00c7087f36eef411d3e58daf1a6d60b8d3ee2c4e5b3ed11b3/8.10.7/bin"
libdir     = "/Users/macbook/Haskell/eugen1j/testproj/.stack-work/install/x86_64-osx/d44cbbb1cc35e9c00c7087f36eef411d3e58daf1a6d60b8d3ee2c4e5b3ed11b3/8.10.7/lib/x86_64-osx-ghc-8.10.7/testproj-0.1.0.0-73KdZf4vUWSGlmTzeg2xri"
dynlibdir  = "/Users/macbook/Haskell/eugen1j/testproj/.stack-work/install/x86_64-osx/d44cbbb1cc35e9c00c7087f36eef411d3e58daf1a6d60b8d3ee2c4e5b3ed11b3/8.10.7/lib/x86_64-osx-ghc-8.10.7"
datadir    = "/Users/macbook/Haskell/eugen1j/testproj/.stack-work/install/x86_64-osx/d44cbbb1cc35e9c00c7087f36eef411d3e58daf1a6d60b8d3ee2c4e5b3ed11b3/8.10.7/share/x86_64-osx-ghc-8.10.7/testproj-0.1.0.0"
libexecdir = "/Users/macbook/Haskell/eugen1j/testproj/.stack-work/install/x86_64-osx/d44cbbb1cc35e9c00c7087f36eef411d3e58daf1a6d60b8d3ee2c4e5b3ed11b3/8.10.7/libexec/x86_64-osx-ghc-8.10.7/testproj-0.1.0.0"
sysconfdir = "/Users/macbook/Haskell/eugen1j/testproj/.stack-work/install/x86_64-osx/d44cbbb1cc35e9c00c7087f36eef411d3e58daf1a6d60b8d3ee2c4e5b3ed11b3/8.10.7/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "testproj_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "testproj_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "testproj_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "testproj_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "testproj_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "testproj_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
