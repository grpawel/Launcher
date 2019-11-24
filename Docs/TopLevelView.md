
# Top-level view of most important classes and concepts

- [Command](#command)
  - [CommandSet](#commandset)
  - [Command key](#command-key)
- [Environment](#environment)
- [GUI](#gui)
- [Controller](#controller)
- [Context](#context)
- [Functions](#functions)
  - [Environment functions](#environment-functions)
  - [Wrappers](#wrappers)
  - [Value functions](#value-functions)
  - [Predicates](#predicates)
  - [Mappers](#mappers)
- [Pipeline](#pipeline)
- [Extension](#extension)

## Command

Command is an object that performs some action.
The action could be just about anything.

Should extend [Command](../src/Commands/Command.ahk) class.

Should use Environment function for interaction with outside world, see [Environment](#environment)

_Base class is defined in [src/Commands/Command.ahk](../src/Commands/Command.ahk), commands are in folders under [src/Commands](../src/Commands)._

### CommandSet

Special kind of command.
Stores commands with their keys.
Shows input in GUI and runs associated command.

### Command key

Some string that is used to select a command in GUI.

Usually a command is associated with a key by first argument of `CommandSet.Add()` method.
One command could be added many times with different keys.

## Environment

Object containing functions for interacting with outside world and their settings.
The function can open files, copy, type text etc. A setting could be e.g. path to browser.

Usually each setting and function have corresponding command:
`Web` commmand uses `open` function and `browser` setting from environment.
`Folder` command uses `open` function and `folder` setting.

Environment exists to enable changing those functions.
For example `open` function can be changed to one copying its argument to clipboard, causing `Web` command to copy URL to clipboard.

_Defined in [src/Environment/Environment.ahk](../src/Environment/Environment.ahk)._

## GUI

Window that the script creates (see screenshot at the top) or class ([Gui](../src/Gui/Gui.ahk)) that creates and manages the window.

## Controller

Object that ties together commands, environment, gui and some other things.
Commands can use the controller to access environment or gui.

Multiple controllers can be created, each with different set of commands, environment etc, and associated with hotkeys.

_Defined in [src/Controller/Controller.ahk](../src/Controller/Controller.ahk)._

## Context

Simple object (without any class) that is used to pass some data between commands.
Mostly unused and needs some thought.

_Passed as second parameter in `Command.Run()` method._

## Functions

Functions are used in different incompatible ways:

### Environment functions

Functions performing some outside actions, set in environment.
Named with nouns, e.g. `RunOpener`.

_Defined in [src/Environment/Functions](../src/Environment/Functions/)._

### Wrappers

Wrappers are functions that take a command and return a different command containing given one.
Named with "With" prefix, e.g. `WithCommandsBlocked`.

In this scipt wrapper is used with a different meaning from decorator.
Decorator more technical: it's an object that passes some calls to one object and some to another.
Wrapper functions return decorators.

_Defined in [src/Commands/Wrappers](../src/Commands/Wrappers/)._

### Value functions

Value function is a function that returns a value.
Most commands can take a value function reference as a parameter.

_Defined in [src/Functions/ValueFunctions.ahk](../src/Functions/ValueFunctions.ahk)._

### Predicates

Predicate is a function that returns true or false for its argument.
Name should be a question with yes/no answer, like HasSomething, IsThatThing etc.

_Defined in [src/Functions/Predicates.ahk](../src/Functions/Predicates.ahk)._

### Mappers

Mapper is a function that takes one object and returns another.

## Pipeline

Pipeline is a combination of Predicates and Mappers that transforms list of objects.
Used to create new CommandSets with some commands.

## Extension

Extension is a set of classes and functions that provide some functionality.
Can be attached to a controller to use the functionality with the controller.
Can also refer to main class of the extension, extending [Extension](../src/Extensions/Extension.ahk) class.

Folders under each extension have the same structure as under [src](../src/) folder.

_Extensions are placed in [src/Extensions](../src/Extensions/) folder._
