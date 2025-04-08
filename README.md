# F4_3loop

Repository for F4 3-loop calculations on Sherlock cluster.

## Dependancy
To use Mathematica on Sherlock, `module load mathematica`. Mathematica may fill the home dir with GBs of tmp files, check `du -h -d 2 ~/.Mathematica` when things fail. To change the Mathematica user base dir, add `export MATHEMATICA_USERBASE="/oak/stanford/orgs/kipac/users/xinshuo/Mathematica_cache"` to `~/.bashrc`.

### Ginsh
This is only needed if we want numerical evaluations in PolyLogTools.


## Integration of one candidate
Given all the triple coproducts in `R43finitepartCoFibered.m` (got by processing symbols on a little laptop, see the script `R43rat_finite.nb`), to integrate all the doublle coproducts, run `math -script parallelIntegrate.wls`. This uses 170 CPU cores and should finish in less than 1 min. This saves all double coproducts in `2idxfiles` folder. Then `math -script combine_files_2idx.wls` combines them into `R43finitepartCoFibered_2idx.m`. Then the integration from double coproducts to a candidate function can be finished on a little laptop within several minutes (see the script `R43rat_finite_last_integr.nb`).