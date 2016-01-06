module SequenceIO
( loadSequences
, saveSequences
) where

import System.IO
import Data.List.Split
import Data.List

type Sequence = [Double]

-- Reads a list of sequences from a file
loadSequences :: FilePath -> IO [Sequence]
loadSequences filePath = do
    contents <- readFile filePath
    let allLines = lines contents
        splitted = map (splitOn ",") $ allLines
    return (map (map read) $ splitted)

-- Writes a list of sequences to a file
saveSequences :: FilePath -> [Sequence] -> IO ()
saveSequences filePath sequences = do
    let splitted = map (map show) sequences
        allLines = map (intercalate ",") splitted
    writeFile filePath (unlines allLines)