%module mzscheme
%{
#include "scheme.h"
%}

Scheme_Config   *scheme_config;
Scheme_Env      *scheme_basic_env(void);
Scheme_Object   *scheme_get_param(Scheme_Config *c, const int pos);

#include "scheme.hi"
#include "schemef.hi"
