; This example introduces Environment and commands using it.
; Environment lets you use different programs for different files
; or open those files in various ways.

; To run this example run `RunExample.ahk` from parent directory and select "4. Environment".

; If you want to use this file with your own commands:
;  1. Copy this file to main directory (the one containing `src`, `Examples` and other folders).
;  2. Remove all lines with "; only-for-demo" comments.
;  3. Add your commands.
; Rest of the file contains everyting you need.



#Include %A_ScriptDir%\src\IncludeAll.ahk

EnvironmentExample:                                         ; only-for-demo
    MsgBox, Press`nCtrl + Shift + /`nto open GUI.           ; only-for-demo

    commands := new CommandSet().SetDescription("Environment")
    commands := WithHelpOpened(commands)


    ; ====== 1. COMMANDS ======

    ; So far we only used `Open` command. By default it uses builtin `Run` from AutoHotkey.
    ; There are other commands specialized for opening different categories of things.

    ; Open website in a browser:
    commands.Add("goo", new Web("https://google.com").SetDescription("Google"))
    ; Open folder using Windows Explorer:
    commands.Add("prog", new Folder(A_ProgramFiles).SetDescription("Program Files"))
    ; Open file in a default program:
    commands.Add("this", new File(A_ScriptDir "\Examples\Environment.ahk"))

    ; Copy string to clipboard:
    commands.Add("email", new Copy("youremail@domain.com").SetDescription("Copy email to clipboard"))
    ; Open separate window with some text:
    commands.Add("text", new ShowInWindow("some possibly long text").SetDescription("Show text in window"))

    ; These commands are in `src\Commands\Actions` folder.
    ; If you look into their implementation, they are using `CallFunction` method on environment
    ; instead of something like `Run, %program% %argument%`.
    ; It is done like this to allow changing those functions to e.g. copy URL to clipboard
    ; See examples in section 2.2 Changing functions.



    ; ====== 2. CHANGING ENVIRONMENT ======


    ; ------ 2.1 Changing settings ------
 
    ; You can change programs used to open things:
    ; `Web` opens website with browser from `browser` setting in environment. By default it is Chrome.
    ; After running `ChangeEnvironment` commands below browser will be changed,
    ; so `Web` and `Search` command will use different browser.
    ; When script is reloaded those changes are lost.
    commands.Add("setchr", new ChangeEnvironment({ settings: { browser: "C:\Program Files\Mozilla Firefox\firefox.exe" } })
                                    .SetDescription("Change browser to Firefox"))
    commands.Add("setfire", new ChangeEnvironment({ settings: { browser: "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" } })
                                    .SetDescription("Change browser to Chrome"))

    ; Other commands like `File` or `Folder` use their own settings.

    ; Change browser for a single command:
    ; `WithEnvironment` first runs `ChangeEnvironment`, then your command (`commands` here), 
    ; and after it is finished reverts the changes made in `ChangeEnvironment`.
    ; Note: `WithEnvironment` returns given command, so calling `SetDescription` would change description for `commands`.
    ; We do not want that, so we use `{ wrapper: "opaque" }` option that makes it return a new command.
    ; More about that in example 5 Composing.
    commands.Add("withfire", WithEnvironment({ settings: { browser: "C:\Program Files\Mozilla Firefox\firefox.exe" } }
                                                    , commands
                                                    , { wrapper: "opaque"})
                                                   .SetDescription("Run next command using Firefox browser"))

    ; If you only want to show commands that use `browser` setting, make a new `CommandSet` with only some commands:
    webCommands := commands.Filter(IsCommand([ "Web", "Search" ]))
    commands.Add("withchr", WithEnvironment({ settings: { browser: "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" } }
                                                   , WithHelpOpened(webCommands))
                                                  .SetDescription("Run next command using Chrome browser"))


    ; ------ 2.1 Changing functions ------

    ; Changing functions allows to do different things with command arguments,
    ; for example copy folder path to clipboard instead of opening the folder.

    ; Copy argument of next command to clipboard:
    ; `ChangeAllFunctions(Func("ToClipboardCopier"))` changes all functions in the environment 
    ; to one that copies its argument to the clipboard.
    commands.Add("copy", WithEnvironment(ChangeAllFunctions(Func("ToClipboardCopier"))
                                               , commands
                                               , { wrapper: "opaque" })
                                .SetDescription("Copy next command to clipboard"))

    ; Show argument of next command in a window:
    commands.Add("show", WithEnvironment(ChangeAllFunctions(Func("InWindowShower")), commands, { wrapper: "opaque" })
                                .SetDescription("Show argument of next command"))



    ; ====== 3. CUSTOM FUNCTIONS AND SETTINGS ======

    ; You are not limited to settings and functions listed in `Environment` class.
    ; In this section we'll add custom ones.


    ; ------ 3.1 Custom settings ------

    ; To be able to use different programs for some type of files, let's say text, you can make up a setting:
    ; "textFile" is the name of our setting.
    commands.Add("usenote", new ChangeEnvironment({ settings: { "textFile": "C:\Windows\System32\notepad.exe" } })
                                    .SetDescription("Use Notepad for opening text files"))
    commands.Add("usecode", new ChangeEnvironment({ settings: { "textFile": "C:\Program Files\Microsoft VS Code\Code.exe" } })
                                    .SetDescription("USe VS Code for opening text files"))
    commands.Add("usewordp", new ChangeEnvironment({ settings: { "textFile": "C:\Program Files\windows nt\accessories\wordpad.exe" } })
                                    .SetDescription("Use WordPad for opening text files"))

    commands.Add("usedef", new ChangeEnvironment({ settings: { "textFile": "" } })
                                    .SetDescription("Use default program for opening text files"))

    ; Then you can use the setting as second argument of `Open` command:
    commands.Add("hosts", new Open("C:\Windows\system32\drivers\etc\hosts", "textFile").SetDescription("Hosts file"))

    ; Note: alternatively you could create these in a loop:
    textPrograms := [ ["note", "Notepad", "C:\Windows\System32\notepad.exe"]
                    , ["notp", "Notepad++", "C:\Program Files\Notepad++\notepad++.exe"] ]
    ; Command must be added to `commands` before this line to be included in `textCommands`
    textCommands := commands.Filter(IsCommand("Open")) 
    for i, program in textPrograms {
        commands.Add("use" program[1], new ChangeEnvironment({ settings: { "textFile": program[3]}})
                                            .SetDescription("Use " program[2] " for opening text files"))
        commands.Add("with" program[1], WithEnvironment({ settings: { "textFile": program[3] } }
                                                       , WithHelpOpened(textCommands)
                                                       , { wrapper: "opaque" } )
                                         .SetDescription("Open text file using " program[2]))
    }


    ; ------ 3.2 Custom functions ------

    ; You can add your own functions to environment.
    ; "customSetting" is the name of the environment setting, "customFunc" is the name of the function.
    ; Initial function and setting value are added to environment in section 5.
    ; Function names are nouns so that they are different from commands.
    commands.Add("doSth", new CallEnvFunction("customFunc", "customSetting", "some argument").SetDescription("Call custom function"))
    ; Add custom command instead of using `CallEnvFunction("SomethingDoer", "someSetting" ...)`
    commands.Add("doCom", new DoSomething("another argument"))

    ; Custom functions are changed by commands like "copy" (section 2.1).
    ; Check that by running "copy" then "customf".
    ; And you can also change functions used in other commands to instead use yours:
    commands.Add("usecustom", WithEnvironment(ChangeAllFunctions(Func("SomethingDoer"))
                                                    , commands
                                                    , { wrapper: "opaque" })
                                .SetDescription("Use custom function for next command"))


    Goto EnvironmentExampleContinue3_2                      ; only-for-demo

; Some function
SomethingDoer(env, setting, argument) {
    ; `env` (Environment) allows you to access other settings or functions
    ; `setting` contains value of some environment setting
    ; `argument` comes from calling command
    MsgBox % "Setting: " ToCompactString(setting) "`nArgument: " ToCompactString(argument)
}

; Some command that uses the function
class DoSomething extends Command {
    __New(argument) {
        this._argument := argument
        this._description := "Run custom environment function in command"
        this.AddTags(["usesEnv"])
    }

    Run(contr, context) {
        env := contr.GetEnvironment()
        ; Using `GetValue` allows you to pass command object returning your argument
        ; instead of passing the argument directly.
        argument := GetValue(this._envSetting, contr, context)
        env.CallFunction("customFunc", "customSetting", toRun)
    }
}

EnvironmentExampleContinue3_2:                              ; only-for-demo

    ; ====== 4. OTHER ======

    ; Check current browser:
    ; `GetEnvironmentSetting("browser")` returns function object that returns "browser" setting from environment.
    ; `ShowMessage`, like most other commands, can take a function object instead of string. 
    ; More about that in example 5 Composing.
    commands.Add("browser", new ShowMessage(GetEnvironmentSetting("browser")).SetDescription("Check current browser"))

    commands.Add("rel", new Reload())
    commands.Add("?", new Help(commands))



    ; ====== 5. INITIAL CONFIGURATION ======

    contr := new Controller(new Environment(), new Gui(cv))
    contr.SetRootCommand(commands)

    ; Set initial setting:
    ; Commands do not have to be run by `CommandSet`, you can run them yourself wherever you want if you have the controller.
    ; 3.1 Set default setting for text commands:
    contr.RunCommand(commands.Get("usenote"))
    ; 3.2 Set custom function and setting so that "customf" command works
    contr.RunCommand(new ChangeEnvironment({ functions: { customFunc: Func("SomethingDoer") }
                                           , settings: { customSetting: "default setting" } }))


    activeExample := "environment"                          ; only-for-demo
    return                                                  ; only-for-demo


#If (activeExample == "environment")                        ; only-for-demo
{                                                           ; only-for-demo
    +^/::
        contr.Execute()
        return
}                                                           ; only-for-demo

#Include %A_ScriptDir%\src\Gui\GuiEscapes.ahk
