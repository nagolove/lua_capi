local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local ipairs = _tl_compat and _tl_compat.ipairs or ipairs; local math = _tl_compat and _tl_compat.math or math; local os = _tl_compat and _tl_compat.os or os; print('hello. I scene from separated thread')
print('hello. I scene from separated thread')


require("love")
require("love_inc").require()



love.filesystem.setRequirePath("?.lua;?/init.lua;scenes/empty/?.lua")
local i18n = require("i18n")














local event_channel = love.thread.getChannel("event_channel")
local draw_ready_channel = love.thread.getChannel("draw_ready_channel")
local graphic_command_channel = love.thread.getChannel("graphic_command_channel")
local graphic_code_channel = love.thread.getChannel("graphic_code_channel")

local mx, my = 0, 0

local time = love.timer.getTime()
local dt = 0.

local Pipeline = {}


















local Pipeline_mt = {
   __index = Pipeline,
}

function Pipeline.new()
   local self = setmetatable({}, Pipeline_mt)
   return self
end

function Pipeline:enter(_)

end

function Pipeline:leave()

end

function Pipeline:pushName(_)

end

function Pipeline:push(_)

end

function Pipeline:ready()
   local is_ready = draw_ready_channel:peek()
   if is_ready then
      if type(is_ready) ~= 'string' then
         print("Type error in is_ready flag")

         os.exit(250)
      end
      if is_ready ~= "ready" then
         local msg = tostring(is_ready) or ""
         print("Bad message in draw_ready_channel: " .. msg)

         os.exit(249)
      end
      draw_ready_channel:pop()
      return true
   end
   return false
end


function pushCode(name, code)
   if not name then
      error("No name for pushCode()")
   end
   if not code then
      error("No code for pushCode()")
   end

   graphic_code_channel:push(name)
   graphic_code_channel:push(code)
end

local pipeline = Pipeline.new()







local rendercode = [[
-- Как пропихнуть глобальную переменную?

local s: integer = 1
-- Как понять, что используются данные из нужного потока?
local y = graphic_command_channel:demand()
local x = graphic_command_channel:demand()

--delkwffj
--z = 1
--z = "hi"

local gr = love.graphics
gr.clear(0.5, 0.5, 0.5)
gr.setColor{0, 0, 0}
gr.print("TestTest", x, y)
]]

local function init()
   i18n.set('en.welcome', 'welcome to this program')
   i18n.load({
      en = {
         good_bye = "good-bye!",
         age_msg = "your age is %{age}.",
         phone_msg = {
            one = "you have one new message.",
            other = "you have %{count} new messages.",
         },
      },
   })
   print("translated", i18n.translate('welcome'))
   print("translated", i18n('welcome'))

   graphic_code_channel:push(rendercode)

end

init()

while true do

   local events = event_channel:pop()
   if events then
      for _, e in ipairs(events) do
         local evtype = (e)[1]
         if evtype == "mousemoved" then
            mx = math.floor((e)[2])
            my = math.floor((e)[3])
         elseif evtype == "keypressed" then
            local key = (e)[2]
            local scancode = (e)[3]
            print('keypressed', key, scancode)
            if scancode == "escape" then
               love.event.quit()
            end
         elseif evtype == "mousepressed" then





         end
      end
   end

   local nt = love.timer.getTime()
   dt = nt - time
   time = nt


   if pipeline:ready() then





      local x, y = love.mouse.getPosition()




      graphic_command_channel:push(y)



      graphic_command_channel:push(x)













   end

   love.timer.sleep(0.001)
end









print('goodbye. I scene from separated thread')