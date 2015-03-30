module Main (main) where
    
import Data.List
import Data.Function
import Text.Printf
import Text.Parsec
import Text.Parsec.String
import Text.Parsec.Token
import Text.Parsec.Language
import Control.Applicative hiding ((<|>))
import System.Console.Haskeline


  
data Problem 
  = Problem {income::[(Double,Double)], -- Incomes,Prob
             auditCost:: Double -- Verification cost
            }
  deriving Show

type Contract = [(Double,Bool)] -- Claim, if verified

              
validate::Problem->Contract->Maybe String
validate Problem{income=yp} contract
  |length yp /= length contract
    = Just "Mismatch in environment and contract length"
  | or [b>y|((y,_),(b,_))<-zip yp contract]
    = Just "Claim greater than income"
  | otherwise
    = Nothing

expectPay::Problem->Contract->(Double,Double)
expectPay Problem{income=yp,auditCost=c} contract
  = (y-expclaim,expclaim-expcost)
  where
    y = sum [y*p|(y,p)<-yp]
    expclaim = sum [b*p|((y,p),(b,_))<-zip yp contract]
    expcost = sum [c*p|((_,p),(_,v))<-zip yp contract,v]

findLies::Problem->Contract->[(Double,Double)]
findLies Problem{income=yp} contract
  = if null noverif then
      []
    else
      [(y,my)|(y,_,b,_)<-z,b>m]
  where
    z = [(y,p,b,v)|((y,p),(b,v))<- zip yp contract]
    noverif = filter (\ (_, _, _, v)-> not v) z
    (my,m) = minimumBy (compare `on` snd)
             [(y,b)|(y,_,b,_)<-noverif]

bestContract::Problem->Double->Contract
bestContract Problem{income=yp,auditCost=c} desired
  = if desired<=0 then
      replicate (length yp) (0,False)
    else
      loop yp 1.0 desired
  where
    loop [] _ _ = []
    loop ((y,p):ys) prob d
      = if y >= d then
          (d,False):loop ys (prob-p) d
        else
          let p' = prob - p
              d' = d+(d-y+c)*p/p' in
          (y,True):loop ys p' d'

defaultProb::Problem
defaultProb = Problem (zip [0,2,4,6,8] (repeat 0.2)) 1

data CheckResult = Efficient
                 | Inefficient Contract
                 | Untruthful [(Double,Double)]
                 | Invalid String
                   deriving Show

check::Problem->Contract->CheckResult
check p c
  = case validate p c of
    Just s -> Invalid s
    Nothing -> case findLies p c of
      [] -> let (ent,inv) = expectPay p c
                bc = bestContract p inv
                (ent',inv') = expectPay p bc in
            if ((ent'-ent)>0 && (inv'-inv)>=0)
               || ((ent'-ent)>=0 && (inv'-inv)>0) then
              Inefficient bc
            else
              Efficient
      lies -> Untruthful lies

--- Parser  
parseContract::String->Either ParseError Contract
parseContract = parse (contractP <* eof) "<interactive>" 
  where
    lexer = makeTokenParser emptyDef
    contractP = entryP `sepBy` symbol lexer ","
    entryP = do
      claim' <- naturalOrFloat lexer
      let claim = case claim' of
            Left i -> fromIntegral i
            Right d -> d
      verified <- option False (symbol lexer "*" *> pure True)
      return (claim,verified)


--- Driver
ppContract::Contract->String
ppContract = intercalate "," . map f
  where
    f (b,v) = bs++vs
      where
        bs = printf "%.2g" b
        vs = if v then "*" else ""

main::IO ()
main = do
  let prob = defaultProb
  putStrLn $ "Incomes, p: "++show (income prob)
    ++".\nAudit cost: "++show (auditCost prob)++"\n"
  putStrLn "Enter entrepreneur's payment for each state separated by commas"
  putStrLn "Put a '*' after a payment to denote a verified state."
  putStrLn "For eg: 0*,2*,4,4,4"
  putStrLn "The audit cost is payed by the investor."
  putStrLn "Type 'q' to quit\n"
  runInputT defaultSettings (processOne prob)

processOne::Problem->InputT IO ()
processOne prob = do
  inp <- getInputLine "> "
  case inp of
    Nothing -> return ()
    Just "q" -> return ()
    Just s -> do
      realProcess prob s
      processOne prob

realProcess::Problem->String->InputT IO ()
realProcess prob s = do
  let pres =  parseContract s
  case pres of
    Left err -> outputStrLn (show err)
    Right c ->
      case check prob c of
        Invalid s -> outputStrLn ("Invalid: "++s)
        Efficient -> outputStrLn "Your contract is efficient"
        Untruthful lies ->
          outputStrLn $ "Untruthful: "
           ++intercalate ", " [show from++" -> "++show to
                              |(from,to)<-lies]
        Inefficient better -> do
          outputStrLn "Inefficient"
          let (ent,inv) = expectPay prob c
          outputStrLn $
            printf "Your contract pays Ent=%.2g, Inv=%.2g"
                ent inv
          outputStrLn $ "Try: " ++ ppContract better
          let (ent', inv') = expectPay prob better
          outputStrLn $
            printf "which pays Ent=%.2g, Inv=%.2g" ent' inv'
                                              
                                              
                                   

                                
