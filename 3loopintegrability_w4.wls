(* 
    Build up the general functions using the rational letters appearing at 3loops
    Extended to weight-4 functions
 *)

SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop"];
If[!DirectoryQ["w4integrability"], CreateDirectory["w4integrability"]];


Print["Launch kernels ", DateString[]];
targetnum = 128;
LaunchKernels[targetnum];
While[Length[Kernels[]] < targetnum,
  Print["Only launched " <> ToString[Length[Kernels[]]] <> " kernels, trying again..."];
  LaunchKernels[targetnum - Length[Kernels[]]];
]
Print["Launched kernels ", DateString[]];

ParallelEvaluate[ {
outputFileName = "integrablew4.m";

SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop"];


(* R43x = << "R43x.m"; *)
<< "xletts.m";
<< "integrablew3.m";  (* Load the weight-3 results from your previous calculation *)

(* threeloopletts = (R43x /. xletts // Variables) /. ct -> Sequence // Union;
threeloopletts = DeleteCases[threeloopletts, u1] // Sort; *)

threeloopletts = {1 - u3, u3, 1 + u3, 1 - v1, 1 - u3 - v1, v1, u3 + v1, 1 - v2, 
 1 + u3 - v2, v2, -u3 + v2, -v1 + v2, -u3 - v1 + v2, 
 u3 + v1 - v1 v2, -u3 + v2 - v1 v2, -u3 + u3 v1 + v2 - v1 v2 - 
  u3 v1 v2, 
 u3 v1 + v1^2 + u3 v2 - u3 v1 v2 - v1^2 v2, -u3 + v2 - 2 v1 v2 + 
  u3 v1 v2 + v1^2 v2, -u3 v1 - u3 v2 + u3 v1 v2 + v2^2 - v1 v2^2};

uvvar = {u3, v1, v2};
(* derivatives *)
Table[DloglettDvar[i, myvar] = D[Log[i], myvar] // Factor, {myvar, 
  uvvar}, {i, threeloopletts}];
(* handy replacement rules *)
l3repl = 
 Table[l[l3idx] -> threeloopletts[[l3idx]], {l3idx, 
   threeloopletts // Length}];

(* Load the adjacency relations from integrability*)
adjrel = << "integrability_adjrel.m";


(* Extract the weight-3 integrable functions *)
w3functionsCount = Length[integrablew3symllist];
Print["Found ", w3functionsCount, " weight-3 functions"];

(* Build weight-4 ansatz by adding another letter to each weight-3 function *)
genexprlw4 = 
 Sum[ccc[idx, 
    idx2]*(integrablew3symllist[[idx]] /. 
     ct[seq__] :> ct[seq, l[idx2]]), {idx, 
   Range[w3functionsCount]}, {idx2, 
   Range[threeloopletts // Length]}];

(* Define the coproduct for weight-4 functions *)
Coproductw4[myexpr_, idx1_, 
  idx2_] := ((myexpr /. ct[seq__, l[idx1], l[idx2]] :> ct[seq]) /. 
   ct[seq__] /; Length[{seq}] == 4 :> 0);

(* Simplify adjacency relations for weight-4 *)
Print["Collecting equations for weight-4 integrability, ", DateString[]];

}];

(* the longest eqs, like for relidx=38, take ~10 mins to finish*)
collectedeqs = ParallelEvaluate[
   {
      relidx = $KernelID;
      Print["Processing relation ", relidx, " of ", Length[adjrel], DateString[]];
      tmp[relidx] = (adjrel[[relidx]][[2]] - adjrel[[relidx]][[1]]) /. {c[i_, j_] :> Coproductw4[genexprlw4, i, j]};//AbsoluteTiming//Print;
      ctvars[relidx] = Cases[tmp[relidx] // Variables, _ct];//AbsoluteTiming//Print;
      eqs = Table[Coefficient[tmp[relidx], var] == 0, {var, ctvars[relidx]}];//AbsoluteTiming//Print;
      Save["w4integrability/"<>ToString[relidx]<>".m",eqs ];
      eqs
   }
];
collectedeqs = collectedeqs//Flatten;//AbsoluteTiming//Print;

(* Save the collected equations for later solving *)
collectedeqs >> "tmp_integrability_w4_eqs.m";
Print["Weight-4 integrability equations saved to tmp_integrability_w4_eqs.m, ", DateString[]];
