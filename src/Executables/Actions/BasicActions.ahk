#Include %A_ScriptDir%\src\Executables\Actions\Action.ahk

class Open extends Action {
    Run(toRun) {
        run, %toRun%
    }
}

class Enter extends Action {
    Run(newCommandSet) {
        global currentExecutable := newCommandSet
        global level := level +1
        GuiAddInput("eachKey")
        return false
    }
}

class Search extends Action {
    Run(searchExecutable) {
        global currentExecutable := searchExecutable
        global level := level + 1
        GuiAddInput("onlyEnter")
        return false
    }
}

class Reload extends Action {
    Run(_) {
        Reload
    }
}

InitializeActions() {
    ent := new Enter()
    return  { open: new Open()
            , enter: new Enter() 
            , search: new Search()
            , reload: new Reload()}
}
