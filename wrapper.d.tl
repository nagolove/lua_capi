local cm = require 'chipmunk'

global record Wrapper
    --average: function(...:any): number
    --each_body: function(function(iter_num: integer), call_count: integer)
    init_space: function(space: cm.cpSpace)

    type EachShapeCallback = function(x: number, y: number, angle: number, obj: any)
    --query_all_shapes: function(space: cm.cpSpace, EachShapeCallback)
    query_all_shapes: function(EachShapeCallback)
    --pass_combo: function(cdata: any)
end

return Wrapper
