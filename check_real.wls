(* check the w3 functions, and my R43 ansatz are real*)


(**** This preamble seems to correctly load PolyLogTools in parallel ****)

$HPLPath = "/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/HPL-2.0";
Get[ToFileName[{$HPLPath}, "HPL.m"]];
$PolyLogPath = SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/plt"];
<< PolyLogTools`;
SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop"];

(* Launch kernels in batches, LaunchKernels[256] would lead to error *)
Print["Starting kernel launch process..."];
While[Length[Kernels[]] < ($ProcessorCount)*(oversubscriberatio),{
LaunchKernels[50];
Print["Current kernel count: ", Length[Kernels[]]];
}]

(* load PolyLogTools to each kernel *)
ParallelEvaluate[
  $HPLPath = "/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/HPL-2.0";
  Get[ToFileName[{$HPLPath}, "HPL.m"]];
  $PolyLogPath = SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/plt"];
  << PolyLogTools`;
  SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop"];
];

Print["Loaded PolyLogTools", DateString[]];
(**** This preamble seems to correctly load PolyLogTools in parallel ****)


(* load R43 to each kernel*)
ParallelEvaluate[
    <<"R43candidate.m";
    <<"xletts.m";
    reversemap = Table[{ctt[item[[2]]]->item[[1]],
        ctt[-item[[2]]]->item[[1]]},{item,xletts}]//Reverse//Flatten ;
]
Print["Loaded R43 ", DateString[]];

testeval = {u1 -> 0.00001, u3 -> 0.3, v1 -> 0.6, v2 -> 0.2}



