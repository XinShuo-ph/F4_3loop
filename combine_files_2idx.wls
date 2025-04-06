
SetDirectory["/oak/stanford/orgs/kipac/users/xinshuo/F4_3loop"];
Table[
    {
        fname = "2idxfiles/R43finitepartCoFibered_2idx_"<> ToString[idx] <> "_" <> ToString[idx2] <> ".m";
        Import[fname];
        R43finitepartCoFibered[x[idx], x[idx2]] = mytmp3/.G->myG;
        Clear[mytmp3];
    },
    {idx,22}, {idx2,22}
]
Save["R43finitepartCoFibered_2idx.m", R43finitepartCoFibered];