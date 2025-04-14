(***** Amend the problematic term R43func[[8642]] ****)

wrongidx = 8642;

(* wrongidx = 12883; *)

batchsize = 512; 
oversubscriberatio = 0.8;


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

Print["Loaded PolyLogTools", DateString[]]
(**** This preamble seems to correctly load PolyLogTools in parallel ****)


(* load R43 to each kernel*)
ParallelEvaluate[
    <<"R43candidate.m";
    <<"xletts.m";
    reversemap = Table[{ctt[item[[2]]]->item[[1]],
        ctt[-item[[2]]]->item[[1]]},{item,xletts}]//Reverse//Flatten ;
]
Print["Loaded R43 ", DateString[]]


ParallelEvaluate[
    (* R43func = R43func//Expand; *)
    R43func[[0]] = List;
    tmp = R43func[[wrongidx]]//Expand;
    (* R43func = R43func//RandomSample; *)
]
Print["expanded R43 ", DateString[]]




R43func8642Length = ParallelEvaluate[Length[tmp], 1];
R43funcwrongidx = ParallelEvaluate[R43func[[wrongidx]], 1];
Print["R43func8642 has ", R43func8642Length, " terms"];

If[!DirectoryQ["tmp_amend"], {
    CreateDirectory["tmp_amend"];
    Table[
        ParallelSubmit[{idx},{
            fname = "tmp_amend/"<>ToString[idx]<>".m";
            Export[fname, tmp[[idx]]//SymbolMap, "Text"];
        }]
        ,{idx,R43func8642Length}
    ]//WaitAll;
    Print["computed ", DateString[]];
}];


(*sum by batch*)
currentidx = 1;
total = 0;

While[currentidx<=R43func8642Length,{

symlist = Table[
    Import["tmp_amend/"<>ToString[idx]<>".m", "Text"] // ToExpression//Expand
    ,
    {idx,currentidx,Min[currentidx+batchsize-1,R43func8642Length]}
    ];

Print["collected ", DateString[]];

sym = Sum[item,{item,symlist}]//Expand;

Print["summed ", DateString[]];

total = total + sym;
currentidx = currentidx + batchsize;

Print["progress ",currentidx,"/",R43func8642Length,DateString[]]

}]

fname = "tmpsymmap/"<>ToString[wrongidx]<>".m";
replrule = {R43funcwrongidx -> total};
Export[fname, replrule, "Text"];