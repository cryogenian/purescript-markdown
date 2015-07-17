module Text.Markdown.SlamDown where

import Prelude
import Data.Maybe
import Data.Monoid
import Data.Function (on)
import Data.List 

data SlamDown = SlamDown (List Block)

instance showSlamDown :: Show SlamDown where
  show (SlamDown bs) = "(SlamDown " ++ show bs ++ ")"
  
instance eqSlamDown :: Eq SlamDown where
  eq = eq `on` show
  
instance ordSlamDown :: Ord SlamDown where
  compare = compare `on` show  
  
instance semigroupSlamDown :: Semigroup SlamDown where
  append (SlamDown bs1) (SlamDown bs2) = SlamDown (bs1 <> bs2)
  
instance monoidSlamDown :: Monoid SlamDown where
  mempty = SlamDown mempty

data Block
  = Paragraph (List Inline)
  | Header Int (List Inline)
  | Blockquote (List Block)
  | Lst ListType (List (List Block))
  | CodeBlock CodeBlockType (List String)
  | LinkReference String String
  | Rule

instance showBlock :: Show Block where
  show (Paragraph is)        = "(Paragraph " ++ show is ++ ")"
  show (Header n is)         = "(Header " ++ show n ++ " " ++ show is ++ ")"
  show (Blockquote bs)       = "(Blockquote " ++ show bs ++ ")"
  show (Lst lt bss)         = "(Lst " ++ show lt ++ " " ++ show bss ++ ")"
  show (CodeBlock ca s)      = "(CodeBlock " ++ show ca ++ " " ++ show s ++ ")"
  show (LinkReference l uri) = "(LinkReference " ++ show l ++ " " ++ show uri ++ ")"
  show Rule                  = "Rule"

data Inline
  = Str String 
  | Entity String 
  | Space
  | SoftBreak  
  | LineBreak  
  | Emph (List Inline)
  | Strong (List Inline)
  | Code Boolean String
  | Link (List Inline) LinkTarget   
  | Image (List Inline) String
  | FormField String Boolean FormField

instance showInline :: Show Inline where
  show (Str s)           = "(Str " ++ show s ++ ")"
  show (Entity s)        = "(Entity " ++ show s ++ ")"
  show Space             = "Space"
  show SoftBreak         = "SoftBreak"
  show LineBreak         = "LineBreak"
  show (Emph is)         = "(Emph " ++ show is ++ ")"
  show (Strong is)       = "(Strong " ++ show is ++ ")"
  show (Code e s)        = "(Code " ++ show e ++ " " ++ show s ++ ")"
  show (Link is tgt)     = "(Link " ++ show is ++ " " ++ show tgt ++ ")"
  show (Image is uri)    = "(Image " ++ show is ++ " " ++ show uri ++ ")"
  show (FormField l r f) = "(FormField " ++ show l ++ " " ++ show r ++ " " ++ show f ++ ")"
   
data ListType = Bullet String | Ordered String

instance showListType :: Show ListType where
  show (Bullet s)   = "(Bullet " ++ show s ++ ")"
  show (Ordered s)  = "(Ordered " ++ show s ++ ")"

instance eqListType :: Eq ListType where
  eq (Bullet s1)  (Bullet s2)  = s1 == s2
  eq (Ordered s1) (Ordered s2) = s1 == s2
  eq _            _            = false


data CodeBlockType 
  = Indented
  | Fenced Boolean String

instance showCodeAttr :: Show CodeBlockType where
  show Indented      = "Indented"
  show (Fenced eval info) = "(Fenced " ++ show eval ++ " " ++ show info ++ ")"
 
data LinkTarget
  = InlineLink String
  | ReferenceLink (Maybe String)

instance showLinkTarget :: Show LinkTarget where
  show (InlineLink uri)    = "(InlineLink " ++ show uri ++ ")"
  show (ReferenceLink tgt) = "(ReferenceLink " ++ show tgt ++ ")"
 
data Expr a
  = Literal a
  | Evaluated String 

instance showExpr :: (Show a) => Show (Expr a) where
  show (Literal a)   = "(Literal " ++ show a ++ ")"
  show (Evaluated s) = "(Evaluated " ++ show s ++ ")"
 
data FormField
  = TextBox        TextBoxType (Expr String)
  | RadioButtons   (Expr String) (Expr (List String))
  | CheckBoxes     (Expr (List Boolean)) (Expr (List String))
  | DropDown       (Expr (List String)) (Expr String)
  
instance showFormField :: Show FormField where
  show (TextBox ty def) = "(TextBox " ++ show ty ++ " " ++ show def ++ ")"
  show (RadioButtons sel ls) = "(RadioButtons " ++ show sel ++ " " ++ show ls ++ ")"
  show (CheckBoxes bs ls) = "(CheckBoxes " ++ show bs ++ " " ++ show ls ++ ")"
  show (DropDown ls def) = "(DropDown " ++ show ls ++ " " ++ show def ++ ")"
 
data TextBoxType = PlainText | Date | Time | DateTime

instance showTextBoxType :: Show TextBoxType where
  show PlainText = "PlainText" 
  show Date      = "Date" 
  show Time      = "Time" 
  show DateTime  = "DateTime" 
 
everywhere :: (Block -> Block) -> (Inline -> Inline) -> SlamDown -> SlamDown
everywhere b i (SlamDown bs) = SlamDown (map b' bs)
  where
  b' :: Block -> Block
  b' (Paragraph is) = b (Paragraph (map i' is))
  b' (Header n is) = b (Header n (map i' is))
  b' (Blockquote bs) = b (Blockquote (map b' bs))
  b' (Lst lt bss) = b (Lst lt (map (map b') bss))
  b' other = b other
  
  i' :: Inline -> Inline
  i' (Emph is)        = i (Emph (map i' is))
  i' (Strong is)      = i (Strong (map i' is))
  i' (Link is uri)    = i (Link (map i' is) uri)
  i' (Image is uri)   = i (Image (map i' is) uri)
  i' other = i other

eval :: (Maybe String -> List String -> String) -> SlamDown -> SlamDown
eval f = everywhere b i
  where
  b :: Block -> Block
  b (CodeBlock (Fenced true info) code) = CodeBlock (Fenced false info) (singleton $ f (Just info) code)
  b other = other

  i :: Inline -> Inline
  i (Code true code) = Code false (f Nothing $ singleton code)
  i other = other
