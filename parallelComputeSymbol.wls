(* Compute the symbol of R43candidate.m in parallel*)
(* After some test it looks like computing symbols of certain weight-6 G functions are substantially slower than others *)
(* So let's do the job using a parallel process pool, through ParallelSubmit *)

(* Disable automatic kernel recovery *)
SetSystemOptions["ParallelOptions" -> {"AutomaticKernelRelaunch" -> False}];
(* Add additional kernel management settings *)
SetSystemOptions["ParallelOptions" -> {
  "AutomaticKernelRelaunch" -> False,
  "RecoveryMode" -> None
}];
batchsize = 512; 
oversubscriberatio = 0.8;
CkptEvery = 2048; (*Writing 100MB file to disk took around 10s*)

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


ParallelEvaluate[
    (* R43func = R43func//Expand; *)
    R43func[[0]] = List;
    (* R43func = R43func//RandomSample; *)
]
Print["expanded R43 ", DateString[]];

(* Get the length of R43func from a parallel kernel *)
R43funcLength = ParallelEvaluate[Length[R43func]][[1]];
Print["R43func has ", R43funcLength, " terms"];

(* compute by batch *)

currentidx = 1;
sumsym = 0;
R43x = <<"R43x.m";
diff = R43x;
Print["Loaded R43x ", DateString[]];


(* Load checkpoint if exists - find the latest one *)
checkpointFiles = FileNames["*.m", "tmp_sumsym_ckpt"];
If[Length[checkpointFiles] > 0,
  (* Extract the indices from filenames and find the latest checkpoint *)
  checkpointIndices = ToExpression[StringReplace[FileBaseName[#], "ckpt_" -> ""] & /@ checkpointFiles];
  latestIdx = Max[checkpointIndices];
  latestCheckpoint = "tmp_sumsym_ckpt/ckpt_" <> ToString[latestIdx] <> ".m";
  
  Print["Loading checkpoint from ", latestCheckpoint];
  ckptData = Get[latestCheckpoint];
  currentidx = ckptData["currentidx"];
  sumsym = ckptData["sumsym"];
  diff = ckptData["diff"];
  
  Print["Resuming from index ", currentidx, " with loaded checkpoint data"];
];


(* Some of the symbol are super hard to compute, record them as lookup tables *)
If[!DirectoryQ["tmpsymmap"], CreateDirectory["tmpsymmap"]];


While[ currentidx<=(R43funcLength), {
symlist = Table[
    ParallelSubmit[{idx},{
        (* timeelapsed = (sym = SymbolMap[R43func[[idx]]];//AbsoluteTiming);
        If[timeelapsed[[1]] > 5,{
            Print["SymbolMap for term ",idx," took ",timeelapsed,"s"];
            replrule = {R43func[[idx]] -> sym};
            fname = "tmpsymmap/"<>ToString[idx]<>".m";
            Export[fname, replrule, "Text"];
        }]; *)
        fname = "tmpsymmap/"<>ToString[idx]<>".m";
        
        symtime = (
        (* Check if the file exists, if so, load the symbol from file *)
        If[FileExistsQ[fname],
            (* Load the saved symbol from file *)
            (* Print["Loading saved symbol for term ", idx, " from ", fname]; *)
            replrule = Import[fname, "Text"] // ToExpression;
            sym = replrule[[ 2]];
        ,
            (* Otherwise compute it and possibly save *)
            timeelapsed = (sym = SymbolMap[R43func[[idx]]];//AbsoluteTiming);
            (* timeelapsed = (sym = ComputeSymbol[R43func[[idx]]];//AbsoluteTiming); *)
            (* SymbolMap mostly works. If SymbolMap gets slow, try ComputeSymbol offline *)
            If[timeelapsed[[1]] > 2,{
                Print["Computing symbols for term ",idx," took ",timeelapsed,"s"];
                replrule = {R43func[[idx]] -> sym};
                Export[fname, replrule, "Text"];
            }];
        ];//AbsoluteTiming
        );
        If[symtime[[1]]>10, Print["Reading/Computing idx=",idx," took ",symtime[[1]],"s"]];

        op1time = (sym = sym/.CiTi->ct/.ct[a1_,a2_,a3_,a4_,a5_,a6_]:>ct[ctt[a1],ctt[a2],ctt[a3],ctt[a4],ctt[a5],ctt[a6]];//AbsoluteTiming);
        If[op1time[[1]]>5, Print["op1 at idx=",idx," took ",op1time[[1]],"s"]];
        op2time = (sym = sym/.reversemap;//AbsoluteTiming);
        If[op2time[[1]]>5, Print["op2 at idx=",idx," took ",op2time[[1]],"s"]];
        (*** Warning, here we ignored all spurious letters, this would substantially save memory. Can check that spurious letters are indeed canceled in the future if we have time ***)
        op3time = (sym = sym /. ct[args__] /; !FreeQ[{args}, ctt[_]] -> 0;//AbsoluteTiming);
        If[op3time[[1]]>5, Print["op3 at idx=",idx," took ",op3time[[1]],"s"]];
        op4time = (sym = Expand[sym];//AbsoluteTiming);
        If[op4time[[1]]>5, Print["op4 at idx=",idx," took ",op4time[[1]],"s"]];
        Print[idx, DateString[]];
        sym
    }]
    ,{idx,currentidx,Min[currentidx+batchsize-1,R43funcLength]}
]//WaitAll;

Print["computed ", DateString[]];

symlist = symlist//Flatten;

nullResults = Position[symlist, Null] ;
If[Length[nullResults] > 0,
    Print["Warning: ", Length[nullResults], " null results found at positions: ", 
          Short[nullResults]];
];


sym = Sum[item,{item,symlist}]//Expand;

Print["summed ", DateString[]];

diff = diff - sym;

Print["diffed ", DateString[]];

(* 
Save["tmp.m",sym];
Print["saved tmp ", DateString[]]; *)

sumsym = sumsym + sym;
(* sumsym>>"tmpsumsym.m"; *)
currentidx = currentidx + batchsize;

Print["Progress "<>ToString[currentidx]<>"/"<>ToString[R43funcLength], DateString[]];

(* Save checkpoint *)
checkpointData = <|
  "currentidx" -> currentidx,
  "sumsym" -> sumsym,
  "diff" -> diff
|>;

If[Mod[currentidx,CkptEvery] == 1,{
checkpointFile = "tmp_sumsym_ckpt/ckpt_" <> ToString[currentidx] <> ".m";
If[!DirectoryQ["tmp_sumsym_ckpt"], CreateDirectory["tmp_sumsym_ckpt"]];
Put[checkpointData, checkpointFile];
Print["Saved checkpoint to ", checkpointFile, DateString[]];
}]

}];

test = sumsym - R43x;
(* Print[test] *)
Save["tmptest.m",test];
