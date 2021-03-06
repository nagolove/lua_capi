/*#include "chipmunk/chipmunk.h"*/
/*#include "chipmunk/chipmunk_structs.h"*/

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
                                  printf("ā%sā", lua_tostring(L, i));
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

/*
 *static int each_body(lua_State *lua) {
 *    luaL_checktype(lua, 1, LUA_TFUNCTION);
 *    int call_count = (int)lua_tonumber(lua, 2);
 *    printf("call_count %d\n", call_count);
 *    for (int i = 0; i < call_count; i++) {
 *        [>lua_call(lua, 1, 0);<]
 *        lua_pushvalue(lua, 1);
 *        lua_pushnumber(lua, i);
 *        lua_call(lua, 1, 0);
 *    }
 *    return 0;
 *}
 *
 */

/*
 *static int query_all_shapes(lua_State *lua) {
 *    printf("cur_space %p\n", cur_space);
 *    print_space_info(cur_space);
 *    assert(cur_space);
 *
 *    printf("C: query_all_shapes\n");
 *
 *    luaL_checktype(lua, 1, LUA_TFUNCTION);
 *
 *    printf("C: query_all_shapes after\n");
 *    [>printf("C: query_all_shapes after\n");<]
 *
 *    return 0;
 *}
 *
 */

static int ret_table(lua_State *lua) {
    printf("Š²Š¾Š·Š²ŃŠ°ŃŠ°ŠµŃ ŃŠ°Š±Š»ŠøŃŃ ŃŠøŃŠµŠ»\n");
    lua_newtable(lua);
    for(int i = 10; i >= 1; i--) {
        /*lua_pushvalue(lua, i);*/
        lua_pushnumber(lua, i);
        lua_pushnumber(lua, i);
        lua_settable(lua, -3);
    }
    return 1;
}

static int samplest(lua_State *lua) {
    printf("ŠæŃŠ¾ŃŃŠµŠ¹ŃŠ°Ń ŃŃŠ½ŠŗŃŠøŃ, Š±ŠµŠ· ŠæŠ°ŃŠ°Š¼ŠµŃŃŠ¾Š²\n");
    return 0;
}

extern int luaopen_wrapper17(lua_State *lua) {
    /*cpSpace *space = cpSpaceNew();*/
    static const struct luaL_Reg functions[] =
    {
         {"samplest", samplest},
         {"ret_table", ret_table},
         {NULL, NULL}
    };
    /*luaL_newlib(lua, functions);*/
    /*luaL_newlib(lua, functions);*/
    /*lua_register(lua, "wrapper", functions);*/
    luaL_register(lua, "wrapper", functions);
    printf("hello from C\n");
    return 1;
}
