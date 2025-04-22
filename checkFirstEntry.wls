(* check the 1,5-coproduct of the candidate function*)

$HPLPath = "/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/HPL-2.0";
Get[ToFileName[{$HPLPath}, "HPL.m"]];
$PolyLogPath = SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/plt"];
<< PolyLogTools`;
SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop"];

(* <<"R43candidate.m";
dt15 = Delta[{1,5},R43func];//AbsoluteTiming//Print;
dt15>>"Delta15candidate.m"; *)
(* Computing Delta51 corpoducts takes around 10 mins*)

dt15 = <<"Delta15candidate.m"; 


tmp = dt15/.{CT[gf_,expr_]:>CT[gf//ComputeSymbol, expr]//Expand}; //AbsoluteTiming//Print;
(* check all symbols appearing at second entry*)
firstArgs = Cases[tmp, CT[firstArgs_, _ ] :> firstArgs, Infinity];  
Print[firstArgs = firstArgs//Union];


<<"xletts.m" ;
Table[Co[x[idx]] = tmp/.CT[b_, a_]/;b==CiTi[x[idx]/.xletts]:>a/.CT[b_, a_]/;b==CiTi[-x[idx]/.xletts]:>a/._CT:>0;//AbsoluteTiming//Print, {idx,xletts//Length}] ;
Table[Co[x[idx]]//Length,{idx,xletts//Length}]//Print;