#include "chipmunk/chipmunk.h"
#include "chipmunk/chipmunk_structs.h"
#include <assert.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <stdint.h>
#include <stdio.h>

static void stackDump (lua_State *L) {
    int i;
    int top = lua_gettop(L);
    for (i = 1; i <= top; i++) { /* repeat for each level */
        int t = lua_type(L, i);
        switch (t) {
            case LUA_TSTRING: { /* strings */
                                  printf("’%s’", lua_tostring(L, i));
                                  break;
                              }
            case LUA_TBOOLEAN: { /* booleans */
                                   printf(lua_toboolean(L, i) ? "true" : "false");
                                   break;
                               }
            case LUA_TNUMBER: { /* numbers */
                                  printf("%g", lua_tonumber(L, i));
                                  break;
                              }
            default: { /* other values */
                         printf("%s", lua_typename(L, t));
                         break;
                     }
        }
        printf(" "); /* put a separator */
    }
    printf("\n"); /* end the listing */
}

/* The function we'll call from the lua script */
static int average(lua_State *L)
{
    /* get number of arguments */
    int n = lua_gettop(L);
    double sum = 0;
    int i;

    /* loop through each argument */
    for (i = 1; i <= n; i++)
    {
        if (!lua_isnumber(L, i)) 
        {
            lua_pushstring(L, "Incorrect argument to 'average'");
            lua_error(L);
        }

		/* total the arguments */
		sum += lua_tonumber(L, i);
	}

	/* push the average */
	lua_pushnumber(L, sum / n);

	/* push the sum */
	lua_pushnumber(L, sum);

	/* return the number of results */
	return 2;
}

static int each_body(lua_State *lua) {
    luaL_checktype(lua, 1, LUA_TFUNCTION);
    int call_count = (int)lua_tonumber(lua, 2);
    printf("call_count %d\n", call_count);
    for (int i = 0; i < call_count; i++) {
        /*lua_call(lua, 1, 0);*/
        lua_pushvalue(lua, 1);
        lua_pushnumber(lua, i);
        lua_call(lua, 1, 0);
    }
    return 0;
}

static cpSpace *cur_space = NULL;

static int init_space(lua_State *lua) {
    int type = lua_type(lua, 1);
    printf("type %d\n", type);
    /*cur_space = (cpSpace*)lua_topointer(lua, 1);*/
    cur_space = cpSpaceNew();

    return 0;
}

static int new_box_body(lua_State *lua) {
    // in: ширина, высота, таблица с инфой

    int w = (int)lua_tonumber(lua, 1);
    int h = (int)lua_tonumber(lua, 2);

    cpBody *b = cpBodyNew(mass, moment);

    int reg_index = luaL_ref(lua, LUA_REGISTRYINDEX);

    return 0;
}

void on_each_body(cpBody *body, void *data) {
    printf("on_each_body\n");
}

void print_space_info(cpSpace *space) {
    printf("iterations %d\n", space->iterations);
    printf("damping %f\n", space->damping);
    printf("data %p\n", space->userData);
    printf("curr_dt %f\n", space->curr_dt);
    printf("stamp %d\n", space->stamp);
}

static int query_all_shapes(lua_State *lua) {
    printf("cur_space %p\n", cur_space);
    print_space_info(cur_space);
    assert(cur_space);

    printf("C: query_all_shapes\n");

    luaL_checktype(lua, 1, LUA_TFUNCTION);

    cpSpaceEachBody(cur_space, on_each_body, NULL);
    /*cpSpaceEachBody(cur_space, NULL, NULL);*/

    printf("C: query_all_shapes after\n");
    /*printf("C: query_all_shapes after\n");*/

    return 0;
}

extern int luaopen_wrapper(lua_State *lua) {
    /*cpSpace *space = cpSpaceNew();*/
    static const struct luaL_Reg functions[] =
    {
         /*{"average", average},*/
         /*{"each_body", each_body},*/
         {"init_space", init_space},
         {"query_all_shapes", query_all_shapes},
         {"new_box_body", new_box_body},
         /*{"pass_combo", pass_combo},*/
         {NULL, NULL}
    };
    /*luaL_newlib(lua, functions);*/
    /*luaL_newlib(lua, functions);*/
    /*lua_register(lua, "wrapper", functions);*/
    luaL_register(lua, "wrapper", functions);
    printf("hello from C\n");
    return 1;
}
