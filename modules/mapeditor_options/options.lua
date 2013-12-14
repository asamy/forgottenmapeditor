Options = {}

local defaultOptions = {
  vsync = false,
  showFps = true,
  fullscreen = false,
  lockvisible = true,
  toggleAnimations = true,
  toggleForceShowAnimations = false,
  foregroundFrameRate = 61,
  backgroundFrameRate = 201,
  painterEngine = 0
}

local optionsWindow
local optionsButton
local optionsTabBar
local options = {}
local generalPanel
local graphicsPanel

local function setupGraphicsEngines()
  local enginesRadioGroup = UIRadioGroup.create()
  local ogl1 = graphicsPanel:getChildById('opengl1')
  local ogl2 = graphicsPanel:getChildById('opengl2')
  enginesRadioGroup:addWidget(ogl1)
  enginesRadioGroup:addWidget(ogl2)

  if g_graphics.getPainterEngine() == 2 then
    enginesRadioGroup:selectWidget(ogl2)
  else
    enginesRadioGroup:selectWidget(ogl1)
  end

  ogl1:setEnabled(g_graphics.isPainterEngineAvailable(1))
  ogl2:setEnabled(g_graphics.isPainterEngineAvailable(2))

  enginesRadioGroup.onSelectionChange = function(self, selected)
    if selected == ogl1 then
      Options.setOption('painterEngine', 1)
    elseif selected == ogl2 then
      Options.setOption('painterEngine', 2)
    end
  end

  if not g_graphics.canCacheBackbuffer() then
    graphicsPanel:getChildById('foregroundFrameRate'):disable()
    graphicsPanel:getChildById('foregroundFrameRateLabel'):disable()
  end
end

function Options.init()
  -- load options
  for k,v in pairs(defaultOptions) do
    g_settings.setDefault(k, v)
    if type(v) == 'boolean' then
      Options.setOption(k, g_settings.getBoolean(k))
    elseif type(v) == 'number' then
      Options.setOption(k, g_settings.getNumber(k))
    end
  end

  optionsWindow = g_ui.displayUI('options.otui')
  optionsWindow:hide()
  optionsButton = modules.mapeditor_topmenu.addLeftButton('optionsButton', tr('Options') .. ' (Ctrl+D)', '/images/topbuttons/options', Options.toggle)

  optionsTabBar = optionsWindow:getChildById('optionsTabBar')
  optionsTabBar:setContentWidget(optionsWindow:getChildById('optionsTabContent'))

  graphicsPanel = g_ui.loadUI('graphics.otui')
  optionsTabBar:addTab(tr('Graphics'), graphicsPanel)

  setupGraphicsEngines()
end

function Options.terminate()
  optionsWindow:destroy()
  optionsWindow = nil
  optionsButton:destroy()
  optionsButton = nil
  optionsTabBar = nil
  generalPanel = nil
  graphicsPanel = nil
  Options = nil
end

function Options.toggle()
  if optionsWindow:isVisible() then
    Options.hide()
  else
    Options.show()
  end
end

function Options.show()
  optionsWindow:show()
  optionsWindow:raise()
  optionsWindow:focus()
end

function Options.hide()
  optionsWindow:hide()
end

function Options.toggleOption(key)
  Options.setOption(key, not Options.getOption(key))
end

function Options.setOption(key, value)
  if options[key] == value then return end
  if key == 'vsync' then
    g_window.setVerticalSync(value)
  elseif key == 'toggleAnimations' then
    g_map.setShowAnimations(value)
  elseif key == 'toggleForceShowAnimations' then
    g_map.setForceShowAnimations(value)
  elseif key == 'showFps' then
    addEvent(function()
      local frameCounter = rootWidget:recursiveGetChildById('frameCounter')
      if frameCounter then frameCounter:setVisible(value) end
    end)
  elseif key == 'fullscreen' then
    g_window.setFullscreen(value)
  elseif key == 'backgroundFrameRate' then
    local text = value
    if value <= 0 or value >= 201 then
      text = 'max'
      value = 0
    end

    if graphicsPanel then
      graphicsPanel:getChildById('backgroundFrameRateLabel'):setText(tr('Game framerate limit: %s', text))
    end
    g_app.setBackgroundPaneMaxFps(value)
  elseif key == 'foregroundFrameRate' then
    local text = value
    if value <= 0 or value >= 61 then
      text = 'max'
      value = 0
    end

    if graphicsPanel then
      graphicsPanel:getChildById('foregroundFrameRateLabel'):setText(tr('Interface framerate limit: %s', text))
    end
    g_app.setForegroundPaneMaxFps(value)
  elseif key == 'painterEngine' then
    g_graphics.selectPainterEngine(value)
  end
  g_settings.set(key, value)
  options[key] = value
end

function Options.getOption(key)
  return options[key]
end


