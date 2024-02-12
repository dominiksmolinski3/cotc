Items = {}
LootContainer = {}

lootContainerWindow = nil
selectedItem = nil
selectedSkipItem = nil
lootBackpack = ''
goldBackpack = ''
stackBackpack = ''
convertGold = false

nameLabel = nil
weightLabel = nil
descriptionLabel = nil
itemSearchPreview = nil
searchInput = nil
lootBackpackCombobox = nil
goldBackpackCombobox = nil
stackBackpackCombobox = nil
skipWhenQuickLootingCheckBox = nil
convertGoldCheckBox = nil

items = {}
itemList = {}
itemsToDisplay = {}
skippedItemsToDisplay = {}
skipItemList = {}
savedSkippedItems = nil

function init()
  connect(g_game, { onLootContainerWindow = Items.create,
                    onGameEnd = Items.destroy })


  lootContainerWindow = g_ui.displayUI('lootContainer', modules.game_interface.getRightPanel())
  lootContainerWindow:hide()
  nameLabel = lootContainerWindow:getChildById('nameLabel')
  weightLabel = lootContainerWindow:getChildById('weightLabel')
  descriptionLabel = lootContainerWindow:getChildById('descriptionLabel')
  itemSearchPreview = lootContainerWindow:getChildById('itemSearchPreview')
  searchInput = lootContainerWindow:getChildById('searchEdit')
  lootBackpackCombobox = lootContainerWindow:recursiveGetChildById('lootBackpack')
  goldBackpackCombobox = lootContainerWindow:recursiveGetChildById('goldBackpack')
  stackBackpackCombobox = lootContainerWindow:recursiveGetChildById('stackBackpack')
  skipWhenQuickLootingCheckBox = lootContainerWindow:recursiveGetChildById('addToSkippedLoot')
  convertGoldCheckBox = lootContainerWindow:recursiveGetChildById('convertGoldToPlatinums')

  lootContainerButton = modules.client_topmenu.addRightGameToggleButton('lootContainerButton', tr('Manage Loot Containers'),
                                                                    '/images/topbuttons/loot_container', toggle)


  lootContainerButton:setOn(false)
  itemList = lootContainerWindow:getChildById('itemList')
  skipItemList = lootContainerWindow:getChildById('skipItemList')
  skippedItemsToDisplay = {}
  setupComboBox()
  initializeItemsList()
  resizeWindow()
end

function terminate()
  disconnect(g_game, { onLootContainerWindow = Items.create,
                       onGameEnd = Items.destroy })
  Items.destroy()
  lootContainerWindow:destroy()
  lootContainerButton:destroy()

  Items = nil
end

function setupComboBox()

  lootBackpackCombobox:addOption('(none)', '')
  lootBackpackCombobox:addOption('Backpack', 'backpack')
  lootBackpackCombobox:addOption('Bag', 'bag')

  lootBackpackCombobox:addOption('Backpack of Holding', 'backpack of holding')

  lootBackpackCombobox:addOption('Beach Backpack', 'beach backpack')
  lootBackpackCombobox:addOption('Beach Bag', 'beach bag')

  lootBackpackCombobox:addOption('Black Troll Backpack', 'black troll backpack')

  lootBackpackCombobox:addOption('Brocade Backpack', 'brocade backpack')
  lootBackpackCombobox:addOption('Brocade Bag', 'brocade bag')

  lootBackpackCombobox:addOption('Demon Backpack', 'demon backpack')

  lootBackpackCombobox:addOption('Expedition Backpack', 'expedition backpack')
  lootBackpackCombobox:addOption('Expedition Bag', 'expedition bag')

  lootBackpackCombobox:addOption('Golden Backpack', 'golden backpack')
  lootBackpackCombobox:addOption('Golden Bag', 'golden bag')

  lootBackpackCombobox:addOption('Green Backpack', 'green backpack')
  lootBackpackCombobox:addOption('Green Bag', 'green bag')

  lootBackpackCombobox:addOption('Grey Backpack', 'grey backpack')
  lootBackpackCombobox:addOption('Grey Bag', 'grey bag')

  lootBackpackCombobox:addOption('Jewelled Backpack', 'jewelled backpack')
  lootBackpackCombobox:addOption('Shell Backpack', 'shell backpack')
  lootBackpackCombobox:addOption('Skeleton Backpack', 'skeleton backpack')

  lootBackpackCombobox:addOption('Red Backpack', 'red backpack')
  lootBackpackCombobox:addOption('Red Bag', 'red bag')

  lootBackpackCombobox:addOption('Troll Backpack', 'troll backpack')

  lootBackpackCombobox:addOption('Yellow Backpack', 'yellow backpack')
  lootBackpackCombobox:addOption('Yellow Bag', 'yellow bag')

  lootBackpackCombobox.onOptionChange = function(comboBox, option)
      setBackpackpack('lootBackpack', comboBox:getCurrentOption().data)
  end

  goldBackpackCombobox:addOption('(none)', '')
  goldBackpackCombobox:addOption('Backpack', 'backpack')
  goldBackpackCombobox:addOption('Bag', 'bag')

  goldBackpackCombobox:addOption('Backpack of Holding', 'backpack of holding')

  goldBackpackCombobox:addOption('Beach Backpack', 'beach backpack')
  goldBackpackCombobox:addOption('Beach Bag', 'beach bag')

  goldBackpackCombobox:addOption('Black Troll Backpack', 'black troll backpack')

  goldBackpackCombobox:addOption('Brocade Backpack', 'brocade backpack')
  goldBackpackCombobox:addOption('Brocade Bag', 'brocade bag')

  goldBackpackCombobox:addOption('Demon Backpack', 'demon backpack')

  goldBackpackCombobox:addOption('Expedition Backpack', 'expedition backpack')
  goldBackpackCombobox:addOption('Expedition Bag', 'expedition bag')

  goldBackpackCombobox:addOption('Golden Backpack', 'golden backpack')
  goldBackpackCombobox:addOption('Golden Bag', 'golden bag')

  goldBackpackCombobox:addOption('Green Backpack', 'green backpack')
  goldBackpackCombobox:addOption('Green Bag', 'green bag')

  goldBackpackCombobox:addOption('Grey Backpack', 'grey backpack')
  goldBackpackCombobox:addOption('Grey Bag', 'grey bag')

  goldBackpackCombobox:addOption('Jewelled Backpack', 'jewelled backpack')
  goldBackpackCombobox:addOption('Shell Backpack', 'shell backpack')
  goldBackpackCombobox:addOption('Skeleton Backpack', 'skeleton backpack')

  goldBackpackCombobox:addOption('Red Backpack', 'red backpack')
  goldBackpackCombobox:addOption('Red Bag', 'red bag')

  goldBackpackCombobox:addOption('Troll Backpack', 'troll backpack')

  goldBackpackCombobox:addOption('Yellow Backpack', 'yellow backpack')
  goldBackpackCombobox:addOption('Yellow Bag', 'yellow bag')

  goldBackpackCombobox.onOptionChange = function(comboBox, option)
      setBackpackpack('goldBackpack', comboBox:getCurrentOption().data)
  end

  stackBackpackCombobox:addOption('(none)', '')
  stackBackpackCombobox:addOption('Backpack', 'backpack')
  stackBackpackCombobox:addOption('Bag', 'bag')

  stackBackpackCombobox:addOption('Backpack of Holding', 'backpack of holding')

  stackBackpackCombobox:addOption('Beach Backpack', 'beach backpack')
  stackBackpackCombobox:addOption('Beach Bag', 'beach bag')

  stackBackpackCombobox:addOption('Black Troll Backpack', 'black troll backpack')

  stackBackpackCombobox:addOption('Brocade Backpack', 'brocade backpack')
  stackBackpackCombobox:addOption('Brocade Bag', 'brocade bag')

  stackBackpackCombobox:addOption('Demon Backpack', 'demon backpack')

  stackBackpackCombobox:addOption('Expedition Backpack', 'expedition backpack')
  stackBackpackCombobox:addOption('Expedition Bag', 'expedition bag')

  stackBackpackCombobox:addOption('Golden Backpack', 'golden backpack')
  stackBackpackCombobox:addOption('Golden Bag', 'golden bag')

  stackBackpackCombobox:addOption('Green Backpack', 'green backpack')
  stackBackpackCombobox:addOption('Green Bag', 'green bag')

  stackBackpackCombobox:addOption('Grey Backpack', 'grey backpack')
  stackBackpackCombobox:addOption('Grey Bag', 'grey bag')

  stackBackpackCombobox:addOption('Jewelled Backpack', 'jewelled backpack')
  stackBackpackCombobox:addOption('Shell Backpack', 'shell backpack')
  stackBackpackCombobox:addOption('Skeleton Backpack', 'skeleton backpack')

  stackBackpackCombobox:addOption('Red Backpack', 'red backpack')
  stackBackpackCombobox:addOption('Red Bag', 'red bag')

  stackBackpackCombobox:addOption('Troll Backpack', 'troll backpack')

  stackBackpackCombobox:addOption('Yellow Backpack', 'yellow backpack')
  stackBackpackCombobox:addOption('Yellow Bag', 'yellow bag')

  stackBackpackCombobox.onOptionChange = function(comboBox, option)
      setBackpackpack('stackBackpack', comboBox:getCurrentOption().data)
  end
end

function initializeItemsList()

  for id, item in pairs(itemsToDisplay) do
    local tmpLabel = g_ui.createWidget('ItemBox', itemList)
    tmpLabel:setId(item.clientId)
    tmpLabel:getChildById('itemPreview'):setItemId(item.clientId)
    tmpLabel:getChildById('itemLabel'):setText(item.name)
    tmpLabel.onClick = updateItemInformation
  end
end

function resizeWindow()
    lootContainerWindow:setWidth(920)
    lootContainerWindow:setHeight(450)

end

function toggle()
  local localPlayer = g_game.getLocalPlayer()

    if lootContainerButton:isOn() then
        lootContainerWindow:unlock()
        selectedItem = nil
        lootContainerButton:setOn(false)
        lootContainerWindow:hide()
        searchInput:setText("")
        saveQuickLootingSettings()
        sendQuickLootData()


    else
        itemsToDisplay = getQuickLootItems()
        skipWhenQuickLootingCheckBox:setChecked(false)
        cleanBackpacks()
        convertGold = false
        loadQuickLootingSettings()
        loadQuickLootingBackpacks()
        loadQuickLootConvertGold()
        clearItems()

        lootContainerButton:setOn(true)
        lootContainerWindow:show()
        lootContainerWindow:raise()
        lootContainerWindow:focus()

        if not localPlayer:isPremium() then
          convertGoldCheckBox:disable()
          skipWhenQuickLootingCheckBox:disable()
          skipItemList:disable()
        else
          convertGoldCheckBox:enable()
          skipWhenQuickLootingCheckBox:enable()
          skipItemList:enable()
        end

        nameLabel:setText(tr("Name") .. ": " )
        weightLabel:setText(tr("Weight") .. ": ")
        descriptionLabel:setText("")
        updateSkippedList()
        updateBackpacks()
        updateConvertGold()
        lootContainerWindow:lock()

    end
end


function Items.create(itemsList)
  items = itemsList
  Items.destroy()

  lootContainerWindow = g_ui.displayUI('lootcontainer.otui')
end

function Items.destroy()
  -- if lootContainerWindow then
  --   lootContainerWindow:destroy()
  --   lootContainerWindow = nil
  --   selectedItem = nil
  --   selectedSkipItem = nil
  --   items = {}
  -- end
end

function findItem(id, parentId)
  local list = itemsToDisplay

  if parentId ~= "itemList" then
    list = skippedItemsToDisplay
  end

  for _, item in pairs(list) do
    if tonumber(item.clientId) == tonumber(id) then
      return item
    end
  end

  return false
end

function updateItemInformation(widget)
    local id = widget:getId()
    local parent = widget:getParent()
    local parentId = parent:getId()

    local itemToDisplay = findItem(id, parentId)

    if itemToDisplay then
      selectedItem = itemToDisplay
      nameLabel:setText(tr("Name") .. ": " .. itemToDisplay.name)
      weightLabel:setText(tr("Weight") .. ": " .. string.format('%.2f', itemToDisplay.weight / 100) .. ' oz')
      descriptionLabel:setText(itemToDisplay.description)
      skipWhenQuickLootingCheckBox:setChecked(inArray(selectedItem, skippedItemsToDisplay))

      if parentId == "itemList" then
        itemSearchPreview:setItemId(id)
        selectedSkipItem = nil

        for i, child in pairs(skipItemList:getChildren()) do
          if child:isFocused() then
            child:setColor("#aaaaaa")
            child:setBackgroundColor("alpha")
          end
        end
      else

        itemSearchPreview:setItemId(0)
        selectedSkipItem = id
        for i, child in pairs(itemList:getChildren()) do
          if child:isFocused() then
            child:setColor("#aaaaaa")
            child:setBackgroundColor("alpha")
          end
        end
      end

    else
        itemSearchPreview:setItemId(0)
        nameLabel:setText(tr("Name") .. ": " )
        weightLabel:setText(tr("Weight") .. ": ")
        descriptionLabel:setText("")
    end
end

function clearItems()
  itemList:destroyChildren()

  itemSearchPreview:setItemId(0)

  if selectedSkipItem == 0 then
    nameLabel:setText(tr("Name") .. ": " )
    weightLabel:setText(tr("Weight") .. ": ")
    descriptionLabel:setText("")
    skipWhenQuickLootingCheckBox:setChecked(false)
  end

  selectedItem = nil
end

function LootContainer.updateList()
    clearItems()

  local newItemsToDisplay = {}

  local searchFilter = searchInput:getText()

  if searchFilter and searchFilter ~= "" then
    for _, item in pairs(getQuickLootItems()) do
        if item.name:lower():find(searchFilter) then
          table.insert(newItemsToDisplay, item)
        end
    end
  end

  itemsToDisplay = newItemsToDisplay
  initializeItemsList()
end

function isItemInList(item, list)
  if not item then return false end
  if table.empty(list) then return false end

  for _, element in pairs(list) do
    if element.clientId == item.clientId then
      return true
    end
  end

  return false
end

function LootContainer.setConvertGold(widget)
  if convertGoldCheckBox:isChecked() == true then
    convertGold = true
  else
    convertGold = false
  end

end

function LootContainer.addToSkippedLoot(widget)
  local newSkippedListToDisplay = {}

  if selectedItem ~= nil then

    if skipWhenQuickLootingCheckBox:isChecked() then -- add to list

      if not isItemInList(selectedItem, skippedItemsToDisplay) and itemSearchPreview:getItemId() ~= 0 then
        table.insert(skippedItemsToDisplay, selectedItem)
        updateSkippedList()
      end

    else -- remove from list
      local canWeRemove = true


      if itemSearchPreview:getItemId() ~= 0 and selectedSkipItem ~= nil then
        if selectedItem.clientId ~= selectedSkipItem then
          canWeRemove = false
        end
      end

      if itemSearchPreview:getItemId() ~= 0 and searchInput:getText() == "" then
        canWeRemove = false
      end

      if isItemInList(selectedItem, skippedItemsToDisplay) and canWeRemove == true then

        if itemSearchPreview:getItemId() == 0 then
          nameLabel:setText(tr("Name") .. ": " )
          weightLabel:setText(tr("Weight") .. ": ")
          descriptionLabel:setText("")
        end

        for _, item in pairs(skippedItemsToDisplay) do
          if item.name ~= selectedItem.name then
            table.insert(newSkippedListToDisplay, item)
          end
        end

        skippedItemsToDisplay = newSkippedListToDisplay
        updateSkippedList()
      end

    end

  end

end


function cleanBackpacks()
  lootBackpackCombobox:setCurrentOptionByData('')
  goldBackpackCombobox:setCurrentOptionByData('')
  stackBackpackCombobox:setCurrentOptionByData('')
end

function updateBackpacks()
  lootBackpackCombobox:setCurrentOptionByData(lootBackpack)
  goldBackpackCombobox:setCurrentOptionByData(goldBackpack)
  stackBackpackCombobox:setCurrentOptionByData(stackBackpack)
end

function updateConvertGold()
  if convertGold == true then
    convertGoldCheckBox:setChecked(true)
  else
    convertGoldCheckBox:setChecked(false)
  end
end

function updateSkippedList()
  skipItemList:destroyChildren()

	table.sort(skippedItemsToDisplay, function(a, b) return a.name:upper() < b.name:upper() end)

  if not table.empty(skippedItemsToDisplay) then

    for id, item in pairs(skippedItemsToDisplay) do

      local tmpLabel = g_ui.createWidget('ItemBox', skipItemList)
      tmpLabel:setId(item.clientId)
      tmpLabel:getChildById('itemPreview'):setItemId(item.clientId)
      tmpLabel:getChildById('itemLabel'):setText(item.name)
      tmpLabel.onClick = updateItemInformation
    end

  end
end

function toSlug(str)
  return string.gsub(string.gsub(str,"[^ A-Za-z]",""),"[ ]+","_")
end

function setBackpackpack(key, value)
  if key == "lootBackpack" then
    lootBackpack = value
  elseif key == "goldBackpack" then
    goldBackpack = value
  else
    stackBackpack = value
  end
end

function getBackpack(key)
  if key == "lootBackpack" then
    return lootBackpack
  elseif key == "goldBackpack" then
    return goldBackpack
  else
    return stackBackpack
  end
end

function getConvertGoldValue()
  return convertGold
end

function saveQuickLootingSettings()
  local char = g_game.getCharacterName()
  if not char or #char == 0 then return end

  local skippedItems = g_settings.getNode('SkippedItems')
  local backpacks = g_settings.getNode('QuickLootBackpacks')
  local lootConvertGold = g_settings.getNode('QuickLootConvertGold')
  if not skippedItems then skippedItems = {} end
  if not backpacks then backpacks = {} end
  if not lootConvertGold then lootConvertGold = {} end

  skippedItems[char] = {}
  backpacks[char] = {}
  lootConvertGold[char] = getConvertGoldValue()

  for key, value in pairs(skippedItemsToDisplay) do
    skippedItems[char][key] = value.serverId
  end

  for _, bp in pairs({'lootBackpack', 'goldBackpack', 'stackBackpack'}) do
    backpacks[char][bp] = getBackpack(bp)
  end

  g_settings.setNode('SkippedItems', skippedItems)
  g_settings.setNode('QuickLootBackpacks', backpacks)
  g_settings.setNode('QuickLootConvertGold', lootConvertGold)

end

function getItemDetails(id)
  for _, item in pairs(getQuickLootItems()) do
    if item.serverId == id then
      return item
    end
  end

  return false
end

function loadQuickLootConvertGold()
  local char = g_game.getCharacterName()
  if not char or #char == 0 then return end

  local convertGoldData = g_settings.getNode('QuickLootConvertGold')
  if not convertGoldData then return end
  if not convertGoldData[char] then return end

  convertGold = convertGoldData[char]
end

function loadQuickLootingBackpacks()
  local char = g_game.getCharacterName()
  if not char or #char == 0 then return end
  local data = {}

  local backpacks = g_settings.getNode('QuickLootBackpacks')
  if not backpacks then return end
  if not backpacks[char] then return end

  for key, value in pairs(backpacks[char]) do
    setBackpackpack(key, value)
  end

end

function loadQuickLootingSettings()
  local char = g_game.getCharacterName()
  if not char or #char == 0 then return end
  local data = {}
  skippedItemsToDisplay = {}

  local skippedItems = g_settings.getNode('SkippedItems')
  if not skippedItems then return end
  if not skippedItems[char] then return end

  for key, value in pairs(skippedItems[char]) do
    local itemDetails = getItemDetails(value)

    if itemDetails then
      table.insert(skippedItemsToDisplay, itemDetails)
    end
  end
end

function sendQuickLootData()
  local stringList = ""

  for _, item in pairs(skippedItemsToDisplay) do
    stringList = stringList .. item.serverId .. ";"
  end

  g_game.quickLootData(stringList, convertGold, lootBackpack, goldBackpack, stackBackpack)
end
