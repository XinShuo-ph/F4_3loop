ct[(syma_)/(symb_)] := ct[syma] - ct[symb]
 
ct[(syma_)*(symb_)] := ct[syma] + ct[symb]
 
ct[(syma_)^(pow_)] := pow*ct[syma]
 
ct[(expr1_) + ct[sym_]*(fac_), expr2__] := fac*ct[sym, expr2] + 
     ct[expr1, expr2]
 
ct[expr2__, (expr1_) + ct[sym_]*(fac_)] := fac*ct[expr2, sym] + 
     ct[expr2, expr1]
 
ct[ct[sym_] + (expr1_), expr2__] := ct[sym, expr2] + ct[expr1, expr2]
 
ct[expr2__, ct[sym_] + (expr1_)] := ct[expr2, sym] + ct[expr2, expr1]
 
ct[expr3__, (expr1_) + ct[sym_]*(fac_), expr2__] := 
    fac*ct[expr3, sym, expr2] + ct[expr3, expr1, expr2]
 
ct[expr3__, ct[sym_] + (expr1_), expr2__] := ct[expr3, sym, expr2] + 
     ct[expr3, expr1, expr2]
 
ct[ct[sym_], expr__] := ct[sym, expr]
 
ct[expr__, ct[sym_]] := ct[expr, sym]
 
ct[expr1__, ct[sym_], expr2__] := ct[expr1, sym, expr2]
 
ct[ct[sym_]*(fac_), expr__] := fac*ct[sym, expr]
 
ct[expr__, ct[sym_]*(fac_)] := fac*ct[expr, sym]
 
ct[expr1__, ct[sym_]*(fac_), expr2__] := fac*ct[expr1, sym, expr2]

