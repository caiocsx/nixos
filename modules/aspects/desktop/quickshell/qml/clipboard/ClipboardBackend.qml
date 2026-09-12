import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property var historyItems: []
    property var favoriteItems: []
    property bool busy: process.running
    property string operation: ""
    readonly property string executable: Quickshell.env("CLIPBOARD_BACKEND") || "quickshell-clipboard-backend"

    signal commandFinished(string operation, bool success, string message)

    function refresh(mode) {
        run([mode === "favorites" ? "--favorites" : "--history"], "load-" + mode)
    }

    function copy(item, mode) {
        if (mode === "favorites")
            run(["--copy-favorite", item.token], "copy")
        else
            run(["--copy-history", item.id], "copy")
    }

    function addFavorite(item) {
        run(["--add-favorite", item.id], "add-favorite")
    }

    function remove(item, mode) {
        if (mode === "favorites")
            run(["--remove-favorite", item.token], "remove-favorite")
        else
            run(["--remove-history", item.token], "remove-history")
    }

    function clear(mode) {
        run([mode === "favorites" ? "--clear-favorites" : "--clear-history"], "clear-" + mode)
    }

    function run(arguments, nextOperation) {
        if (process.running)
            return

        operation = nextOperation
        process.command = [executable].concat(arguments)
        process.running = true
    }

    Process {
        id: process

        stdout: StdioCollector { id: output }
        stderr: StdioCollector { id: errorOutput }

        onExited: exitCode => {
            const completedOperation = root.operation
            const success = exitCode === 0
            const message = success ? output.text.trim() : errorOutput.text.trim()

            if (success && completedOperation.startsWith("load-")) {
                try {
                    const items = JSON.parse(output.text || "[]")
                    if (completedOperation === "load-history")
                        root.historyItems = items
                    else
                        root.favoriteItems = items
                } catch (error) {
                    root.commandFinished(completedOperation, false, error.toString())
                    return
                }
            }

            root.commandFinished(completedOperation, success, message)
        }
    }
}
