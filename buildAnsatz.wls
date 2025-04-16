(* float z5, z4*log, z3*weight2, z2*weight3 functions to all the 7 independant coproducts, extracted from Delta51 of the candidate *)
(* then re-do the integration to get the Ansatz of R43rat*)

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
collectTerms$returnList[terms_List] := 
  Module[{gPatterns = {}, prefactors = {}, components, gPattern, 
    prefactor, pos},(*Process each term*)
   Do[components = extractComponents[term];
    gPattern = components[[1]];
    prefactor = components[[2]];
    (*Add to the appropriate pattern in our lists*)
    pos = Position[gPatterns, gPattern, 1, 1];
    If[pos =!= {}, 
     prefactors[[pos[[1, 1]]]] += prefactor, 
     AppendTo[gPatterns, gPattern];
     AppendTo[prefactors, prefactor]], {term, terms}];
   (*Return the collected terms as two lists*)
   {gPatterns, prefactors}];
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
   (*Return the result and statistics*){"result" -> result, 
    "numberOfDistinctPatterns" -> Length[collected], 
    "numberOfNonZeroTerms" -> Length[nonZeroTerms]}];



dt51 = <<"Delta51candidate.m"; 
Print["reading done",DateString[]];

tmp = dt51/.CT[expr_,gf_]:>CT[expr,gf//ComputeSymbol]; 
Print["processing done",DateString[]];
(* check all symbols appearing at second entry*)
secondArgs = Cases[tmp, CT[_, secondArg_] :> secondArg, Infinity];  
Print[lastentries = secondArgs//Union   ];

<<"xletts.m" ;
Print["Extracting coproducts",DateString[]];
Table[Co[x[idx]] = tmp/.CT[a_,b_]/;b==CiTi[x[idx]/.xletts]:>a/.CT[a_,b_]/;b==CiTi[-x[idx]/.xletts]:>a/._CT:>0;//AbsoluteTiming//Print, {idx,20}] ;
Table[x[idx] -> (Co[x[idx]]//Length),{idx,20}]//Print;
Print["Checking relations",DateString[]]
Print[Co[x[1]] + Co[x[3]] + Co[x[10]] + Co[x[11]] + Co[x[13]] + Co[x[15]]//Expand];
Print[Co[x[4]] + Co[x[7]] + Co[x[10]] + Co[x[13]] + Co[x[15]] //Expand];
Print[Co[x[5]] + Co[x[8]] + Co[x[11]] + Co[x[15]]//Expand];



(* Next, float some zeta numbers to the Co[] and re-integrate the full function*)
<<"w3func.m";
Print["Read w3func.m ",DateString[]];
w1funcs = Table[FiberSymbol[CiTi[item],{u3,v1,v2}],{item,threeloopletts}];
(* choose 7 independant basis and float constants *)
basis = {x[1], x[4], x[5], x[8], x[10], x[13],x[15]};
Table[{
    Co[item] = ( Co[item] + c[item,"z5"]*z5 + c[item,"z4u1"]*G[0,u1]*z4 
        + Sum[c[item,"z4w1",idx]*w1funcs[[idx]]*z4//Expand,{idx,w1funcs//Length}] 
        + c[item,"z3u1u1"]*G[0,0,u1]*z3 
        + Sum[c[item,"z3u1w1",idx]*w1funcs[[idx]]*G[0,1]*z3//Expand,{idx,w1funcs//Length}] 
        + Sum[c[item,"z3w2",idx]*w2funcs[[idx]]*z3//Expand,{idx,w2funcs//Length}] 
        + c[item,"z2u1u1u1"]*G[0,0,0,u1]*z2 
        + Sum[c[item,"z2u1u1w1",idx]*w1funcs[[idx]]*G[0,0,1]*z2//Expand,{idx,w1funcs//Length}] 
        + Sum[c[item,"z2u1w2",idx]*w2funcs[[idx]]*G[0,u1]*z2//Expand,{idx,w2funcs//Length}]
        + Sum[c[item,"z2w3",idx]*w3func[[idx]]*z2//Expand,{idx,w3func//Length}]
    ); //AbsoluteTiming//Print;
    Cases[Co[item]//Variables,_c]//Length//AbsoluteTiming//Print;
},{item,basis}];


Co[x[11]] = -(Co[x[5]] + Co[x[8]] + Co[x[15]])//Expand; //AbsoluteTiming//Print;
Co[x[7]] = -(Co[x[4]] + Co[x[10]] + Co[x[13]] + Co[x[15]])//Expand; //AbsoluteTiming//Print;
Co[x[3]] = -(Co[x[1]] + Co[x[10]] + Co[x[11]] + Co[x[13]] + Co[x[15]])//Expand; //AbsoluteTiming//Print;

Print["Length of the coproduct ansatz:"];
Table[x[idx] -> (Co[x[idx]]//Length),{idx,20}]//Print;


(* Then do the integration, refer to R43rat_finite_last_integr.wls *)

<< "xletts.m";
Table[{
   DlogxDvar[x[idx], myvar] = D[Log[x[idx]] /. xletts, myvar];
   }, {idx, xletts // Length}, {myvar, {v1, v2, u3, u1}}];

(*integrate term by term*)
Table[
 {
  (* each Co[x[]] are of 100k~1M terms, but only ~10k distinct G functions, so let's first collectTerms[] *)
  If[Co[x[idx]] === 0, {
  ktmp[idx] = {};
  vtmp[idx] = {};
  kintegratedtmp[idx] = {};
  }
  ,{
  Print["Integrating Co[x[idx]] for idx=",idx];
  tmplist = Co[x[idx]];
  tmplist[[0]] = List;
  dic =  collectTerms[tmplist];//AbsoluteTiming//Print;
  dic//Length//Print;
  ktmp[idx] = Keys[dic];
  vtmp[idx] = Values[dic];
  kintegratedtmp[idx] = Table[GIntegrate[Times[DlogxDvar[x[idx], u3], Sequence@@item ],u3],{item,ktmp[idx]} ];//AbsoluteTiming//Print;
  Position[kintegratedtmp[idx],Plus,1]//AbsoluteTiming//Print;
  (* tmpintegrated[idx] = 
       GIntegrate[
        Co[x[idx]]*DlogxDvar[x[idx], u3], 
        u3]; // AbsoluteTiming // Print; *)
  }];
  },
 {idx, 22}];

R43ansatz = Sum[Sum[vtmp[idx][[idx2]] * kintegratedtmp[idx][[idx2]] ,{idx2,kintegratedtmp[idx]//Length}], {idx, 22}];
R43ansatz>>"R43ansatz.m";

(* next, simplify the ansatz a bit, by collectTerms *)
(* note that the size of the ansatz is huge, but it doesn't contain too many G functions (approximately same as R43candidate). The size comes from big sums of prefactors of c[] constants. we can iterate over kintegratedtmp and vtmp, record the bug sums, replace them as placeholders, then collectTerms, then recover the place holder and expand the prefactors. Hopefully a lot of them will cancel. Then again record the big c[] sums in final expression. put placeholders. check v1, v2 derivatives with placeholders implicit. *)


R43ansatzList = R43ansatz;
R43ansatzList[[0]] = List;
dic = collectTerms[R43ansatzList]; //AbsoluteTiming//Print;
