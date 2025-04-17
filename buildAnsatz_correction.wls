(* ansatz_deriv_check.wls - Script to check derivatives of the R43 ansatz *)
(* This script processes the output from buildAnsatz.wls and checks if the derivatives simplify to zero *)

(* Set up parallel processing *)
LaunchKernels[];
Print["Launched ", $KernelCount, " kernels for parallel processing"];

(* Helper functions *)
SimplifyDiffTerm[expr_, valuesList_] := Module[{
    result, 
    expandedExpr = expr /. vh[idx_] :> valuesList[[idx]]
  },
  (* First try Together to combine fractions *)
  result = Together[expandedExpr];
  
  (* If the result is a fraction, expand the numerator *)
  If[Head[result] === Times || Head[result] === Power,
    result = Together[expandedExpr, Modulus -> 0];
    If[Head[result] === Rational || MatchQ[result, _Times?(MemberQ[{_Rational, _Power}, Head[#]] &)],
      result = result /. (num_. / den_.) :> Expand[num]/den;
    ]
  ];
  
  (* Final simplification *)
  Simplify[result]
];

(* Process both v1 and v2 derivatives *)
For[varIdx = 1, varIdx <= 2, varIdx++,
  varName = "v" <> ToString[varIdx];
  Print["Processing ", varName, " derivative check"];
  
  (* Read the necessary data *)
  dir = "tmp_ansatz_deriv_" <> varName;
  Print["Reading data from ", dir];
  
  valuesList = Get[dir <> "/v.m"];
  diffKeys = Get[dir <> "/diffdick.m"];
  diffValues = Get[dir <> "/diffdicv.m"];
  
  Print["Loaded ", Length[valuesList], " value terms"];
  Print["Loaded ", Length[diffKeys], " difference keys"];
  Print["Loaded ", Length[diffValues], " difference values"];
  
  (* Process the differences in parallel *)
  Print["Starting parallel processing of ", Length[diffValues], " terms"];
  startTime = AbsoluteTime[];
  
  results = ParallelTable[
    Module[{simplifiedTerm, timeUsed},
      timeUsed = AbsoluteTiming[
        simplifiedTerm = SimplifyDiffTerm[diffValues[[i]], valuesList];
      ][[1]];
      {i, simplifiedTerm, timeUsed}
    ],
    {i, Length[diffValues]}
  ];
  
  (* Filter out zero results *)
  nonZeroResults = Select[results, #[[2]] =!= 0 &];
  
  (* Report results *)
  endTime = AbsoluteTime[];
  Print["Processing completed in ", endTime - startTime, " seconds"];
  Print["Found ", Length[nonZeroResults], " non-zero terms out of ", Length[diffValues]];
  
  (* Save detailed results *)
  If[Length[nonZeroResults] > 0,
    Print["Non-zero results found:"];
    
    (* Create a full report *)
    reportFile = "ansatz_" <> varName <> "_derivative_report.txt";
    strm = OpenWrite[reportFile];
    WriteString[strm, "# Ansatz Derivative Check for " <> varName <> "\n\n"];
    WriteString[strm, "Total terms checked: " <> ToString[Length[diffValues]] <> "\n"];
    WriteString[strm, "Non-zero terms found: " <> ToString[Length[nonZeroResults]] <> "\n\n"];
    
    WriteString[strm, "## Detailed Results\n\n"];
    Do[
      idx = nonZeroResults[[j, 1]];
      term = nonZeroResults[[j, 2]];
      time = nonZeroResults[[j, 3]];
      
      WriteString[strm, "### Term " <> ToString[idx] <> "\n"];
      WriteString[strm, "Processing time: " <> ToString[time] <> " seconds\n\n"];
      
      (* Write the G functions involved *)
      WriteString[strm, "G functions: " <> ToString[diffKeys[[idx]]] <> "\n\n"];
      
      (* Write the simplified non-zero result *)
      WriteString[strm, "Simplified result: " <> ToString[term] <> "\n\n"];
      WriteString[strm, "-------------------------------------------\n\n"];
    , {j, Length[nonZeroResults]}];
    
    Close[strm];
    
    (* Also save as Mathematica expressions for further analysis *)
    nonZeroTerms = Table[{
      diffKeys[[nonZeroResults[[j, 1]]]],
      nonZeroResults[[j, 2]]
    }, {j, Length[nonZeroResults]}];
    
    Export["ansatz_" <> varName <> "_nonzero_terms.m", nonZeroTerms];
    
    Print["Detailed report saved to ", reportFile];
    Print["Non-zero terms saved to ansatz_", varName, "_nonzero_terms.m"];
  ,
    Print["All terms simplified to zero for ", varName, " derivative check!"];
  ];
  
  Print["-----------------------------------------------------"];
];

(* Try a deeper simplification for any remaining non-zero terms *)
For[varIdx = 1, varIdx <= 2, varIdx++,
  varName = "v" <> ToString[varIdx];
  nonZeroFile = "ansatz_" <> varName <> "_nonzero_terms.m";
  
  If[FileExistsQ[nonZeroFile],
    Print["Performing deeper simplification on non-zero terms for ", varName];
    nonZeroTerms = Get[nonZeroFile];
    
    deeperResults = ParallelTable[
      Module[{gFuncs, term, simplified},
        gFuncs = nonZeroTerms[[i, 1]];
        term = nonZeroTerms[[i, 2]];
        
        (* Try more aggressive simplification techniques *)
        simplified = Simplify[term, TimeConstraint -> 30];
        If[simplified === 0, Return[{i, 0, "Simplify"}]];
        
        simplified = FullSimplify[term, TimeConstraint -> 30];
        If[simplified === 0, Return[{i, 0, "FullSimplify"}]];
        
        (* Return the original if no simplification worked *)
        {i, term, "None"}
      ],
      {i, Length[nonZeroTerms]}
    ];
    
    stillNonZero = Select[deeperResults, #[[2]] =!= 0 &];
    
    Print["After deeper simplification: ", Length[stillNonZero], " terms remain non-zero out of ", 
          Length[nonZeroTerms]];
    
    If[Length[stillNonZero] > 0,
      Export["ansatz_" <> varName <> "_final_nonzero.m", 
        Table[{nonZeroTerms[[stillNonZero[[j, 1]], 1]], stillNonZero[[j, 2]]}, 
             {j, Length[stillNonZero]}]];
      Print["Final non-zero terms saved to ansatz_", varName, "_final_nonzero.m"];
    ];
  ];
];

(* Clean up *)
CloseKernels[];
Print["Processing complete."];