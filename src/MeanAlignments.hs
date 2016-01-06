module MeanAlignments
( computeGramMatrix
) where

import System.Random
import Numeric.LinearAlgebra.HMatrix
import qualified Data.Map as Map
import Simulation
import SequenceIO

sigma = 3.0 -- bandwidth for the kernel

type Sequence = [Double]
type Index = (Int,Int)
type DynList = Map.Map Index Double

-- This function computes a distance between two sequences
-- As this distance is Hilbertian its exponentiation leads to a
-- positive definite kernel
oneSidedMean :: Sequence -> Sequence -> Double
oneSidedMean seq1 seq2 = let n1 = length seq1
                             n2 = length seq2
                         in -- The shorter sequence plays a special role, hence the name "one-sided"
                         if n1 < n2 then (oneSidedDynProg seq1 seq2) / fromIntegral n2
                                    else (oneSidedDynProg seq2 seq1) / fromIntegral n1

-- This is where the dynamic programming is actually carried.
-- A Map (DynList) is used instead of the usual matrix,
-- which is terribly inefficient since it has to be recreated at each step...
oneSidedDynProg :: Sequence -> Sequence -> Double
oneSidedDynProg seqA seqB = let l = length seqA
                                m = (length seqB) - (length seqA) + 1
                                indices = unrollIndexes l m
                                completeDynList = foldl (updateDynList seqA seqB) Map.empty indices
                            in -- we only keep the last computed value
                            case (Map.lookup (l,m) completeDynList) of Nothing -> error "Lookup failed"
                                                                       Just x -> x

-- This function computes the next intermediate values (at index (i,j) )of the dynamic programming
-- using previously computed values (at indexes (i-1,j) and (i,j-1) ) and the distance
-- between element at index i-1 of the short sequence and element at index i+j-2 of the long sequence
updateDynList :: Sequence -> Sequence -> DynList -> Index -> DynList
updateDynList seqA seqB dynList (i,j) = Map.insert (i,j) newValue dynList where
    newValue = let f = oneSidedComparison seqA seqB
               in
               if (i,j)==(1,1)  then f 1 1
                                else let i' = fromIntegral i
                                         j' = fromIntegral j
                                         dynI = case (Map.lookup (i - 1, j) dynList) of Nothing -> 0 -- optimize this
                                                                                        Just x -> x
                                         dynJ = case (Map.lookup (i, j - 1) dynList) of Nothing -> 0
                                                                                        Just x -> x
                                         a = (i' - 1) / (i' + j' - 2) * dynI
                                         b = (j' - 1) / (i' + j' - 2) * dynJ
                                     in a + b + f i j

oneSidedComparison :: Sequence -> Sequence -> Int -> Int -> Double
oneSidedComparison seqA seqB i j = let elementA = seqA !! (i - 1)
                                       elementB = seqB !! (i + j -2)
                                   in (elementA - elementB)^2 -- here you can use the square of any distance that is Hilbertian

-- This function computes a Gram matrix from a list of sequences
-- Element at index (i,j) of the matrix is the "similarity" of sequences i and j
-- The "similarity" is the exponentiation of the one-sided mean distance,
-- such that a distance of 0 corresponds to a similarity of 1,
-- and an infinite distance corresponds to a similarity of 0.
-- As the one-sided mean distance is Hilbertian the corresponding Gram matrix will be positive definite
computeGramMatrix :: [Sequence] -> Matrix Double
computeGramMatrix seqs = let nSeqs = length seqs
                             f (i,j) = oneSidedMean (seqs !! (i-1)) (seqs !! (j-1))
                             elements = map f $ unrollIndexes nSeqs nSeqs
                             hilbertDistMat = matrix nSeqs elements
                             exp' x = exp (- x / (2 * sigma))
                         in cmap exp' hilbertDistMat

unrollIndexes :: Int -> Int -> [Index]
unrollIndexes l m = concatMap (\n -> [(n,i) | i <- [1..m]]) [1..l]