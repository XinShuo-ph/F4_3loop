(* Re-do the integration from 2idx coproducts to 1idx coproducts *)


$HPLPath = "/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/HPL-2.0";
Get[ToFileName[{$HPLPath}, "HPL.m"]];
$PolyLogPath = SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/plt"];
<< PolyLogTools`;
SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop"];
(*Process large sum of terms with G-functions and rational prefactors*)
(*Define a function to extract G-functions and prefactors from a term*)
extractComponents[term_] := 
  Module[{gFuncs, prefactor}, 
   If[Head[term] === Times,(*Split the term into G-
    functions and prefactors*)gFuncs = Cases[term, _G, Infinity];
    prefactor = term/Times @@ gFuncs;
    {Sort[gFuncs], prefactor},(*Handle case where term is just a G-
    function*)
    If[Head[term] === G, {Sort[{term}], 
      1},(*Handle case where term is just a prefactor*){{}, term}]]];

(*Function to collect terms with the same G-function pattern*)
collectTerms[terms_List] := 
  Module[{patterns = <||>, components, gPattern, 
    prefactor},(*Process each term*)
   Do[components = extractComponents[term];
    gPattern = components[[1]];
    prefactor = components[[2]];
    (*Add to the appropriate pattern in our dictionary*)
    If[KeyExistsQ[patterns, gPattern], 
     patterns[gPattern] += prefactor, 
     patterns[gPattern] = prefactor], {term, terms}];
   (*Return the collected terms*)patterns];

(*Main function to process and simplify the list of terms*)
simplifySum[terms_List] := 
  Module[{collected, result = 0, nonZeroTerms = {}, 
    prefactor},(*Collect terms with the same G-function pattern*)
   collected = collectTerms[terms];
   (*Form the simplified sum-
   using correct syntax for iterating through associations*)
   KeyValueMap[
    Function[{key, val},(*Only keep terms with non-
     zero coefficients after simplification*)prefactor = Simplify[val];
     If[prefactor =!= 0, term = Times[prefactor, Sequence @@ key];
      AppendTo[nonZeroTerms, term];
      result += term]], collected];
   (*Return the result and statistics*){"result" -> Simplify[result], 
    "numberOfDistinctPatterns" -> Length[collected], 
    "numberOfNonZeroTerms" -> Length[nonZeroTerms]}];

<< "R43finitepartCoFibered_2idx.m";
<< "xletts.m";
Table[{
   DlogxDvar[x[idx], myvar] = D[Log[x[idx]] /. xletts, myvar];
   }, {idx, xletts // Length}, {myvar, {v1, v2, u3, u1}}];
Print["Read inputs",DateString[]];

Table[R43finitepartCoFibered[x[idx], x[idx2]] = R43finitepartCoFibered[x[idx], x[idx2]]/.myG->G,{idx,22},{idx2,22}];
Print["Processed inputs",DateString[]];


Table[{
  (R43finitepartCoFibered[idx] = 
     Sum[GIntegrate[
       R43finitepartCoFibered[x[idx], x[idx2]]*DlogxDvar[x[idx2], u3]/.myG->G,
        u3], {idx2, xletts // Length}]; )// AbsoluteTiming//Print
  }, {idx, 22}];
Print["First trial integration done ", DateString[]];
Table[{
  mytmp = R43finitepartCoFibered[idx];
  If[mytmp == 0, 0, 0, {
    mytmp[[0]] = List;
      tmptable = Table[{
         
         factored = (Numerator[term] // Factor)/(Denominator[term] // 
             Factor);
         If[Denominator[factored] != 1, factored = Apart[factored]];
         factored
         }, {term, mytmp}]; // AbsoluteTiming // Print;
    R43finitepartCoFibered[idx] = 
     Sum[term, {term, tmptable // Flatten}];
    }];
  }, {idx, 22}];
Print["First trial integration simplified ", DateString[]];



(*simplify the sum and check v1,v2 derivatives in the corrected way*)
(*  v2 deriv *)
Table[{ (tmpderiv[idx] = 
   Sum[R43finitepartCoFibered[x[idx], x[idx2]]*
      DlogxDvar[x[idx2], v2], {idx2, xletts // Length}] - 
    DG[R43finitepartCoFibered[idx] // Expand, v2]//Expand; )// AbsoluteTiming//Print;
    (* simplify the big sum of derivatives*)
    If[tmpderiv[idx] == 0, 
    {
      (*if true do nothing*)
    }
    ,{
      terms = tmpderiv[idx];
      terms[[0]] = List;
      (sol = simplifySum[terms];)// AbsoluteTiming//Print;
      Print[sol[[2]]];
      Print[sol[[3]]];
      tmpderiv[idx] = "result"/.sol[[1]];
    },{
      terms = tmpderiv[idx];
      terms[[0]] = List;
      (sol = simplifySum[terms];)// AbsoluteTiming//Print;
      Print[sol[[2]]];
      Print[sol[[3]]];
      tmpderiv[idx] = "result"/.sol[[1]];
    }];
    (* integrate *)
    R43finitepartCoFibered[idx] = R43finitepartCoFibered[idx] + GIntegrate[tmpderiv[idx],v2];
    },{idx,22}];
(*  v2 derivative  *)
Table[{ (tmpderiv[idx] = 
   Sum[R43finitepartCoFibered[x[idx], x[idx2]]*
      DlogxDvar[x[idx2], v1], {idx2, xletts // Length}] - 
    DG[R43finitepartCoFibered[idx] // Expand, v1]//Expand; )// AbsoluteTiming//Print;
    (* simplify the big sum of derivatives*)
    If[tmpderiv[idx] == 0, 
    {
      (*if true do nothing*)
    }
    ,{
      terms = tmpderiv[idx];
      terms[[0]] = List;
      (sol = simplifySum[terms];)// AbsoluteTiming//Print;
      Print[sol[[2]]];
      Print[sol[[3]]];
      tmpderiv[idx] = "result"/.sol[[1]];
    },{
      terms = tmpderiv[idx];
      terms[[0]] = List;
      (sol = simplifySum[terms];)// AbsoluteTiming//Print;
      Print[sol[[2]]];
      Print[sol[[3]]];
      tmpderiv[idx] = "result"/.sol[[1]];
    }];
    (* integrate *)
    R43finitepartCoFibered[idx] = R43finitepartCoFibered[idx] + GIntegrate[tmpderiv[idx],v1];
    },{idx,22}];

(* Save the corrected results *)
Table[R43finitepartCoFibered$1idx[x[idx]] = 
   R43finitepartCoFibered[idx], {idx, 22}];
Clear[G];
Save["R43finitepartCoFibered_1idx.m", R43finitepartCoFibered$1idx]