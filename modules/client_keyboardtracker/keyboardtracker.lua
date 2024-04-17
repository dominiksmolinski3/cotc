function init()
    g_ui.importStyle('keyboardtracker')

    if not keyboardWindow then
        keyboardWindow = g_ui.createWidget('keyboardWindow', rootWidget)
        print("C")
    else
        keyboardWindow:show()
        print("Z")
    end
    print("S")
end

function toggleKeyboardTracker()
end

function terminate()
end