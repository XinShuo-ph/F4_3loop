(* 
    Build up the general functions using the rational letters appearing at 3loops
 *)


$HPLPath = "/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/HPL-2.0";
Get[ToFileName[{$HPLPath}, "HPL.m"]];
$PolyLogPath = SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop/plt"];
<< PolyLogTools`;
SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop"];
kernelidx = $KernelID + idxoffset;
<< "R43x.m";
<< "xletts.m";
(* << "ctdef.m"; *)

threeloopletts = (R43x /. xletts // Variables) /. ct -> Sequence // 
   Union;
threeloopletts = DeleteCases[threeloopletts, u1] // Sort;

uvvar = {u3, v1, v2};