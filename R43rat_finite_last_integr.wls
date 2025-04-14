(* Re-do the integration from 1idx coproducts to the full function *)


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




<< "R43finitepartCoFibered_1idx.m";
<< "xletts.m";
Table[{
   DlogxDvar[x[idx], myvar] = D[Log[x[idx]] /. xletts, myvar];
   }, {idx, xletts // Length}, {myvar, {v1, v2, u3, u1}}];

(*integrate term by term*)
Table[
 {
  tmp[idx] = 
       GIntegrate[
        R43finitepartCoFibered$1idx[x[idx]]*DlogxDvar[x[idx], u3], 
        u3]; // AbsoluteTiming // Print;
  },
 {idx, 22}];

R43finitepart = Sum[tmp[idx], {idx, 22}];
R43finitepartexpand = R43finitepart//Expand;

(* check the derivative*)
(* v1 *)
tmpderiv = 
   Sum[R43finitepartCoFibered$1idx[x[idx2]]*
      DlogxDvar[x[idx2], v2], {idx2, xletts // Length}] - 
    DG[R43finitepartexpand, v2]; // AbsoluteTiming//Print; (* this takes around 200s, didn't bother to parallelize it*)

expandedderiv = tmpderiv // Expand;
expandedderiv // Length//Print;
expandedderiv[[0]] = List;

(dic = simplifySum[expandedderiv]); // AbsoluteTiming//Print;
Print[dic] (* Should be 0? checked locally*)

If[ ("result"/.dic) == 0, {

}
,{
    R43finitepart =  R43finitepart + GIntegrate["results"/.dic, v2];
},{
    R43finitepart =  R43finitepart + GIntegrate["results"/.dic, v2];
}];

R43finitepartexpand = R43finitepart//Expand;
(* v1 *)
tmpderiv = 
   Sum[R43finitepartCoFibered$1idx[x[idx2]]*
      DlogxDvar[x[idx2], v1], {idx2, xletts // Length}] - 
    DG[R43finitepartexpand, v1]; // AbsoluteTiming//Print; (* this takes around 200s, didn't bother to parallelize it*)

expandedderiv = tmpderiv // Expand;
expandedderiv // Length//Print;
expandedderiv[[0]] = List;

(dic = simplifySum[expandedderiv]); // AbsoluteTiming//Print;
Print[dic] 

If[ ("result"/.dic) == 0, {

}
,{
    R43finitepart =  R43finitepart + GIntegrate["results"/.dic, v1];
},{
    R43finitepart =  R43finitepart + GIntegrate["results"/.dic, v1];
}];

Clear[G];
Save["R43finite.m", R43finitepart];