(* parse the integrability equations for finite field solver *)

SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop"];

Print["Launch kernels ", DateString[]];
targetnum = 256;
LaunchKernels[targetnum];
While[Length[Kernels[]] < targetnum,
  Print["Only launched " <> ToString[Length[Kernels[]]] <> " kernels, trying again..."];
  LaunchKernels[targetnum - Length[Kernels[]]];
]
numKernels = Length[Kernels[]];
Print["Launched ", numKernels, " kernels ", DateString[]];

(* Load common data and initialize variables on all kernels *)
ParallelEvaluate[
  SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop"];
  << "integrablew3.m";  
  threeloopletts = {1 - u3, u3, 1 + u3, 1 - v1, 1 - u3 - v1, v1, u3 + v1, 1 - v2, 
   1 + u3 - v2, v2, -u3 + v2, -v1 + v2, -u3 - v1 + v2, 
   u3 + v1 - v1 v2, -u3 + v2 - v1 v2, -u3 + u3 v1 + v2 - v1 v2 - 
    u3 v1 v2, 
   u3 v1 + v1^2 + u3 v2 - u3 v1 v2 - v1^2 v2, -u3 + v2 - 2 v1 v2 + 
    u3 v1 v2 + v1^2 v2, -u3 v1 - u3 v2 + u3 v1 v2 + v2^2 - v1 v2^2};
  
  w2dim = integrablew2symllist//Length;
  w3dim = integrablew3symllist//Length;
  lettdim = threeloopletts//Length; (*19*)
  
  w3vars = Table[cc[i,j],{i,w2dim},{j,lettdim}]//Flatten;
  w4vars = Table[ccc[i,j],{i,w3dim},{j,lettdim}]//Flatten;
  
  w3renamed = w3vars /. cc[i_, j_] :> ToExpression["cc" <> ToString[i] <> "t" <> ToString[j]];
  w3renaming = Table[w3vars[[i]] -> w3renamed[[i]], {i, w3renamed // Length}];
  
  w4renamed = w4vars /. ccc[i_, j_] :> ToExpression["ccc" <> ToString[i] <> "t" <> ToString[j]];
  w4renaming = Table[w4vars[[i]] -> w4renamed[[i]], {i, w4renamed // Length}];
];

Print["Dimensions as of ", DateString[]];
w2dim = ParallelEvaluate[w2dim][[1]];
w3dim = ParallelEvaluate[w3dim][[1]];
lettdim = ParallelEvaluate[lettdim][[1]];
Print["w2dim = ", w2dim, ", w3dim = ", w3dim, ", lettdim = ", lettdim];

w3vars = ParallelEvaluate[w3vars,1];
w4vars = ParallelEvaluate[w4vars,1];

w3vars>>"tmp_integrability_w3_vars.m";
w4vars>>"tmp_integrability_w4_vars.m";

w3renamed = ParallelEvaluate[w3renamed,1];
w4renamed = ParallelEvaluate[w4renamed,1];
w3renamed >> "goff/parse-equations-master/integrability_w3_vars.txt";
w4renamed >> "goff/parse-equations-master/integrability_w4_vars.txt";

(* Load equations *)
Print["Reading w3eqs ", DateString[]];
 ParallelEvaluate[
w3eqs = <<"tmp_integrability_w3_eqs.m";
 ];
Print["Number of w3 equations: ", ParallelEvaluate[Length[w3eqs],1]];
(*expand*)
ParallelEvaluate[
w3eqs = Table[item[[1]]//Expand,{item,w3eqs}];
];//AbsoluteTiming//Print;
ParallelEvaluate[
    w3eqs >> "goff/parse-equations-master/integrability_w3_eqs_expand.txt";
    , 1
];

Print["Reading w4eqs ", DateString[]];
 ParallelEvaluate[
w4eqs = <<"tmp_integrability_w4_eqs.m";
 ];
Print["Number of w4 equations: ", ParallelEvaluate[Length[w4eqs],1]];
(*expand*)
ParallelEvaluate[
w4eqs = Table[item[[1]]//Expand,{item,w4eqs}];
];//AbsoluteTiming//Print;

ParallelEvaluate[
    w4eqs >> "goff/parse-equations-master/integrability_w4_eqs_expand.txt";
    , 1
];



(* 

(* Sort equations by length for better load balancing *)
Print["Sorting w3 equations by length for load balancing..."];
 ParallelEvaluate[
w3eqsWithLen = Table[{Length[w3eqs[[i]]], i}, {i, 1, Length[w3eqs]}];
w3eqsWithLen = Sort[w3eqsWithLen, #1[[1]] > #2[[1]] &]; (* Sort by descending length *)
w3eqsSorted = w3eqs[[#[[2]]]] & /@ w3eqsWithLen;
 ];
Print["Sorting w3 equations complete"];

Print["Sorting w4 equations by length for load balancing..."];
 ParallelEvaluate[
w4eqsWithLen = Table[{Length[w4eqs[[i]]], i}, {i, 1, Length[w4eqs]}];
w4eqsWithLen = Sort[w4eqsWithLen, #1[[1]] > #2[[1]] &]; (* Sort by descending length *)
w4eqsSorted = w4eqs[[#[[2]]]] & /@ w4eqsWithLen;
 ];
Print["Sorting w4 equations complete"];



(* Process w3 equations with each kernel handling a portion *)
Print["Processing w3 equations in parallel ", DateString[]];
w3results = ParallelEvaluate[
  kernelID = $KernelID;
  numEquations = Length[w3eqsSorted];
  numKernelsTotal = 256;
  
  (* Get interleaved equations for this kernel - every numKernelsTotal starting at kernelID *)
  myIndices = Table[i, {i, kernelID, numEquations, numKernelsTotal}];
  myEquations = w3eqsSorted[[myIndices]];
  
  (* Process my equations *)
  myStartTime = AbsoluteTime[];
  w3eqsRenamedLocal = Table[eq /. w3renaming, {eq, myEquations}];
  myEndTime = AbsoluteTime[];
  
  Print["Kernel ", kernelID, " processed ", Length[myEquations], 
    " w3 equations (interleaved) in ", 
    N[myEndTime - myStartTime, 3], " seconds"];
    
  w3eqsRenamedLocal
];

(* Gather results from all kernels for w3 *)
w3eqsrenamed = Flatten[w3results, 1];
Print["Total w3 equations processed: ", Length[w3eqsrenamed]];

(* Process w4 equations with each kernel handling a portion *)
Print["Processing w4 equations in parallel ", DateString[]];
w4results = ParallelEvaluate[
  kernelID = $KernelID;
  numEquations = Length[w4eqsSorted];
  numKernelsTotal = 256;
  
  (* Get interleaved equations for this kernel - every numKernelsTotal starting at kernelID *)
  myIndices = Table[i, {i, kernelID, numEquations, numKernelsTotal}];
  myEquations = w4eqsSorted[[myIndices]];
  
  
  (* Process my equations *)
  myStartTime = AbsoluteTime[];
  w4eqsRenamedLocal = Table[eq /. w4renaming, {eq, myEquations}];
  myEndTime = AbsoluteTime[];
  
  Print["Kernel ", kernelID, " processed ", Length[myEquations], 
    " w4 equations (interleaved) in ", 
    N[myEndTime - myStartTime, 3], " seconds"];
    
  w4eqsRenamedLocal
];

(* Gather results from all kernels for w4 *)
w4eqsrenamed = Flatten[w4results, 1];
Print["Total w4 equations processed: ", Length[w4eqsrenamed]];

Print["First few renamed w3 equations:"];
Print[Take[w3eqsrenamed, Min[3, Length[w3eqsrenamed]]]];

Print["First few renamed w4 equations:"];
Print[Take[w4eqsrenamed, Min[3, Length[w4eqsrenamed]]]];

(* Write the renamed variables and equations to files *)
(* w3renamed >> "goff/parse-equations-master/integrability_w3_vars.txt"; *)
w3eqsrenamed >> "goff/parse-equations-master/integrability_w3_eqs.txt";
(* w4renamed >> "goff/parse-equations-master/integrability_w4_vars.txt"; *)
w4eqsrenamed >> "goff/parse-equations-master/integrability_w4_eqs.txt";

(* Print summary of the processing *)
Print["Processing complete at ", DateString[]];
Print["Files written to parse-equations-master directory:"];
Print["  integrability_w3_vars.txt: ", Length[w3renamed], " variables"];
Print["  integrability_w3_eqs.txt: ", Length[w3eqsrenamed], " equations"];
Print["  integrability_w4_vars.txt: ", Length[w4renamed], " variables"];
Print["  integrability_w4_eqs.txt: ", Length[w4eqsrenamed], " equations"];

(* Optional: You might want to check the system determinacy *)
Print["System determinacy check:"];
Print["  Weight 3: ", Length[w3renamed], " variables, ", Length[w3eqsrenamed], " equations"];
Print["  Weight 4: ", Length[w4renamed], " variables, ", Length[w4eqsrenamed], " equations"];
 *)
