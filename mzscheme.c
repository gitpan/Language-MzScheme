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
mzscheme_from_perl_scalar (Perl_Scalar sv) {
    return (
        SvIOK(sv) ? scheme_make_integer_value( (int)SvIV(sv) ) :
        SvNOK(sv) ? scheme_make_double( (double)SvNV(sv) ) :
        SvPOK(sv) ? scheme_make_string( (char *)SvPV(sv, PL_na) ) :
        (SvTYPE(sv) == SVt_PVCV)
            ? mzscheme_make_perl_prim_w_arity((Perl_Scalar)sv, "", 0, -1)
            : scheme_undefined
    );
}

Scheme_Object *
_mzscheme_closed_prim_CV (void *callback, int argc, Scheme_Object **argv) {
    dSP ;
    Scheme_Object **return_values;
    I32 count, i;

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

    count = call_sv((SV*)callback, G_ARRAY);

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

AV *
_mzscheme_objects_AV (Scheme_Object ** objects) {
    AV *myav;
    SV **svs;
    int i = 0, len = 0;
    while (objects[len]) {
        len++;
    };
    svs = (SV **)malloc(len*sizeof(SV *));
    for (i = 0; i < len ; i++) {
        svs[i] = sv_newmortal();
        sv_setref_pv((SV*)svs[i], (char *)&SWIGTYPE_p_Scheme_Object, objects[i]);
    };
    myav = av_make(len, svs);
    free(svs);
    return myav;
}
