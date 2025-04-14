(* check the coproduct of the candidate function*)

$HPLPath = "/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/HPL-2.0";
Get[ToFileName[{$HPLPath}, "HPL.m"]];
$PolyLogPath = SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/plt"];
<< PolyLogTools`;
SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop"];

(* <<"R43candidate.m";
dt51 = Delta[{5,1},R43func];//AbsoluteTiming//Print;
dt51>>"Delta51candidate.m"; *)
(* Computing Delta51 corpoducts takes around 10 mins*)

dt51 = <<"Delta51candidate.m"; 

tmp = dt51/.CT[expr_,gf_]:>CT[expr,gf//ComputeSymbol]; 
(* check all symbols appearing at second entry*)
secondArgs = Cases[tmp, CT[_, secondArg_] :> secondArg, Infinity];  
Print[lastentries = secondArgs//Union   ];

<<"xletts.m" ;
Table[Co[x[idx]] = tmp/.CT[a_,b_]/;b==CiTi[x[idx]/.xletts]:>a/.CT[a_,b_]/;b==CiTi[-x[idx]/.xletts]:>a/._CT:>0;//AbsoluteTiming//Print, {idx,20}] ;
Table[Co[x[idx]]//Length,{idx,20}]//Print;
Print[Co[x[1]] + Co[x[3]] + Co[x[10]] + Co[x[11]] + Co[x[13]] + Co[x[15]]//Expand];
Print[Co[x[4]] + Co[x[7]] + Co[x[10]] + Co[x[13]] + Co[x[15]] //Expand];
Print[Co[x[5]] + Co[x[8]] + Co[x[11]] + Co[x[15]]//Expand];

