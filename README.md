# F4_3loop

Repository for F4 3-loop calculations on Sherlock cluster.

## Dependancy
To use Mathematica on Sherlock, `module load mathematica`. Mathematica may fill the home dir with GBs of tmp files, check `du -h -d 2 ~/.Mathematica` when things fail. To change the Mathematica user base dir, add `export MATHEMATICA_USERBASE="/oak/stanford/orgs/kipac/users/xinshuo/Mathematica_cache"` to `~/.bashrc`.

### Ginsh
This is only needed if we want numerical evaluations in PolyLogTools.

#### *Install cln*
On Sherlock cluster, I installed cln with
```bash
cd cln-1.1.6
./configure --prefix=$HOME/cln_install
make
make check
make install
```
If everything works, after a long output, in the `make check` step we should see
```
PASS: exam
PASS: tests
============================================================================
Testsuite summary for cln 1.3.6
============================================================================
# TOTAL: 2
# PASS:  2
# SKIP:  0
# XFAIL: 0
# FAIL:  0
# XPASS: 0
# ERROR: 0
============================================================================
```

Full documentation: https://www.ginac.de/CLN/cln.html

#### *Install GiNaC*

```bash
cd ginac-1.8.6
module load readline  # see https://www.sherlock.stanford.edu/docs/software/list/?h=readline#system
export PKG_CONFIG_PATH=$HOME/cln_install/lib/pkgconfig
./configure --prefix=$HOME/local --exec-prefix=$HOME/local
make
make install
```

add
```bash
module load readline
```
to `~/.bashrc`

### finite field solver
`goff` includes a finite field solver from Andy Yu-Ting Liu

## Integration of one candidate
Given all the triple coproducts in `R43finitepartCoFibered.m` (got by processing symbols on a little laptop, see the script `R43rat_finite.nb`), to integrate all the doublle coproducts, run `math -script parallelIntegrate.wls`. This uses 170 CPU cores and should finish in less than 1 min. This saves all double coproducts in `2idxfiles` folder. Then `math -script combine_files_2idx.wls` combines them into `R43finitepartCoFibered_2idx.m`. Then the integration from double coproducts to a candidate function can be finished on a little laptop within several minutes (see the script `R43rat_finite_last_integr.nb`). This is one function that match the symbol of `R43x.m`. We need to add all possible beyond-symbol functions (functions containing zeta values) to the ansatz.

### weight-3 function space
There are 19 nontrivial letters appearing in the three-loop R43 symbol. We solved the space of weight-3 functions using `3loopintegrability.wls` and `parallelfiber_w3.wls`. I gave one basis of weight-3 functions in G-function representations in `w3func.m`

