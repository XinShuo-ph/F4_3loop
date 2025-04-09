(* Do FiberSymbol in parallel *)

w3dim = 2343

$HPLPath = "/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/HPL-2.0";
Get[ToFileName[{$HPLPath}, "HPL.m"]];
$PolyLogPath = SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/plt"];
<< PolyLogTools`;

SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop"];
If[!DirectoryQ["w3fiber"], CreateDirectory["w3fiber"]];

(* Launch kernels in batches *)
Print["Starting kernel launch process..."];
LaunchKernels[50];
Print["First batch launched. Current kernel count: ", Length[Kernels[]]];

LaunchKernels[50];
Print["Second batch launched. Current kernel count: ", Length[Kernels[]]];

LaunchKernels[50];
Print["Third batch launched. Current kernel count: ", Length[Kernels[]]];

LaunchKernels[50];
Print["Final batch launched. Current kernel count: ", Length[Kernels[]]];

batchSize = Ceiling[w3dim/Length[Kernels[]]];
(* 
w3func = ParallelTable[{

$HPLPath = "/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/HPL-2.0";
Get[ToFileName[{$HPLPath}, "HPL.m"]];
$PolyLogPath = SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/plt"];
<< PolyLogTools`;
SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop"];
<<"integrablew3.m";
FiberSymbol[integrablew3symlist[[idx]]/.ct->CiTi,{u3,v1,v2}];
},
{idx,w3dim}
]

Clear[G];
Save["w3func.m",w3func]; *)

(* parallel table fails*)
(* Process w3 in batches using ParallelEvaluate instead of ParallelTable *)
ParallelEvaluate[
  $HPLPath = "/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/HPL-2.0";
  Get[ToFileName[{$HPLPath}, "HPL.m"]];
  $PolyLogPath = SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/plt"];
  << PolyLogTools`;
  SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop"];
  << "integrablew3.m";
  
  (* Calculate indices based on kernel ID *)
  startIdx = ($KernelID - 1) * batchSize + 1;
  endIdx = Min[$KernelID * batchSize, w3dim];
  
  (* Process assigned indices *)
  For[idx = startIdx, idx <= endIdx, idx++,
    result = FiberSymbol[integrablew3symlist[[idx]]/.ct->CiTi, {u3,v1,v2}];
    (* Save individual result to file *)
    Clear[G];
    Save["w3fiber/w3func_" <> ToString[idx] <> ".m", result];
  ];
];


(* Initialize the w3func array *)
w3func = Table[Null, {w3dim}];

(* Import each file and build the complete array *)
For[idx = 1, idx <= w3dim, idx++,
  filename = "w3fiber/w3func_" <> ToString[idx] <> ".m";
  If[FileExistsQ[filename],
    Import[filename];
    w3func[[idx]] = result;
    ,
    Print["Warning: Missing file for index ", idx];
  ];
];

(* Save the complete array *)
Clear[G];
Save["w3func.m", w3func];
