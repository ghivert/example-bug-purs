module Main where

import Prelude

import Data.Maybe (Maybe(..), maybe)
import Data.Nullable (Nullable)
import Data.Nullable as Nullable
import Effect (Effect)
import Effect.Class.Console as Console
import Effect.Exception (throw)
import Effect.Unsafe (unsafePerformEffect)
import React.Basic.DOM (render)
import React.Basic.DOM as DOM
import React.Basic.Events (handler_)
import React.Basic.Hooks (type (/\), Component, ReactContext, component, useEffectOnce, useReducer, (/\))
import React.Basic.Hooks as RB
import React.Basic.Hooks as React
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML as HTML
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window as Window

type User = { uid :: String }

foreign import foreignAuthStateChanged :: (Nullable User -> Unit) -> Effect (Effect Unit)
foreign import foreignSignInWithPopup :: String -> Array String -> Effect Unit
foreign import foreignSignOut :: Effect Unit

type State = { user :: Maybe User}
data Action
  = UpdateUser (Maybe User)

init :: State
init = { user: Nothing }

reduce :: State -> Action -> State
reduce state (UpdateUser user) =
  let _ = unsafePerformEffect $ Console.warn "UpdateUser" in
  state { user = user }

onAuthStateChanged :: (Maybe User -> Effect Unit) -> Effect (Effect Unit)
onAuthStateChanged callback =
  foreignAuthStateChanged $ Nullable.toMaybe >>> callback >>> unsafePerformEffect

context :: ReactContext (State /\ (Action -> Effect Unit))
context =
  unsafePerformEffect
  $ RB.createContext
  $ init /\ (const $ Console.warn "Nothing implemented")

mkApp :: Component Unit
mkApp = do
  component "App" \props -> React.do
    store <- useReducer init reduce
    let state /\ dispatch = store
    useEffectOnce $ onAuthStateChanged $ \user -> do
      Console.warn "Dispatching"
      dispatch $ UpdateUser user
    pure $ RB.provider context store
      [ DOM.pre_ [DOM.text $ show state.user]
      , DOM.button
        { onClick: handler_ $ maybe (foreignSignInWithPopup "Google" ["openid"]) (const foreignSignOut) state.user
        , children:
          [ DOM.text $ maybe "Connect" (const "Disconnect") state.user]
        }
      ]

main :: Effect Unit
main = do
  document <- Window.document =<< HTML.window
  container <- getElementById "app" $ toNonElementParentNode document
  case container of
    Nothing -> throw "No Element \"app\" found."
    Just node -> do
      root <- mkApp
      render (root unit) node
