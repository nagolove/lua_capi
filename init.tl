print('hello. I scene from separated thread')

--local tl = require "tl"
require "love"
require "love_inc".require_pls_nographic()
require 'pipeline'

--require "love.timer"

love.filesystem.setRequirePath("?.lua;?/init.lua;scenes/lua_capi/?.lua")
local cpath = love.filesystem.getCRequirePath()
love.filesystem.setCRequirePath(love.filesystem.getCRequirePath() .. ";scenes/lua_capi/?.so")
--love.filesystem.setCRequirePath(cpath .. ";./scenes/lua_capi/?.so")

print('getCRequirePath()', love.filesystem.getCRequirePath())

local colorize = require 'ansicolors2'.ansicolors
--local format = string.format

local event_channel = love.thread.getChannel("event_channel")

local mx, my = 0, 0

local last_render: number

local pipeline = Pipeline.new()

--require 'wrapper'

local function test_capi()
    local ok, errmsg: boolean, string = pcall(function()
        local wrp = require "wrapper17"
        error('fuck')
        --wrapper.samplest()
        --wrapper.ret_table()
    end)
    if not ok then
        print(colorize("%{green}test_capi " .. "%{red}" .. errmsg))
    end
end

test_capi()

-- Как часто перекомпилировать код рисовки?
-- Варианты - 
--  * по таймеру
--  * используя метод :peek() на каждой итерации цикла
-- Сейчас функция компилируется один раз при загрузке файла исходного текста
-- потока.

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

    -- Допустимо-ли переопределение функций? Или добавить специальный флаг?
    -- Нормально-ли использовать константы?
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
        local events = event_channel:pop() as {any}
        if events then
            for _, e in ipairs(events) do
                local evtype: string = (e as {string})[1]
                if evtype == "mousemoved" then
                    mx = math.floor((e as {number})[2])
                    my = math.floor((e as {number})[3])
                elseif evtype == "keypressed" then
                    local key = (e as {string})[2]
                    local scancode = (e as {string})[3]
                    print('keypressed', key, scancode)
                    if scancode == "escape" then
                        love.event.quit()
                    end
                elseif evtype == "mousepressed" then
                    --local x: number = (e as {number})[2]
                    --local y: number = (e as {number})[3]
                    --local button: number = (e as {number})[4]
                    --local istouch: boolean = (e as {boolean})[5]
                    --local presses: number = (e as {number})[6]
                end
            end
        end
        
        local nt = love.timer.getTime()
        --local pause = 1. / 10.
        local pause = 1. / 300.
        if nt - last_render >= pause then
            last_render = nt
            --local msg = 'love.timer.getTime() = %f'
            --print(colorize('%{blue}' .. format(msg, love.timer.getTime())))

            render()
        end
        --]]

        --[[
        Ограничение кадров в секунду до 60
        --]]

        --love.timer.sleep(0.0008)
        love.timer.sleep(0.0001)
    end
end

init()
mainloop()

print('goodbye. I scene from separated thread')
