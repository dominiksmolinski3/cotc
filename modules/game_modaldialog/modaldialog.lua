modalDialog = nil

function init()
    g_ui.importStyle('modaldialog')

    connect(g_game, {
        onModalDialog = onModalDialog,
        onGameEnd = destroyDialog
    })

    local dialog = rootWidget:recursiveGetChildById('modalDialog')
    if dialog then modalDialog = dialog end
end

function terminate()
    disconnect(g_game, {
        onModalDialog = onModalDialog,
        onGameEnd = destroyDialog
    })
end

function destroyDialog()
    if modalDialog then
        g_game.setModalDialog(false)
        modalDialog:unlock()
        modalDialog:destroy()
        modalDialog = nil
    end
end

function onModalDialog(id, title, message, buttons, enterButton, escapeButton, choices, priority)
    -- priority parameter is unused, not sure what its use is.
    if modalDialog then return end

    g_game.setModalDialog(true)

    modalDialog = g_ui.createWidget('ModalDialog', rootWidget)

    modalDialog:lock()


    local messageLabel = modalDialog:getChildById('messageLabel')
    local choiceList = modalDialog:getChildById('choiceList')
    local choiceScrollbar = modalDialog:getChildById('choiceScrollBar')
    local buttonsPanel = modalDialog:getChildById('buttonsPanel')

    modalDialog:setText(title)
    messageLabel:setText(message)

    local labelHeight
    for i = 1, #choices do
        local choiceId = choices[i][1]
        local choiceName = choices[i][2]

        local label = g_ui.createWidget('ChoiceListLabel', choiceList)
        label.choiceId = choiceId
        label:setText(choiceName)
        label:setPhantom(false)
        if not labelHeight then labelHeight = label:getHeight() end
    end
    choiceList:focusChild(choiceList:getFirstChild())

    g_keyboard.bindKeyPress('Down', function()
        choiceList:focusNextChild(KeyboardFocusReason)
    end, modalDialog)

    g_keyboard.bindKeyPress('Numpad2', function()
        choiceList:focusNextChild(KeyboardFocusReason)
    end, modalDialog)

    g_keyboard.bindKeyPress('Up', function()
        choiceList:focusPreviousChild(KeyboardFocusReason)
    end, modalDialog)

    g_keyboard.bindKeyPress('Numpad8', function()
        choiceList:focusPreviousChild(KeyboardFocusReason)
    end, modalDialog)

    g_keyboard.bindKeyPress('Escape', function()
    end, modalDialog)

    local buttonsWidth = 0
    for i = 1, #buttons do
        local buttonId = buttons[i][1]
        local buttonText = buttons[i][2]

        local button = g_ui.createWidget('ModalButton', buttonsPanel)
        button:setText(buttonText)
        button.onClick = function(self)
            local focusedChoice = choiceList:getFocusedChild()
            local choice = 0xFF
            if focusedChoice then choice = focusedChoice.choiceId end
            g_game.answerModalDialog(id, buttonId, choice)
            destroyDialog()
        end
        buttonsWidth = buttonsWidth + button:getWidth() + button:getMarginLeft() + button:getMarginRight()
    end

    local additionalHeight = 0
    if #choices > 0 then
        choiceList:setVisible(true)
        choiceScrollbar:setVisible(true)

        additionalHeight = math.min(modalDialog.maximumChoices, math.max(modalDialog.minimumChoices, #choices)) *
                               labelHeight
        additionalHeight = additionalHeight + choiceList:getPaddingTop() + choiceList:getPaddingBottom()
    end

    local horizontalPadding = modalDialog:getPaddingLeft() + modalDialog:getPaddingRight()
    buttonsWidth = buttonsWidth + horizontalPadding

    modalDialog:setWidth(math.min(modalDialog.maximumWidth,
                                  math.max(buttonsWidth, messageLabel:getWidth(), modalDialog.minimumWidth)))
    messageLabel:setWidth(math.min(modalDialog.maximumWidth,
                                   math.max(buttonsWidth, messageLabel:getWidth(), modalDialog.minimumWidth)) -
                              horizontalPadding)

    local textHeight = #messageLabel:getText()

    if textHeight > 250 then
      additionalTextHeight = 20 + ((textHeight - 250) / 10)
    else
      additionalTextHeight = 0
    end

    modalDialog:setHeight(modalDialog:getHeight() + additionalHeight + messageLabel:getHeight() - 8 + additionalTextHeight)

    local enterFunc = function()
        local focusedChoice = choiceList:getFocusedChild()
        local choice = 0xFF
        if focusedChoice then choice = focusedChoice.choiceId end
        g_game.answerModalDialog(id, enterButton, choice)
        destroyDialog()
    end

    local escapeFunc = function()
      local endList = {
        -- pl
        "koniec",
        "wyrusze w droge najszybciej, jak sie da!",
        "wyrusze w droge najszybciej, jak sie da! (koniec)",
        "musze isc!", "musze isc! (koniec)",
        --en
        "end", "i was just going.",
         "i'll be on my way as fast as i can!",
         "i'll be on my way as fast as i can! (end)",
         "i've got to go!", "i've got to go! (end)"
      }
      local backList = {
        -- pl
        "powrot", "wroc", "przyjde pozniej... (powrot)",
        "chwilowo nie mam pieniedzy...", "nie mam przy sobie wystarczajaco duzo zlota... (powrot)",
        "moze pozniej...", "moze pozniej... (powrot)", "zobacze, co da sie zrobic.",

        -- en
        "back", "i'll come back later (back)",
         "i haven't got anything to spare right now ...", "but i didn't bring enough gold ... (back)",
         "maybe later ...", "maybe later ... (back)", "i'll see what I can do.",
       }
        -- local hasEndButton = false

       for i=1, #choices do
          if inArray(choices[i][2]:lower(), endList) then
            local focusedChoice = choiceList:getFocusedChild()
            local choice = 0xFF
            if focusedChoice then
              choice = focusedChoice.choiceId
            end

            g_game.answerModalDialog(id, escapeButton, choice)
            destroyDialog()
          end
      end

      for i=1, #choices do
         if inArray(choices[i][2]:lower(), backList) then
           local choice = choices[i][1]
           g_game.answerModalDialog(id, enterButton, choice)
           destroyDialog()
         end
     end
    end

    choiceList.onDoubleClick = enterFunc

    modalDialog.onEnter = enterFunc
    modalDialog.onEscape = escapeFunc
end

function inArray(id, elements)
  for i=1, #elements do
    if elements[i] == id then
       return true
     end
  end

  return false
end
