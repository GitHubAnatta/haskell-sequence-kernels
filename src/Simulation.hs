module Simulation
( dummyData
, createInfiniteData
) where

import System.Random
import Numeric.LinearAlgebra.Data

type Sequence = [Double]

randSeed = 5674
nSeqs = 20 -- number of sequences
lmin = 1 -- minimum length of a sequence
lmax = 100 -- maximum length of a sequence
ymin = 0 -- min amplitude
ymax = 10 -- max amplitude

-- A list of "random" sequences,
-- to simplify they are just linear sequences
dummyData :: [Sequence]
dummyData = take nSeqs $ createInfiniteData $ mkStdGen randSeed

createInfiniteData :: StdGen -> [Sequence]
createInfiniteData r =  let (seq, r') = createRandomSequence r
                        in seq:createInfiniteData r'

-- This code seems very awkward with all the randGen
-- but I don't know how to do it in a better way
createRandomSequence :: StdGen -> (Sequence, StdGen)
createRandomSequence randGen =
    let (y0, randGen') = randomR (ymin, ymax) randGen
        (y1, randGen'') = randomR (ymin, ymax) randGen'
        (l, randGen''') = randomR (lmin, lmax) randGen''
        seq = toList $ linspace l (y0,y1)
    in  (seq, randGen''')