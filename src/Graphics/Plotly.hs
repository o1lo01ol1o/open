{-# LANGUAGE DeriveGeneric, OverloadedStrings,FlexibleInstances, TemplateHaskell #-}

module Graphics.Plotly where

import Data.Aeson
import Data.Aeson.Types
import Data.Char (toLower)
import Data.List (intercalate, nub, findIndex)
import Data.Monoid ((<>))
import Data.Maybe (fromJust)
import Data.Text (Text)

import GHC.Generics
import Lens.Micro.TH

import Graphics.Plotly.Utils

data Mode = Markers | Lines deriving Show

instance ToJSON [Mode] where
  toJSON = toJSON . intercalate "+" . map (map toLower . show)

data TraceType = Scatter | Bar deriving Show

instance ToJSON TraceType where
  toJSON = toJSON . map toLower . show

data Color = RGBA Int Int Int Int
           | RGB Int Int Int
           | ColIxs [Int]
           | Cols [Color]

instance ToJSON Color where
  toJSON (RGB r g b) = toJSON $ "rgb("<>show r<>","<>show g<>","<>show b<>")"
  toJSON (RGBA r g b a) = toJSON $ "rgba("<>show r<>","<>show g<>","<>show b<>","<> show a<>")"
  toJSON (ColIxs cs) = toJSON cs
  toJSON (Cols cs) = toJSON cs

catColors :: Eq a => [a] -> Color
catColors xs =
  let vals = nub xs
      f x = fromJust $ findIndex (==x) vals
  in ColIxs $ map f xs

data Symbol = Circle | Square | Diamond | Cross deriving Show

instance ToJSON Symbol where
  toJSON = toJSON . map toLower . show


data Marker = Marker
  { _size :: Maybe Int
  , _markercolor :: Maybe Color
  , _symbol :: Maybe Symbol
  , _opacity :: Maybe Double
  } deriving Generic

makeLenses ''Marker

instance ToJSON Marker where
  toJSON = genericToJSON jsonOptions {fieldLabelModifier = rename "markercolor" "color" . unLens}

data Dash = Solid | Dashdot | Dot deriving Show

instance ToJSON Dash where
  toJSON = toJSON . map toLower . show

instance ToJSON Barmode where
  toJSON = toJSON . map toLower . show

data Barmode = Stack | Group deriving Show

data Orientation = Horizontal | Vertical

instance ToJSON Orientation where
  toJSON Horizontal = "h"
  toJSON Vertical = "v"

data Fill = ToZeroY | ToNextY deriving Show

instance ToJSON Fill where
  toJSON = toJSON . map toLower . show


data Line = Line
  { _linewidth :: Maybe Double
  , _linecolor :: Maybe Color
  , _dash :: Maybe Dash
  } deriving Generic

makeLenses ''Line

instance ToJSON Line where
  toJSON = genericToJSON jsonOptions { fieldLabelModifier = dropInitial "line" . unLens}

defLine :: Line
defLine = Line Nothing Nothing Nothing

defMarker :: Marker
defMarker  = Marker Nothing Nothing Nothing Nothing

data Trace = Trace
  { _x :: Maybe [Double]
  , _y :: Maybe [Double]
  , _xtext :: Maybe [Text]
  , _ytext :: Maybe [Text]
  , _mode :: Maybe [Mode]
  , _name :: Maybe Text
  , _text :: Maybe [Text]
  , _tracetype :: TraceType
  , _marker :: Maybe Marker
  , _line :: Maybe Line
  , _fill :: Maybe Fill
  , _orientation :: Maybe Orientation
  } deriving Generic


makeLenses ''Trace

scatter :: Trace
scatter = Trace Nothing Nothing Nothing Nothing Nothing Nothing Nothing Scatter Nothing Nothing Nothing Nothing

bars :: Trace
bars = Trace Nothing Nothing Nothing Nothing Nothing Nothing Nothing Bar Nothing Nothing Nothing Nothing


instance ToJSON Trace where
  toJSON = genericToJSON jsonOptions {fieldLabelModifier = rename "tracetype" "type" . rename "xtext" "x" . rename "ytext" "y" . unLens}


data Axis = Axis
  { _range :: Maybe (Double,Double)
  , _axistitle :: Maybe Text
  , _showgrid :: Maybe Bool
  , _zeroline :: Maybe Bool
  } deriving Generic

makeLenses ''Axis


instance ToJSON Axis where
  toJSON = genericToJSON jsonOptions {fieldLabelModifier = rename "axistitle" "axis" . unLens}

defAxis :: Axis
defAxis = Axis Nothing Nothing Nothing Nothing


data Margin = Margin
  { _marginl :: Int
  , _marginr :: Int
  , _marginb :: Int
  , _margint :: Int
  , _marginpad :: Int
  } deriving Generic

makeLenses ''Margin

instance ToJSON Margin where
  toJSON = genericToJSON jsonOptions { fieldLabelModifier = dropInitial "margin" . unLens}

thinMargins, titleMargins :: Margin
thinMargins = Margin 40 25 30 10 4
titleMargins = Margin 40 25 30 40 4

data Layout = Layout
  { _xaxis :: Maybe (Double,Double)
  , _yaxis :: Maybe (Double,Double)
  , _title :: Maybe Text
  , _showlegend :: Maybe Bool
  , _height :: Maybe Int
  , _width :: Maybe Int
  , _barmode :: Maybe Barmode
  , _margin :: Maybe Margin
  } deriving Generic

makeLenses ''Layout

defLayout :: Layout
defLayout = Layout Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing

instance ToJSON Layout where
  toJSON = genericToJSON jsonOptions

data Plotly = Plotly
  { _traces :: [Trace]
  , _layout :: Layout
  }

makeLenses ''Plotly

plotly :: [Trace] -> Plotly
plotly trs = Plotly trs defLayout
