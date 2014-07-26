# News

## Version Updates

### 0.3.1

* Added `chains` field to `Chains` type for tracking purposes.
* Fixed `mcmc` to accommodate restarting of chains subsetted by parameters and/or chains.
* Fixed plot legends to properly reference the chains being displayed.
* Added support for sampling of positive-definite matrices specified with Wishart or InverseWishart distributions.

### 0.3.0

* Implemented restarting of MCMC chains.
* Deprecated `slicewg` and `SliceWG`.  Replaced with `:univar` option to `slice` and `Slice`.

### 0.2.1

* Updated documentation.
* Simplified parallel code.

### 0.2.0

* Automatically load *Distributions* package.
* Implemented parallel execution of parallel chains on multi-processor systems.

### 0.1.0

* Removed `MCMC` prefix from type names, and deprecated `MCMC*` types.

### 0.0.2

* Renamed package from *MCMCsim* to *Mamba*.

### 0.0.1

* Initial public release.