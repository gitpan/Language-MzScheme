#pragma SWIG nowarn=302,451,509

%{
#include "mzscheme.c"
%}

%typemap(in) Perl_Scalar {
    $1 = (void *)$input;
}

%typemap(out) Perl_Scalar {
    $result = (SV *)$1;
}

%typemap(in) Scheme_Object ** {
    AV *tempav;
    I32 len;
    int i;
    SV  **tv;
    if (!SvROK($input))
        croak("argument $argnum is not a reference.");
    if (SvTYPE(SvRV($input)) != SVt_PVAV)
        croak("argument $argnum is not an array.");
    tempav = (AV*)SvRV($input);
    len = av_len(tempav);
    $1 = (Scheme_Object **) malloc((len+2)*sizeof(Scheme_Object *));
    for (i = 0; i <= len; i++) {
        tv = av_fetch(tempav, i, 0);
        $1[i] = (Scheme_Object *) SvIV((SV*)SvRV(*tv));
    }
    $1[i] = NULL;
};

%typemap(freearg) Scheme_Object ** {
    free($1);
}

%typemap(out) Scheme_Object ** {
    $result = newRV((SV *)_mzscheme_objects_AV($1));
    sv_2mortal($result);
    argvi++;
}

void            mzscheme_init();
Scheme_Object*  mzscheme_make_perl_prim_w_arity(Perl_Scalar cv_ref, const char *name, int mina, int maxa);
Scheme_Object * mzscheme_from_perl_scalar (Perl_Scalar sv);

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

