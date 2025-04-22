(* check the 1,5-coproduct of the candidate function*)

$HPLPath = "/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/HPL-2.0";
Get[ToFileName[{$HPLPath}, "HPL.m"]];
$PolyLogPath = SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/plt"];
<< PolyLogTools`;
SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop"];

Print["Launch kernels ", DateString[]];
targetnum = 250;
LaunchKernels[targetnum];
While[Length[Kernels[]] < targetnum,
  Print["Only launched " <> ToString[Length[Kernels[]]] <> " kernels, trying again..."];
  LaunchKernels[targetnum - Length[Kernels[]]];
]
Print["Launched kernels ", DateString[]];

(* load PolyLogTools to each kernel *)
ParallelEvaluate[
  $HPLPath = "/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/HPL-2.0";
  Get[ToFileName[{$HPLPath}, "HPL.m"]];
  $PolyLogPath = SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/plt"];
  << PolyLogTools`;
  SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop"];
];

Print["Loaded PolyLogTools", DateString[]];

(* <<"R43candidate.m";
dt15 = Delta[{1,5},R43func];//AbsoluteTiming//Print;
dt15>>"Delta15candidate.m"; *)
(* Computing Delta51 corpoducts takes around 10 mins*)

ParallelEvaluate[
dt15 = <<"Delta15candidate.m";  //AbsoluteTiming//Print;


tmp = dt15/.{CT[gf_,expr_]:>CT[gf//ComputeSymbol, expr]//Expand}; //AbsoluteTiming//Print;
(* check all symbols appearing at second entry*)
firstArgs = Cases[tmp, CT[firstArgs_, _ ] :> firstArgs, Infinity];  
Print[firstArgs = firstArgs//Union];

<<"xletts.m" ;
Table[Co[x[idx]] = tmp/.CT[b_, a_]/;b==CiTi[x[idx]/.xletts]:>a/.CT[b_, a_]/;b==CiTi[-x[idx]/.xletts]:>a/._CT:>0;//AbsoluteTiming//Print, {idx,xletts//Length}] ;
Table[Co[x[idx]]//Length,{idx,xletts//Length}]//Print;
];

(* Most of the 1,5 coproducts are not explicitly 0, check numerically*)
testeval = {u1 -> 0.00001, u3 -> 0.3, v1 -> 0.6, v2 -> 0.2}
(* Launch 250 kernels, load polylogtools, and distribute definitions of Co[] to evaluate in parallel *)

