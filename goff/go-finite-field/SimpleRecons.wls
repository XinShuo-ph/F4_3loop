(* a simple rational reconstruction script*)
dim2 = 233;
dim3 = 2343;
SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/goff"];

p = 46337;
sol = << "go-finite-field/integrability_w3_sol.txt.m";
vars = << "parse-equations-master/integrability_w3_vars.txt";

sol = sol /. var[i_] :> vars[[i]];
sol = sol /. num_ /; Abs[num] > 100 :> Mod[num, p];

Print["Building reconstruction map ", DateString[]];
recon = {};
up = 20;  (* upper limit of denominators *)
numup = 200;  (* upper limit of numerators *)
For[myn = numup + 1, myn < p, myn = myn + 1, {
  If[Mod[myn, 10000] == 1, Print[myn]];
  For[den = -up, den <= up, den = den + 1, {
    If [den == 0, Continue[]];
    num = Mod[myn*den, p];
    If[num <= numup, recon = Append[recon, myn -> num/den]];
    }]
  }];//AbsoluteTiming//Print;
recon = recon // DeleteDuplicates;//AbsoluteTiming//Print;

Print["Built reconstruction map ", DateString[]];

sol = sol /. recon;//AbsoluteTiming//Print;


(* test on original eqs*)
origEqs = <<"parse-equations-master/integrability_w3_eqs_expand_parsed.txt";

origEqs=origEqs/.sol;//AbsoluteTiming//Print;
origEqs[[0]] = Plus;
Print[origEqs];

Print["Parsing back to original notation ", DateString[]];

first = Range[dim2];
second = Range[19];
rename = 
  Table[ToExpression["c" <> ToString[i] <> "t" <> ToString[j]] -> 
     c[i, j], {i, first}, {j, second}] // Flatten;
sol = sol /. rename;//AbsoluteTiming//Print;

sol>>"go-finite-field/integrability_w3_sol_recon.m";
