### About

This is a very small toy project that I made to experiment with the Haskell programming language.

It reads a set of sequences from file `example_data.txt`, computes a Gram matrix of these sequences using the _one-sided mean alignment kernel_, computes the eigenvalues of this matrix and displays them.
As the one-sided mean alignment kernel is provably positive definite, the eigenvalues are all positive.

The project also contains code to generate random dummy time series.

### Usage

1. If you do not have stack installed you can on OS X with `Homebrew`:

    ```bash
    brew update
    brew install haskell-stack
    ```
2. Then build and run the program:

    ```bash
    cd haskell-sequence-kernels
    stack setup
    stack build
    stack exec haskell-sequence-kernels-exe
    ```

### Performance

Performance is terrible.

This is because currently dynamic programming is implemented by keeping intermediate results in a `Data.Map` structure which does not have constant access time like vectors.
In the future I plan on using a mutable vector or matrix with the `ST` monad.
Nevertheless, on this dataset the Haskell program compiled with `O2` optimization level is quite surprisingly almost faster than the Python equivalent.

### About the one-sided mean alignment kernel

Well-known kernel methods such as for example SVM and Kernel PCA rely on a kernel which is used to compute a Gram matrix which can generally be interpreted as a matrix of similarity values between any pair of samples in the dataset.
These algorithms require that the kernel be _positive definite_, which guarantees that the resulting optimization programs are convex whatever the samples.

When dealing with vector data the most common choice is generally a Gaussian kernel, but when the samples are time-series (or more generally sequences) custom kernels must be used.
There are not many sensible choices, as merely using a classic _dynamic time warping_ distance does not lead to a positive definite kernel.

To this end we propose the one-sided mean kernel, which has many advantages:
* Provably positive definite,
* Faster than competing techniques with a time complexity of `O(l × (m - l))` instead of `O(l × m)` for sequences of length `l < m`,
* Consistent with a vector kernel when time series are of equal length,
* Does not suffer from issues of diagonal dominance like the global alignment kernel for example.

### TODO

1. Rewrite the algorithm using the `ST` monad,
2. Implement other kernels such as classic dynamic time warping and the global alignment kernel,
3. Add support for multivariate time-series,
4. Automatic selection of the kernel bandwith,

### References

* N. Chrysanthos, P. Beauseroy, H. Snoussi, E. Grall-Maës, __Theoretical properties and implementation of the one-sided mean kernel for time series__, in: _Neurocomputing_ 169 (2015) 196–204
* M. Cuturi, J.-P. Vert, O. Birkenes, T. Matsui, __A kernel for time series based on global alignments__, in: _IEEE International Conference on Acoustics, Speech and Signal Processing_, 2007
* J.-P. Vert, __The Optimal Assignment Kernel is not Positive Definite__ in: _arXiv:0801. 4061_
