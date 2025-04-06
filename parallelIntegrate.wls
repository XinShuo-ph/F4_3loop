$HPLPath = "/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/HPL-2.0";
Get[ToFileName[{$HPLPath}, "HPL.m"]];
$PolyLogPath = SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/plt"];
<< PolyLogTools`;

SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop"];
If[!DirectoryQ["2idxfiles"], CreateDirectory["2idxfiles"]];

(* Launch kernels in batches *)
Print["Starting kernel launch process..."];
LaunchKernels[50];
Print["First batch launched. Current kernel count: ", Length[Kernels[]]];

LaunchKernels[50];
Print["Second batch launched. Current kernel count: ", Length[Kernels[]]];

LaunchKernels[50];
Print["Third batch launched. Current kernel count: ", Length[Kernels[]]];

LaunchKernels[20];
Print["Final batch launched. Current kernel count: ", Length[Kernels[]]];




(* I can launch at most 199 kernels, but I need to compute 22*22, so need to do by batch *)
idxoffset = 0;

ParallelEvaluate[
$HPLPath = "/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/HPL-2.0";
Get[ToFileName[{$HPLPath}, "HPL.m"]];
$PolyLogPath = SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/plt"];
<< PolyLogTools`;
SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop"];
kernelidx = $KernelID + idxoffset;
<< "R43finitepartCoFibered.m";
<< "xletts.m";
Table[{
   DlogxDvar[x[idx], myvar] = D[Log[x[idx]] /. xletts, myvar];
   }, {idx, xletts // Length}, {myvar, {v1, v2, u3, u1}}];
(*  let idx and idx2 be in 1-22, so that kernelidx = idx*22 + idx2  *)
idx = Quotient[kernelidx - 1, 22] + 1;
idx2 = Mod[kernelidx - 1, 22] + 1;
time1= AbsoluteTiming[
mytmp = Sum[
   GIntegrate[
    R43finitepartCoFibered[x[idx], x[idx2], x[idx3]]*
     DlogxDvar[x[idx3], u3], u3], {idx3, xletts // Length}];
expr = Collect[mytmp,_G];
terms = List @@ expr;
(* Apply Factor to each term *)
factoredTerms = Factor /@ terms;
(* Recombine the terms into an expression *)
factoredExpr = Plus @@ factoredTerms;
mytmp = factoredExpr;
];
Save["2idxfiles/R43finitepartCoFibered_2idx_"<> ToString[idx] <> "_" <> ToString[idx2] <> ".m", time1];
time2= AbsoluteTiming[mytmp = mytmp // Together;];
Save["2idxfiles/R43finitepartCoFibered_2idx_"<> ToString[idx] <> "_" <> ToString[idx2] <> ".m", time2];
time3= AbsoluteTiming[
mytmp2intgd = 
  Sum[R43finitepartCoFibered[x[idx], x[idx2], x[idx3]]*
       DlogxDvar[x[idx3], v1], {idx3, xletts // Length}] - 
     DG[mytmp, v1] // Expand ;
expr = Collect[mytmp2intgd,_G];
terms = List @@ expr;
(* Apply Factor to each term *)
factoredTerms = Factor /@ terms;
(* Recombine the terms into an expression *)
factoredExpr = Plus @@ factoredTerms;
mytmp2intgd = factoredExpr;
];
Save["2idxfiles/R43finitepartCoFibered_2idx_"<> ToString[idx] <> "_" <> ToString[idx2] <> ".m", time3];
mytmp2 = mytmp + GIntegrate[mytmp2intgd, v1];
time4= AbsoluteTiming[
mytmp3intgd = 
  Sum[R43finitepartCoFibered[x[idx], x[idx2], x[idx3]]*
       DlogxDvar[x[idx3], v2], {idx3, xletts // Length}] - 
     DG[mytmp2, v2] // Expand; 
expr = Collect[mytmp3intgd,_G];
terms = List @@ expr;
(* Apply Factor to each term *)
factoredTerms = Factor /@ terms;
(* Recombine the terms into an expression *)
factoredExpr = Plus @@ factoredTerms;
mytmp3intgd = factoredExpr;
];
Save["2idxfiles/R43finitepartCoFibered_2idx_"<> ToString[idx] <> "_" <> ToString[idx2] <> ".m", time4];
mytmp3 = mytmp2 + GIntegrate[mytmp3intgd, v2];
Clear[G];
Save["2idxfiles/R43finitepartCoFibered_2idx_"<> ToString[idx] <> "_" <> ToString[idx2] <> ".m", mytmp3];

idxoffset = 170;
kernelidx = $KernelID + idxoffset;
idx = Quotient[kernelidx - 1, 22] + 1;
idx2 = Mod[kernelidx - 1, 22] + 1;
If[idx > 22, Exit[]];
time1= AbsoluteTiming[
mytmp = Sum[
   GIntegrate[
    R43finitepartCoFibered[x[idx], x[idx2], x[idx3]]*
     DlogxDvar[x[idx3], u3], u3], {idx3, xletts // Length}];
expr = Collect[mytmp,_G];
terms = List @@ expr;
(* Apply Factor to each term *)
factoredTerms = Factor /@ terms;
(* Recombine the terms into an expression *)
factoredExpr = Plus @@ factoredTerms;
mytmp = factoredExpr;
];
Save["2idxfiles/R43finitepartCoFibered_2idx_"<> ToString[idx] <> "_" <> ToString[idx2] <> ".m", time1];
time2= AbsoluteTiming[mytmp = mytmp // Together;];
Save["2idxfiles/R43finitepartCoFibered_2idx_"<> ToString[idx] <> "_" <> ToString[idx2] <> ".m", time2];
time3= AbsoluteTiming[
mytmp2intgd = 
  Sum[R43finitepartCoFibered[x[idx], x[idx2], x[idx3]]*
       DlogxDvar[x[idx3], v1], {idx3, xletts // Length}] - 
     DG[mytmp, v1] // Expand ;
expr = Collect[mytmp2intgd,_G];
terms = List @@ expr;
(* Apply Factor to each term *)
factoredTerms = Factor /@ terms;
(* Recombine the terms into an expression *)
factoredExpr = Plus @@ factoredTerms;
mytmp2intgd = factoredExpr;
];
Save["2idxfiles/R43finitepartCoFibered_2idx_"<> ToString[idx] <> "_" <> ToString[idx2] <> ".m", time3];
mytmp2 = mytmp + GIntegrate[mytmp2intgd, v1];
time4= AbsoluteTiming[
mytmp3intgd = 
  Sum[R43finitepartCoFibered[x[idx], x[idx2], x[idx3]]*
       DlogxDvar[x[idx3], v2], {idx3, xletts // Length}] - 
     DG[mytmp2, v2] // Expand; 
expr = Collect[mytmp3intgd,_G];
terms = List @@ expr;
(* Apply Factor to each term *)
factoredTerms = Factor /@ terms;
(* Recombine the terms into an expression *)
factoredExpr = Plus @@ factoredTerms;
mytmp3intgd = factoredExpr;
];
Save["2idxfiles/R43finitepartCoFibered_2idx_"<> ToString[idx] <> "_" <> ToString[idx2] <> ".m", time4];
mytmp3 = mytmp2 + GIntegrate[mytmp3intgd, v2];
Clear[G];
Save["2idxfiles/R43finitepartCoFibered_2idx_"<> ToString[idx] <> "_" <> ToString[idx2] <> ".m", mytmp3];

idxoffset = 340;
kernelidx = $KernelID + idxoffset;
idx = Quotient[kernelidx - 1, 22] + 1;
idx2 = Mod[kernelidx - 1, 22] + 1;
If[idx > 22, Exit[]];
time1= AbsoluteTiming[
mytmp = Sum[
   GIntegrate[
    R43finitepartCoFibered[x[idx], x[idx2], x[idx3]]*
     DlogxDvar[x[idx3], u3], u3], {idx3, xletts // Length}];
expr = Collect[mytmp,_G];
terms = List @@ expr;
(* Apply Factor to each term *)
factoredTerms = Factor /@ terms;
(* Recombine the terms into an expression *)
factoredExpr = Plus @@ factoredTerms;
mytmp = factoredExpr;
];
Save["2idxfiles/R43finitepartCoFibered_2idx_"<> ToString[idx] <> "_" <> ToString[idx2] <> ".m", time1];
time2= AbsoluteTiming[mytmp = mytmp // Together;];
Save["2idxfiles/R43finitepartCoFibered_2idx_"<> ToString[idx] <> "_" <> ToString[idx2] <> ".m", time2];
time3= AbsoluteTiming[
mytmp2intgd = 
  Sum[R43finitepartCoFibered[x[idx], x[idx2], x[idx3]]*
       DlogxDvar[x[idx3], v1], {idx3, xletts // Length}] - 
     DG[mytmp, v1] // Expand ;
expr = Collect[mytmp2intgd,_G];
terms = List @@ expr;
(* Apply Factor to each term *)
factoredTerms = Factor /@ terms;
(* Recombine the terms into an expression *)
factoredExpr = Plus @@ factoredTerms;
mytmp2intgd = factoredExpr;
];
Save["2idxfiles/R43finitepartCoFibered_2idx_"<> ToString[idx] <> "_" <> ToString[idx2] <> ".m", time3];
mytmp2 = mytmp + GIntegrate[mytmp2intgd, v1];
time4= AbsoluteTiming[
mytmp3intgd = 
  Sum[R43finitepartCoFibered[x[idx], x[idx2], x[idx3]]*
       DlogxDvar[x[idx3], v2], {idx3, xletts // Length}] - 
     DG[mytmp2, v2] // Expand; 
expr = Collect[mytmp3intgd,_G];
terms = List @@ expr;
(* Apply Factor to each term *)
factoredTerms = Factor /@ terms;
(* Recombine the terms into an expression *)
factoredExpr = Plus @@ factoredTerms;
mytmp3intgd = factoredExpr;
];
Save["2idxfiles/R43finitepartCoFibered_2idx_"<> ToString[idx] <> "_" <> ToString[idx2] <> ".m", time4];
mytmp3 = mytmp2 + GIntegrate[mytmp3intgd, v2];
Clear[G];
Save["2idxfiles/R43finitepartCoFibered_2idx_"<> ToString[idx] <> "_" <> ToString[idx2] <> ".m", mytmp3];
]