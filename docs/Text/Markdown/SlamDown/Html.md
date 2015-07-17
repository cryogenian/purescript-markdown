## Module Text.Markdown.SlamDown.Html

This module defines functions for rendering Markdown to HTML.

#### `FormFieldValue`

``` purescript
data FormFieldValue
  = SingleValue String
  | MultipleValues (Set String)
```

##### Instances
``` purescript
instance showFormFieldValue :: Show FormFieldValue
```

#### `SlamDownState`

``` purescript
newtype SlamDownState
  = SlamDownState (Map String FormFieldValue)
```

The state of a SlamDown form - a mapping from input keys to values

##### Instances
``` purescript
instance showSlamDownState :: Show SlamDownState
```

#### `emptySlamDownState`

``` purescript
emptySlamDownState :: SlamDownState
```

The state of an empty form, in which all fields use their default values

#### `SlamDownEvent`

``` purescript
data SlamDownEvent
```

The type of events which can be raised by SlamDown forms

#### `applySlamDownEvent`

``` purescript
applySlamDownEvent :: SlamDownState -> SlamDownEvent -> SlamDownState
```

Apply a `SlamDownEvent` to a `SlamDownState`.

#### `markdownToHtml`

``` purescript
markdownToHtml :: SlamDownState -> String -> String
```

Convert Markdown to HTML

#### `renderHTML`

``` purescript
renderHTML :: SlamDownState -> SlamDown -> String
```

Render the SlamDown AST to a HTML `String`

#### `renderHalogen`

``` purescript
renderHalogen :: forall f. (Alternative f) => SlamDownState -> SlamDown -> Array (HTML (f SlamDownEvent))
```

Render the SlamDown AST to an arbitrary Halogen HTML representation


