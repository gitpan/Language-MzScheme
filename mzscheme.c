#include "scheme.h"
#include "mzscheme.h"

void
mzscheme_init () {
    int dummy;
    scheme_set_stack_base(&dummy, 1);
}

Scheme_Object *
mzscheme_make_perl_prim_w_arity (Perl_Scalar cv_ref, const char *name, int mina, int maxa) {
    SvREFCNT_inc((SV *)cv_ref);
    return scheme_make_closed_prim_w_arity(
        &_mzscheme_closed_prim_CV,
        (void *)cv_ref, name, mina, maxa
    );
}

Scheme_Object *
mzscheme_make_perl_object_w_arity (Perl_Scalar object, const char *name, int mina, int maxa) {
    SvREFCNT_inc((SV *)object);
    return scheme_make_closed_prim_w_arity(
        &_mzscheme_closed_prim_OBJ,
        (void *)object, name, mina, maxa
    );
}

Scheme_Object *
mzscheme_from_perl_scalar (Perl_Scalar sv) {
    Scheme_Object *temp;

    return (
        SvROK(sv) ?
            (SWIG_ConvertPtr(sv, (void **) &temp, SWIGTYPE_p_Scheme_Object, 0) >= 0)
                ? temp :
            sv_isobject(SvRV(sv))
                ? mzscheme_make_perl_object_w_arity((Perl_Scalar)SvRV(sv), SvPV(sv, PL_na), 0, -1) :
            (SvTYPE(SvRV(sv)) == SVt_PVCV)
                ? mzscheme_make_perl_prim_w_arity((Perl_Scalar)SvRV(sv), SvPV(sv, PL_na), 0, -1)
                : scheme_void :
        SvIOK(sv) ? scheme_make_integer_value( (int)SvIV(sv) ) :
        SvNOK(sv) ? scheme_make_double( (double)SvNV(sv) ) :
        SvPOK(sv) ? scheme_make_string( (char *)SvPV(sv, PL_na) ) : scheme_void
    );
}

void
_mzscheme_enter (int argc, Scheme_Object **argv) {
    dSP ;
    int i;

    push_scope() ;
    SAVETMPS;

    PUSHMARK(SP) ;
    EXTEND(SP, argc);

    for (i = 0; i < argc; i++) {
        SV *sv = sv_newmortal();
        SWIG_MakePtr(sv, (void *)argv[i], SWIGTYPE_p_Scheme_Object, 0);
        PUSHs(sv);
    }

    PUTBACK ;
}

void
_mzscheme_enter_with_sv (Perl_Scalar sv, int argc, Scheme_Object **argv) {
    dSP ;
    int i;

    push_scope() ;
    SAVETMPS;

    PUSHMARK(SP) ;
    EXTEND(SP, argc);

    PUSHs(sv);

    for (i = 1; i < argc; i++) {
        SV *sv = sv_newmortal();
        SWIG_MakePtr(sv, (void *)argv[i], SWIGTYPE_p_Scheme_Object, 0);
        PUSHs(sv);
    }

    PUTBACK ;
}

Scheme_Object *
_mzscheme_leave (int count) {
    dSP ;
    Scheme_Object **return_values;
    int i;

    SPAGAIN ;
    return_values = (Scheme_Object **) malloc((count+2)*sizeof(Scheme_Object *));

    for (i = count - 1; i >= 0 ; i--) {
        return_values[i] = mzscheme_from_perl_scalar(POPs);
    }

    PUTBACK ;
    FREETMPS ;
    LEAVE ;

    return scheme_build_list((int)count, return_values);
}

Scheme_Object *
_mzscheme_closed_prim_CV (void *callback, int argc, Scheme_Object **argv) {
    _mzscheme_enter(argc, argv);
    return _mzscheme_leave( (int)call_sv((SV*)callback, G_ARRAY) );
}

Scheme_Object *
_mzscheme_closed_prim_OBJ (void *callback, int argc, Scheme_Object **argv) {
    const char *method;

    if (argc == 0) {
        return scheme_undefined;
    }

    method = SCHEME_STRSYM_VAL(argv[0]);
    _mzscheme_enter_with_sv((SV *)callback, argc, argv);
    return _mzscheme_leave( (int)call_method(method, G_ARRAY) );
}

AV *
_mzscheme_objects_AV (void **objects, char *type) {
    AV *myav;
    SV **svs;
    int i = 0, len = 0;
    while (objects[len]) {
        len++;
    };
    svs = (SV **)malloc(len*sizeof(SV *));
    for (i = 0; i < len ; i++) {
        svs[i] = sv_newmortal();
        SWIG_MakePtr(svs[i], (void *)objects[i], SWIGTYPE_p_Scheme_Object, 0);
    };
    myav = av_make(len, svs);
    free(svs);
    return myav;
}
