local keyboardBindings = {
    {'f1', 'F1'}, {'f2', 'F2'}, {'f3', 'F3'}, {'f4', 'F4'}, {'f5', 'F5'}, {'f6', 'F6'},
    {'f7', 'F7'}, {'f8', 'F8'}, {'f9', 'F9'}, {'f10', 'F10'}, {'f11', 'F11'}, {'f12', 'F12'},
    {'1', '1'}, {'2', '2'}, {'3', '3'}, {'4', '4'}, {'5', '5'}, {'6', '6'},
    {'7', '7'}, {'8', '8'}, {'9', '9'}, {'0', '0'}, {'escape', 'Esc'}, {'`', 'Tilde'}, {'tab', 'Tab'}, {'capslock', 'CapsLock'},
    {'q', 'Q'}, {'w', 'W'}, {'e', 'E'}, {'r', 'R'}, {'t', 'T'}, {'y', 'Y'}, {'u', 'U'}, {'i', 'I'}, {'o', 'O'}, {'p', 'P'}, {'[', 'LeftBracket'}, {']', 'RightBracket'},
    {'-', 'Minus'}, {'=', 'Equal'}, {'\\', 'Backslash'}, {'Backspace', 'Backspace'},
    {'a', 'A'}, {'s', 'S'}, {'d', 'D'}, {'f', 'F'}, {'g', 'G'}, {'h', 'H'}, {'j', 'J'}, {'k', 'K'}, {'l', 'L'}, {';', 'Semicolon'}, {'\'', 'Apostrophe'},
    {'z', 'Z'}, {'x', 'X'}, {'c', 'C'}, {'v', 'V'}, {'b', 'B'}, {'n', 'N'}, {'m', 'M'}, {',', 'Comma'}, {'.', 'Period'}, {'/', 'Slash'}, {'enter', 'Enter'},
    {'space', 'Space'},
    {'Left', 'Left'}, {'Down', 'Down'}, {'Up', 'Up'}, {'Right', 'Right'}, {'Delete', 'Delete'}, {'End', 'End'}, {'PageDown', 'PageDown'}, {'PageUp', 'PageUp'}, {'Home', 'Home'}, {'Insert', 'Insert'}, {'Pause', 'Pause'}, {'Scrolllock', 'ScrollLock'}, {'PrintScreen', 'PrintScreen'},
    { 'numpad0', 'Numpad0' }, { 'numpad1', 'Numpad1' }, { 'numpad2', 'Numpad2' }, { 'numpad3', 'Numpad3' }, { 'numpad4', 'Numpad4' }, { 'numpad5', 'Numpad5' }, { 'numpad6', 'Numpad6' }, { 'numpad7', 'Numpad7' }, { 'numpad8', 'Numpad8' }, { 'numpad9', 'Numpad9' }
}
local keyboardWindow

-- Funkcja do obsługi wciśnięcia klawisza
local function onKeyDown(key)
    local widget = keyboardWindow:getChildById('button' .. key)
    if widget then
        widget:setOn(true)
    end
end

-- Funkcja do obsługi zwolnienia klawisza
local function onKeyUp(key)
    local widget = keyboardWindow:getChildById('button' .. key)
    if widget then
        widget:setOn(false)
    end
end

-- Rejestracja bindów klawiszy
function init()
    g_ui.importStyle('keyboardtracker')

    keyboardWindow = g_ui.createWidget('keyboardWindow', rootWidget)

    if not modules.client_options.getOption('showVirtualKeyboard') then
        keyboardWindow:hide()
    else
        keyboardWindow:show()
    end

    for _, bind in ipairs(keyboardBindings) do
        g_keyboard.bindKeyDown(bind[1], function() onKeyDown(bind[2]) end)
        g_keyboard.bindKeyUp(bind[1], function() onKeyUp(bind[2]) end)
    end

    -- Bindy dla klawiszy Shift + [0-9] i Shift + F[1-12]
    for i = 0, 9 do
        local key = 'Shift+' .. tostring(i)
        g_keyboard.bindKeyDown(key, function() onKeyDown('LeftShift'); onKeyDown(tostring(i)) end)
        g_keyboard.bindKeyUp(key, function() onKeyUp('LeftShift'); onKeyUp(tostring(i)) end)
    end

    for i = 1, 12 do
        local key = 'Shift+F' .. tostring(i)
        g_keyboard.bindKeyDown(key, function() onKeyDown('LeftShift'); onKeyDown('F' .. tostring(i)) end)
        g_keyboard.bindKeyUp(key, function() onKeyUp('LeftShift'); onKeyUp('F' .. tostring(i)) end)
    end
end

function hide()
    keyboardWindow:hide()
end

function show()
    keyboardWindow:show()
end

function terminate()
end
