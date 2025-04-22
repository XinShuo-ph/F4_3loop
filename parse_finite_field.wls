(* parse the integrability equations for finite field solver *)


SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop"];

Print["Launch kernels ", DateString[]];
targetnum = 256;
LaunchKernels[targetnum];
While[Length[Kernels[]] < targetnum,
  Print["Only launched " <> ToString[Length[Kernels[]]] <> " kernels, trying again..."];
  LaunchKernels[targetnum - Length[Kernels[]]];
]
Print["Launched kernels ", DateString[]];

<< "integrablew3.m";  (* Load the weight-3 results from your previous calculation in 3loopintegrability.wls, to get the dimensions *)
threeloopletts = {1 - u3, u3, 1 + u3, 1 - v1, 1 - u3 - v1, v1, u3 + v1, 1 - v2, 
 1 + u3 - v2, v2, -u3 + v2, -v1 + v2, -u3 - v1 + v2, 
 u3 + v1 - v1 v2, -u3 + v2 - v1 v2, -u3 + u3 v1 + v2 - v1 v2 - 
  u3 v1 v2, 
 u3 v1 + v1^2 + u3 v2 - u3 v1 v2 - v1^2 v2, -u3 + v2 - 2 v1 v2 + 
  u3 v1 v2 + v1^2 v2, -u3 v1 - u3 v2 + u3 v1 v2 + v2^2 - v1 v2^2};

w2dim = integrablew2symllist//Length;
w3dim = integrablew3symllist//Length;
lettdim = threeloopletts//Length; (*19*)

(* print the dims here with DateString[] *)
Print["Dimensions as of ", DateString[]];
Print["w2dim = ", w2dim, ", w3dim = ", w3dim, ", lettdim = ", lettdim];

w3vars = Table[cc[i,j],{i,w2dim},{j,lettdim}]//Flatten;
w4vars = Table[ccc[i,j],{i,w3dim},{j,lettdim}]//Flatten;

w3vars>>"tmp_integrability_w3_vars.m";
w4vars>>"tmp_integrability_w4_vars.m";

w3renamed =  w3vars /. cc[i_, j_] :> 
   ToExpression["cc" <> ToString[i] <> "t" <> ToString[j]];
w3renaming = Table[w3vars[[i]] -> w3renamed[[i]], {i, w3renamed // Length}];

w4renamed =  w4vars /. ccc[i_, j_] :> 
   ToExpression["ccc" <> ToString[i] <> "t" <> ToString[j]];
w4renaming = Table[w4vars[[i]] -> w4renamed[[i]], {i, w4renamed // Length}];


w3eqs = <<"tmp_integrability_w3_eqs.m";
(*print num*)
Print["Number of w3 equations: ", Length[w3eqs]];

(* w3eqsrenamed = Table[item/.w3renaming,{item,w3eqs}];//AbsoluteTiming//Print; *)
w3eqsrenamed = ParallelTable[item/.w3renaming,{item,w3eqs}];//AbsoluteTiming//Print;
(*print *)
Print["First few renamed w3 equations:"];
Print[Take[w3eqsrenamed, Min[3, Length[w3eqsrenamed]]]];

w3renamed >> "goff/parse-equations-master/integrability_w3_vars.txt";
w3eqsrenamed >> "goff/parse-equations-master/integrability_w3_eqs.txt";

(* Now continue with w4 equations in similar fashion *)
Print["Reading w4eqs"]
w4eqs = <<"tmp_integrability_w4_eqs.m";//AbsoluteTiming//Print;
Print["Number of w4 equations: ", Length[w4eqs]];

(* Process w4 equations in batches of 1000 with timing reports *)
batchSize = 1000;
numBatches = Ceiling[Length[w4eqs]/batchSize];
w4eqsrenamed = {};

Print["Processing w4 equations in ", numBatches, " batches of size ", batchSize];
For[i = 1, i <= numBatches, i++,
  startIdx = (i-1)*batchSize + 1;
  endIdx = Min[i*batchSize, Length[w4eqs]];
  Print["Processing batch ", i, "/", numBatches, " (equations ", startIdx, " to ", endIdx, ")"];
  
  batchEqs = w4eqs[[startIdx ;; endIdx]];
  batchStartTime = AbsoluteTime[];
  batchRenamed = ParallelTable[item/.w4renaming, {item, batchEqs}];
  batchEndTime = AbsoluteTime[];
  
  AppendTo[w4eqsrenamed, batchRenamed];
  
  Print["  Batch ", i, " completed in ", N[batchEndTime - batchStartTime, 3], " seconds"];
  Print["  Rate: ", N[Length[batchEqs]/(batchEndTime - batchStartTime), 3], " equations/second"];
];

(* Flatten the batched results *)
w4eqsrenamed = Flatten[w4eqsrenamed, 1];
Print["Total w4 equations processed: ", Length[w4eqsrenamed]];

Print["First few renamed w4 equations:"];
Print[Take[w4eqsrenamed, Min[3, Length[w4eqsrenamed]]]];

(* Write the renamed w4 variables and equations to files *)
w4renamed >> "goff/parse-equations-master/integrability_w4_vars.txt";
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