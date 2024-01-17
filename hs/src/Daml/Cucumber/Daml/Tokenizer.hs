-- |

module Daml.Cucumber.Daml.Tokenizer where

import Data.Text (Text)
import qualified Data.Text as T

data Token
  = Identifier Text
  | BeginComment
  | TypeArrow
  | Arrow
  | Do
  | Equals
  | Colon
  | LineBreak
  deriving (Eq, Show)

tokenToText :: Token -> Text
tokenToText = \case
  Identifier n -> n
  BeginComment -> "--"
  TypeArrow -> "=>"
  Arrow -> "->"
  Do -> "do"
  Equals-> "="
  Colon-> ":"
  LineBreak-> "\n" -- TODO do we care about unix/linux

tokenize :: Text -> [Token]
tokenize input
  | T.null input = []
  | T.isPrefixOf "--" token = BeginComment : tokenize (T.drop 2 token)
  | T.isPrefixOf "\n" token || T.isPrefixOf "\r" token = let
      withoutBreaks = T.dropWhile (flip elem lineBreaks) token
      in
      LineBreak : tokenize withoutBreaks

  | T.isPrefixOf ":" token = Colon : tokenize (T.drop 1 token)
  | T.isPrefixOf "=" token = Equals : tokenize (T.drop 1 token)
  | T.isPrefixOf "->" token = Arrow : tokenize (T.drop 2 token)
  | T.isPrefixOf "=>" token = TypeArrow : tokenize (T.drop 2 token)
  | T.isPrefixOf "do" token = Do : tokenize (T.drop 2 token)
  | otherwise = case ident of
      "" -> tokenize $ T.drop 1 token
      _ -> Identifier ident : tokenize rest
  where
    token = T.dropWhile (flip elem defaultSpaces) input
    ident = T.takeWhile (not . flip elem defaultSpacesWithColonAndBreaks) token
    rest = T.drop (T.length ident) token

defaultSpaces :: String
defaultSpaces = " "

lineBreaks :: String
lineBreaks = "\n\r"

defaultSpacesWithColonAndBreaks :: String
defaultSpacesWithColonAndBreaks = "\n\r :"
