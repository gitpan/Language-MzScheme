#pragma SWIG nowarn=302,451,509

%{

#include "scheme.h"

void mzscheme_init () {
    int dummy;
    scheme_set_stack_base(&dummy, 1);
}

%}

void mzscheme_init ();

Scheme_Type     SCHEME_TYPE(Scheme_Object *obj);
int             SCHEME_PROCP(Scheme_Object *obj);
int             SCHEME_SYNTAXP(Scheme_Object *obj);
int             SCHEME_PRIMP(Scheme_Object *obj);
int             SCHEME_CLSD_PRIMP(Scheme_Object *obj);
int             SCHEME_CONTP(Scheme_Object *obj);
int             SCHEME_ECONTP(Scheme_Object *obj);
int             SCHEME_PROC_STRUCTP(Scheme_Object *obj);
int             SCHEME_STRUCT_PROCP(Scheme_Object *obj);
int             SCHEME_GENERICP(Scheme_Object *obj);
int             SCHEME_CLOSUREP(Scheme_Object *obj);

Scheme_Config   *scheme_config;
Scheme_Env      *scheme_basic_env(void);

Scheme_Object   *scheme_make_integer(int i);
Scheme_Object   *scheme_make_character(char ch);
Scheme_Object   *scheme_set_param(Scheme_Config *c, int pos, Scheme_Object *o);
Scheme_Object   *scheme_get_param(Scheme_Config *c, int pos);

Scheme_Object   *scheme_alloc_object();
Scheme_Object   *scheme_alloc_small_object();
Scheme_Object   *scheme_alloc_stubborn_object();
Scheme_Object   *scheme_alloc_stubborn_small_object();
Scheme_Object   *scheme_alloc_eternal_object();
Scheme_Object   *scheme_alloc_eternal_small_object();

#include "mzscheme_wrap.h"

