local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local ipairs = _tl_compat and _tl_compat.ipairs or ipairs; local math = _tl_compat and _tl_compat.math or math; local package = _tl_compat and _tl_compat.package or package; local pcall = _tl_compat and _tl_compat.pcall or pcall; print('hello. I scene from separated thread')


require("love")
require("love_inc").require_pls_nographic()
require('pipeline')



love.filesystem.setRequirePath("?.lua;?/init.lua;scenes/lua_capi/?.lua")
local cpath = love.filesystem.getCRequirePath()

love.filesystem.setCRequirePath("scenes/lua_capi/?.so;?.so")
package.cpath = package.cpath .. ";./scenes/lua_capi/?.so"
print('package.cpath', package.cpath)


print('getCRequirePath()', love.filesystem.getCRequirePath())

local colorize = require('ansicolors2').ansicolors


local event_channel = love.thread.getChannel("event_channel")

local mx, my = 0, 0

local last_render

local pipeline = Pipeline.new()


local inspect = require("inspect")

local function test_capi()
   local ok, errmsg = pcall(function()


      local wrp = require("wrapper17")
      print('samplest', wrp.samplest())
      print('ret_table', inspect(wrp.ret_table()))
   end)
   if not ok then
      print(colorize("%{green}test_capi " .. "%{red}" .. errmsg))
   end
end

test_capi()








local function init()
   local rendercode = [[
    while true do
        local w, h = love.graphics.getDimensions()
        local x, y = math.random() * w, math.random() * h
        love.graphics.setColor{0, 0, 0}
        love.graphics.print("TestTest", x, y)

        coroutine.yield()
    end
    ]]
   pipeline:pushCode('text', rendercode)



   pipeline:pushCode('clear', [[
    while true do
        love.graphics.clear{0.5, 0.5, 0.5}

        coroutine.yield()
    end
    ]])

   last_render = love.timer.getTime()
end

local function render()
   pipeline:openAndClose('clear')

   pipeline:open('text')
   pipeline:close()

   pipeline:sync()
end

local function mainloop()
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

      local pause = 1. / 300.
      if nt - last_render >= pause then
         last_render = nt



         render()
      end







      love.timer.sleep(0.0001)
   end
end

init()
mainloop()

print('goodbye. I scene from separated thread')
