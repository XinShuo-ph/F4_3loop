(* float z5, z4*log, z3*weight2, z2*weight3 functions to all the 7 independant coproducts, extracted from Delta51 of the candidate *)
(* then re-do the integration to get the Ansatz of R43rat*)

$HPLPath = "/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/HPL-2.0";
Get[ToFileName[{$HPLPath}, "HPL.m"]];
$PolyLogPath = SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/plt"];
<< PolyLogTools`;
SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop"];


dt51 = <<"Delta51candidate.m"; 
Print["reading done",DateString[]];

tmp = dt51/.CT[expr_,gf_]:>CT[expr,gf//ComputeSymbol]; 
Print["processing done",DateString[]];
(* check all symbols appearing at second entry*)
secondArgs = Cases[tmp, CT[_, secondArg_] :> secondArg, Infinity];  
Print[lastentries = secondArgs//Union   ];

<<"xletts.m" ;
Print["Extracting coproducts",DateString[]];
Table[Co[x[idx]] = tmp/.CT[a_,b_]/;b==CiTi[x[idx]/.xletts]:>a/.CT[a_,b_]/;b==CiTi[-x[idx]/.xletts]:>a/._CT:>0;//AbsoluteTiming//Print, {idx,20}] ;
Table[Co[x[idx]]//Length,{idx,20}]//Print;
Print["Checking relations",DateString[]]
Print[Co[x[1]] + Co[x[3]] + Co[x[10]] + Co[x[11]] + Co[x[13]] + Co[x[15]]//Expand];
Print[Co[x[4]] + Co[x[7]] + Co[x[10]] + Co[x[13]] + Co[x[15]] //Expand];
Print[Co[x[5]] + Co[x[8]] + Co[x[11]] + Co[x[15]]//Expand];



(* Next, float some zeta numbers to the Co[] and re-integrate the full function*)