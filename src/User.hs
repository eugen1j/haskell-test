{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}

module User where

import Prelude ()
import Prelude.Compat

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

data User = User
  { id :: Int
  , name :: String
  } deriving (Eq, Show, Generic)

instance ToJSON User where

instance FromJSON User

type UsersAPI =
       Get '[JSON] [User] -- list users
  :<|> ReqBody '[JSON] User :> PostNoContent -- add a user
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
            users <- decode (liftIO (readFile "users.txt"))
            return users

        newUser :: User -> Handler NoContent
        newUser = error "..."

        userOperations userid =
          viewUser userid :<|> updateUser userid :<|> deleteUser userid

          where
            viewUser :: Int -> Handler User
            viewUser = error ("Cannot view user #" ++ show userid)

            updateUser :: Int -> User -> Handler NoContent
            updateUser = error ("Cannot update user #" ++ show userid)

            deleteUser :: Int -> Handler NoContent
            deleteUser = error ("Cannot delete user #" ++ show userid)

userAPI :: Proxy UsersAPI
userAPI = Proxy

app4 :: Application
app4 = serve userAPI usersServer

startApp :: IO ()
startApp = run 8081 app4