module Main where

import Numeric.LinearAlgebra.HMatrix

import Simulation
import SequenceIO
import MeanAlignments

main :: IO ()
main = do
    alldata <- loadSequences "example_data.txt"
    let gramMat = computeGramMatrix alldata
    let (d,v) = eigSH gramMat
    putStrLn "Eigenvalues are:"
    -- For any list of sequences the eigenvalues shall all be positive
    -- since the kernel is provably positive definite
    print d