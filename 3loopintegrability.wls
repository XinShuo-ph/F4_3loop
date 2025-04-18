(* 
    Build up the general functions using the rational letters appearing at 3loops
 *)


outputFileName = "integrablew3.m";


$HPLPath = "/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/HPL-2.0";
Get[ToFileName[{$HPLPath}, "HPL.m"]];
$PolyLogPath = SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/plt"];
<< PolyLogTools`;
SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop"];
kernelidx = $KernelID + idxoffset;
R43x = << "R43x.m";
<< "xletts.m";
(* << "ctdef.m"; *)

threeloopletts = (R43x /. xletts // Variables) /. ct -> Sequence // 
   Union;
threeloopletts = DeleteCases[threeloopletts, u1] // Sort;

uvvar = {u3, v1, v2};
(* derivatives *)
Table[DloglettDvar[i, myvar] = D[Log[i], myvar] // Factor, {myvar, 
  uvvar}, {i, threeloopletts}];
(* handy replacement rules *)
l3repl = 
 Table[l[l3idx] -> threeloopletts[[l3idx]], {l3idx, 
   threeloopletts // Length}];


(* quick and dirty integration to get all weight 2 functions*)
genexpr = 
  Sum[c[i, j] ct[threeloopletts[[i]], threeloopletts[[j]]], {i, 
    threeloopletts // Length}, {j, threeloopletts // Length}];
uvvar = {u3, v1, v2};
Table[DloglettDvar[i, myvar] = D[Log[i], myvar] // Factor, {myvar, 
   uvvar}, {i, threeloopletts}];
Table[{
   DFDvar[var1, var2] =  
    Sum[c[j, i] DloglettDvar[threeloopletts[[i]], var1] DloglettDvar[
       threeloopletts[[j]], var2], {i, threeloopletts // Length} , {j,
       threeloopletts // Length}]}, {var1, uvvar}, {var2, uvvar}];
integrability = 
  Table[DFDvar[uvvar[[var1]], uvvar[[var2]]] - 
      DFDvar[uvvar[[var2]], uvvar[[var1]]] == 0, {var1, 
     uvvar // Length}, {var2, var1 + 1, uvvar // Length}] // Flatten;
Print["symbolic integrability, ", DateString[]];

(*assign random numbers to uvvar and solve eqs*)
numevals = 50;
For[fori = 1, fori <= numevals, fori = fori + 1, {
  (*Print["rand val set "<>ToString[fori]];*)
  randvals = 
   RandomInteger[{1, 30}, uvvar // Length]/
    RandomInteger[{1, 30}, uvvar // Length];
  randuvs = Table[uvvar[[i]] -> randvals[[i]], {i, uvvar // Length}];
  While[Not[(And @@ 
      Thread[DeleteCases[threeloopletts /. randuvs, u1] > 0])],
   {randvals = 
     RandomInteger[{1, 30}, uvvar // Length]/
      RandomInteger[{1, 30}, uvvar // Length];
    randuvs = Table[uvvar[[i]] -> randvals[[i]], {i, uvvar // Length}];
    }
   ];
  (*Print[randuvs];*)
  eq[fori] = Table[{
     integrability[[i]] /. randuvs}, {i, integrability // Length}];
  sol[fori] = Solve[eq[fori] // Flatten];
  }];
Print["numeric integrability, ", DateString[]];
(*then join all the solutions*)
joinedsol = Flatten[Table[sol[tablei][[1]], {tablei, numevals}]];
joinedeq = 
  Table[joinedsol[[tablei]][[1]] == joinedsol[[tablei]][[2]], {tablei,
     joinedsol // Length}];
finalsol = Solve[joinedeq // Flatten];
Print["Solved, ", DateString[]];

integrablew2sym = genexpr /. finalsol[[1]];

ccoefs = Cases[integrablew2sym // Variables, _c];

w2funcs = Table[{
    Print[item];
    FiberSymbol[
     Coefficient[integrablew2sym, item] /. ct -> CiTi, {u3, v1, 
      v2}]}, {item, ccoefs}];
Print["Integrated, ", DateString[]];

w2funcs = w2funcs // Flatten;

(* Save the results to a file *)
Clear[G]
Save[outputFileName, w2funcs];
Print["weight-2 Results saved to " <> outputFileName];


(* next go on to solve general space of arbitrary weight functions*)
(* reuse some results from weight-2*)
adjrel = Table[rel[[1]] == rel[[2]], {rel, finalsol[[1]]}];
adjrel>>"integrability_adjrel.m";
(* use l[1],...,l[19] to represent letters*)
genexprl = 
  Sum[c[i, j] ct[l[i], l[j]], {i, 
    threeloopletts // Length}, {j, threeloopletts // Length}];
integrablew2syml = genexprl /. finalsol[[1]];
integrablew2symllist = 
  Table[Coefficient[integrablew2syml, coef], {coef, ccoefs}];
Save[outputFileName, integrablew2symllist];

genexprlw3 = 
 Sum[cc[idx, 
    idx2]*(integrablew2symllist[[idx]] /. 
     ct[seq__] :> ct[seq, l[idx2]]), {idx, 
   Range[integrablew2symllist // Length]}, {idx2, 
   Range[threeloopletts // Length]}];

Coproductw3[myexpr_, idx1_, 
  idx2_] := ((myexpr /. ct[seq__, l[idx1], l[idx2]] :> ct[seq]) /. 
   ct[seq__] /; Length[{seq}] == 3 :> 0);


Print["Launch kernels ", DateString[]];
LaunchKernels[128];
Print["Launched kernels ", DateString[]];

(* simplify adjrels *)
collectedeqs = ParallelTable[
   {
      Print[relidx];
      tmp[relidx] = (adjrel[[relidx]][[2]] - adjrel[[relidx]][[1]]) /. {c[i_, j_] :> Coproductw3[genexprlw3, i, j]};
      ctvars[relidx] = Cases[tmp[relidx] // Variables, _ct];
      Table[Coefficient[tmp[relidx], var] == 0, {var, ctvars[relidx]}]
   },{relidx,adjrel//Length}
];
collectedeqs = collectedeqs//Flatten;//AbsoluteTiming//Print;
collectedeqs>>"tmp_integrability_w3_eqs.m";
(* collectedsols = Table[
   {
      Print[relidx];
      tmp[relidx] = (adjrel[[relidx]][[2]] - adjrel[[relidx]][[1]]) /. {c[i_, j_] :> Coproductw3[genexprlw3, i, j]};
      ctvars[relidx] = Cases[tmp[relidx] // Variables, _ct];
      Solve[Table[Coefficient[tmp[relidx], var] == 0, {var, ctvars[relidx]}]][[1]]
   },{relidx,adjrel//Length}
]
Save[outputFileName,collectedsols];
collectedsols = collectedsols//Flatten;
sol = Solve[Table[eq[[1]] == eq[[2]],{eq,collectedsols}]]; (*This takes 4 mins *)
Save["w3sol.m",sol] *)

<<"w3sol.m";
integrablew3syml = genexprlw3/.sol[[1]];
integrablew3sym = integrablew3syml/.l3repl;
ccvars = Cases[integrablew3syml//Variables,_cc];
integrablew3symlist = Table[Coefficient[integrablew3sym,var],{var,ccvars}];
integrablew3symllist = Table[Coefficient[integrablew3syml,var],{var,ccvars}];
Save[outputFileName, integrablew3symlist];
Save[outputFileName, integrablew3symllist];
Print["weight-3 Results saved to " <> outputFileName];