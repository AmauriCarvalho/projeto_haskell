{-# LANGUAGE EmptyCase #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}

module Common.Route where

{- -- You will probably want these imports for composing Encoders.
import Prelude hiding (id, (.))
import Control.Category
-}

import Data.Text (Text)
import Data.Functor.Identity

import Data.Text (Text, unpack)
import Data.Function

import Obelisk.Route
import Obelisk.Route.TH

data BackendRoute :: * -> * where
  -- | Used to handle unparseable routes.
  BackendRoute_Missing :: BackendRoute ()
  BackendRoute_BrasilCar :: BackendRoute ()
  BackendRoute_ListarBr :: BackendRoute ()
  BackendRoute_BuscarBr :: BackendRoute Int
  BackendRoute_EditarBr :: BackendRoute Int
  BackendRoute_JapanCar :: BackendRoute ()
  BackendRoute_ListarJp :: BackendRoute ()
  BackendRoute_BuscarJp :: BackendRoute Int
  BackendRoute_EditarJp :: BackendRoute Int
  BackendRoute_EuropeCar :: BackendRoute ()
  BackendRoute_ListarEu :: BackendRoute ()
  BackendRoute_BuscarEu :: BackendRoute Int
  BackendRoute_EditarEu :: BackendRoute Int
  -- You can define any routes that will be handled specially by the backend here.
  -- i.e. These do not serve the frontend, but do something different, such as serving static files.

data FrontendRoute :: * -> * where
  FrontendRoute_Main :: FrontendRoute ()
  -- This type is used to define frontend routes, i.e. ones for which the backend will serve the frontend.

fullRouteEncoder
  :: Encoder (Either Text) Identity (R (FullRoute BackendRoute FrontendRoute)) PageName
fullRouteEncoder = mkFullRouteEncoder
  (FullRoute_Backend BackendRoute_Missing :/ ())
  (\case
      BackendRoute_Missing -> PathSegment "missing" $ unitEncoder mempty
      BackendRoute_BrasilCar -> PathSegment "brasilcar" $ unitEncoder mempty
      BackendRoute_ListarBr -> PathSegment "listarbr" $ unitEncoder mempty
      BackendRoute_BuscarBr -> PathSegment "buscarbr" readShowEncoder
      BackendRoute_EditarBr -> PathSegment "editarbr" readShowEncoder
      BackendRoute_JapanCar -> PathSegment "japancar" $ unitEncoder mempty
      BackendRoute_ListarJp -> PathSegment "listarjp" $ unitEncoder mempty
      BackendRoute_BuscarJp -> PathSegment "buscarjp" readShowEncoder
      BackendRoute_EditarJp -> PathSegment "editarjp" readShowEncoder
      BackendRoute_EuropeCar -> PathSegment "europecar" $ unitEncoder mempty
      BackendRoute_ListarEu -> PathSegment "listareu" $ unitEncoder mempty
      BackendRoute_BuscarEu -> PathSegment "buscareu" readShowEncoder
      BackendRoute_EditarEu -> PathSegment "editareu" readShowEncoder)
  (\case
      FrontendRoute_Main -> PathEnd $ unitEncoder mempty)
checFullREnc :: Encoder Identity Identity (R (FullRoute BackendRoute FrontendRoute)) PageName
checFullREnc = checkEncoder fullRouteEncoder & \case
  Left err -> error $ unpack err
  Right encoder -> encoder
concat <$> mapM deriveRouteComponent
  [ ''BackendRoute
  , ''FrontendRoute
  ]
