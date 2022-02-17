# LaDoc - Specification
## What is it?
It is a specification for a Language Agnostic Documentation Format.

It takes its inspiration and initial format idea from the [COD](https://github.com/namuol/codhttps://github.com/namuol/cod) specification.

The goal is to provide a documentation format that can be used for any project, no matter the language it is developed in, and that can be exported to different output format.

At this moment, only the JSON output is formally specified

It is **NOT** a documentation generator.

Thus, you'll have to implement your own documentation generator that can parse LaDoc or use one that is already implemented.

LaDoc can be used as is, in its own file or as part of a code base inside of comment blocks.

Being language agnostic, LaDoc has no knowledge of functions, classes, objects, monad or other programming languages concepts. It will also **NOT** do code analysis or extract information from the code LaDoc might be directly documenting (if used inside comment blocks for example). 

## Format
Even though LaDoc is language agnostic and has no knowledge of programming concepts, it describes different types of tags to convey different meaning that we can't avoid to have and that will ultimately be needed at some points anyway.

LaDoc tries to be as succint as possible, to let as much freedom and flexibility to the writer.

## Tags
Every tags start with the `@` symbol which must be the first character in a new line.

They can then be followed by other special characters depending on the meaning we want the tag to convey.

If the tag takes a value, the tag name and its value are separated by one space character.

A tag value is almost always taken as a string, with whitespaces preserved. The [number tag](#number-tag) allows enforcing the value to be an number.

By default and if not specified otherwise, every tag is contained under a global unnamed scope. It is possible to create additional scopes using the [scope tags](#scope-tags).

It is invalid to have the same tag as part of the same scope. The only exception being if they are defined in an [list tag](#list-tags).

### Key/Value tags
Describes a simple tag that represent a key value pair.

```
@key value
```

> Example
```
@firstname Jonathan
@lastname Racaud
@bio Author of the LaDoc specification.
```
output: 
```json
{
  {"firstname": "Jonathan"},
  {"lastname": "Racaud"},
  {"bio": "Author of the LaDoc specification."}
}
```

### Named key/value tags
Describe a tag for which the key/value pair needs to be named.
```
@^name key value
```

> Example
```
@^return int The returned value
```
output: 
```json
{
  "return": { "int": "The returned value" }
}
```

### Single line string tag
This tag describe a simple string that has the same value as its name.

This tag can only represent single line strings.

It's usage is highly situational and is not expected to be used often by itself. Most likely it will be used inside of a list tag.

```
@'tag
```
> Example
```
@'Jonathan
@'Racaud
@'That string is a little bit longer
 and this line will not be part of it
```
output: 
```json
"Jonathan"
"Racaud"
"That string is a little bit longer"
```

#### Number tag
Force the value to be a number. 
```
@#key value
```

> Example
```
@#luckyNumber 42
@#pi 3.141592
@#bigNumber +42.e+237
@#smallNumber -42.e-329
```
output: 
```json
{
  "luckyNumber": 42,
  "pi": 3.141592,
  "bigNumber": +42.e+237,
  "smallNumber": -42.e-329
}
```

### Scope tags
Describe a scope that contains other tag or texts.
The closing tag can ommit the tag name. If present, it must match the opening tag.

The opening and closing tag can live in different comment blocks.


```
@{tag
@}tag

# is equivalent to

@{tag
@}
```

> Example
```
@{module
 @description This is a module.
 @createdOn 2022-02-14
@}module

@{scope
  @description Another description.
@}
```
output: 
```json
{
  "module": {
    "description": "This is a module.",
    "createdOn": "2022-02-14"
  },
  "scope": {
    "description": "Another description."
  }
}
```

It is forbidden to have the same tag appearing multiple time in a scope. This does not mean that same tag can't be used multiple time throughout the documentation. Also the knowledge of a scope is only the scope itself and not its parent nor children.

This means it is entirely legal to use the same tag in a child scope even if it was used in the parent scope

> Example
```
# Valid
@{module
  @description The description of the module.

  @{aFunction
    @description The description of aFunction.
  @}

  @{aSecondFunction
    @description The description of aSecondFunction.
  @}
@}
```
output:
```json
{
  "module": {
    "description": "The description of the module.",
    "aFunction": {
      "description": "The description of aFunction."
    },
    "aSecondFunction": {
      "description": "The description of aSecondFunction"
    }
  }
}
```
---
```
# invalid
@{module
  @description The description of the module.

  @{aFunction
    @description The description of aFunction.
  @}

  @{aFunction
    @description The second `aFunction` scope is invalid, because its name collide with
    the previously specified `aFunction` scope.
  @}

  @description This line is invalid because @description was already defined before.
@}
```

### List tags
Describe a list of tags.
The closing tag can ommit the tag name. If present, it must match the opening tag.

The list tag can contain Key/Value tags or String tags (see below).
```
@[tag
@]tag

# is equivalent to

@[tag
@]
```

> Example
```
@[parameters
  @int32 size
  @char8* buffer
  @MySuperClass superClass
@]parameters
```
output: 
```json
{
  "parameters": [
    {"int32": "size"},
    {"char8*": "buffer"},
    {"MySupperClass": "superClass"}
  ]
}
```
Even though a tag can't be repeated as part of the same scope, in the case of a list tag, that rule can be "broken". The reason being most of the items in the list are being treated as unnamed scopes. So repetition of tags is accepted.

> Example
```
@[aList
  @'a single string
  @key value
  @key second value
  @#aNumber 42
  @#aNumber 32
  @[aNestedArray
  @]
  @[aNestedArray
  @]
  @{aNestedScope
  @}
  @{aNestedScope
  }
  @^property int 456
  @^property int 234
@]
```
output:
```json
{
  "anArray": [
    "a single string",
    {"key": "value"},
    {"key": "second value"},
    {"aNumber": 42},
    {"aNumber": 32},
    {"aNestedArray": []},
    {"aNestedArray": []},
    {"aNestedScope": {}},
    {"aNestedScope": {}},
    {"property": {"int": "456"}}
    {"property": {"int": "234"}}
  ]
}
```

### Untagged text
Because LaDoc is meant to be flexible, it is allowed to have non tagged text. LaDoc will preserve that text and its formatting.
Since that kind of text can be found anywhere in the documentation, LaDoc specifies that it will keep that text in a special `!text` array for which each items keep the following information:
- Preceding tag
- Text content

> Example
```
This text is not part of any tag and will be preserved as it is.

@{Sub-section
  This text belongs to the sub-section and does not have any preceding tag.
  
  @description This is a sample description.

  This text also belongs to the sub-section, 
  but is preceded by the @description tag.
      Also, whitespaces are preserved.
@}
```
output: 
```json
{
  "!text": [
    {
      "precededBy": "",
      "content": "This text is not part of any tag and will be preserved as it is."
    },
    "Sub-section": {
      "!text": [
        {
          "precededBy": "",
          "content": "This text belongs to the sub-section and does not have any preceding tag."
        },
        {
          "precededBy": "description",
          "content": "This text also belongs to the sub-section, \nbut is preceded by the @description tag.\n\t\tAlso, whitespaces are preserved."
        }
      ],
      "description": "This is a sample description.",
    }
  ]
}
```

