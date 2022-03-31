{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}

{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}

module User where

import Prelude (
  (==),
  (/=)
  )
import Prelude.Compat
    ( (++),
      ($),
      Eq,
      Monad(return),
      Show(show),
      Int,
      IO,
      error,
      writeFile,
      String )

import System.IO.Strict (readFile)
import Control.Monad.Except
import Control.Monad.Reader
import Data.Aeson
import Data.Aeson.Types
import Data.Attoparsec.ByteString
import Data.ByteString (ByteString)
import Data.List
import Data.Maybe
import Data.String.Conversions
import Data.Time.Calendar
import GHC.Generics
import Lucid
import Network.HTTP.Media ((//), (/:))
import Network.Wai
import Network.Wai.Handler.Warp
import Servant
import System.Directory
import Text.Blaze
import Text.Blaze.Html.Renderer.Utf8
import Servant.Types.SourceT (source)
import qualified Data.Aeson.Parser
import qualified Text.Blaze.Html
import Data.ByteString.Lazy.Char8 (pack, unpack)

data User = User
  { id :: Int
  , name :: String
  } deriving (Eq, Show, Generic)

instance ToJSON User where

instance FromJSON User

type UsersAPI =
       Get '[JSON] [User] -- list users
  :<|> ReqBody '[JSON] User :> PostNoContent  -- add a user
  :<|> Capture "userid" Int :>
         ( Get '[JSON] User -- view a user
      :<|> ReqBody '[JSON] User :> PutNoContent -- update a user
      :<|> DeleteNoContent -- delete a user
         )

newtype FileContent = FileContent
  { content :: String }
  deriving Generic

instance ToJSON FileContent

usersServer :: Server UsersAPI
usersServer = getUsers :<|> newUser :<|> userOperations

  where getUsers :: Handler [User]
        getUsers = do
          content <- liftIO $ readFile "users.txt"
          return $ fromMaybe [] $ decode $ pack content

        newUser :: User -> Handler NoContent
        newUser user = do
          content <- liftIO $ readFile "users.txt"
          let users = fromMaybe [] $ decode $ pack content
          liftIO $ writeFile "users.txt" $ unpack $ encode $ users ++ [user]
          return NoContent

        userOperations userid =
          viewUser userid :<|> updateUser userid :<|> deleteUser userid

          where
            viewUser :: Int -> Handler User
            viewUser userId = do
              content <- liftIO $ readFile "users.txt"
              let users = fromMaybe [] $ decode $ pack content
              let filtered = filter (\user -> id user == userId) users
              
              case filtered of
                [] -> throwError err404
                _ -> return $ head filtered      

            updateUser :: Int -> User -> Handler NoContent
            updateUser userId user = do
              content <- liftIO $ readFile "users.txt"
              let users = fromMaybe [] $ decode $ pack content
                  filtered = filter (\user -> id user == userId) users
                  changed = map (\u -> if id u == userId then user else u) users
              liftIO $ writeFile "users.txt" $ unpack $ encode changed
              case filtered of
                [] -> throwError err404
                _ -> return NoContent

            deleteUser :: Int -> Handler NoContent
            deleteUser userId = do
              content <- liftIO $ readFile "users.txt"
              let users :: [User] = fromMaybe [] $ decode $ pack content
              let filtered = filter (\user -> id user /= userId) users
              liftIO $ writeFile "users.txt" $ unpack $ encode filtered
              return NoContent


userAPI :: Proxy UsersAPI
userAPI = Proxy

app4 :: Application
app4 = serve userAPI usersServer

startApp :: IO ()
startApp = run 8081 app4