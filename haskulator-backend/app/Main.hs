{-# LANGUAGE OverloadedStrings #-}

import Network.Wai (Application, requestBody, responseLBS)
import Network.Wai.Handler.Warp (run)
import Network.HTTP.Types (status200)
import Data.Aeson (withObject, decode, encode, object, (.=), Value, Value(Object), (.:))
import qualified Data.ByteString.Lazy as BL
import qualified Data.ByteString as BS
import Data.Maybe (fromMaybe)
import Control.Applicative ((<|>)) 
import Network.Wai.Middleware.Cors (cors, corsRequestHeaders, corsOrigins, corsMethods, corsMaxAge, CorsResourcePolicy(..))
import Data.Aeson.Types (Parser, Object, parseEither)
-- Example calculation functions

calculateDisplacementWithoutVelocityOrAcceleration :: Double -> Double -> Double
calculateDisplacementWithoutVelocityOrAcceleration initial final = final - initial

calculateDisplacement :: Double -> Double -> Double -> Double
calculateDisplacement initialVelocity acceleration time = initialVelocity * time + 0.5 * acceleration * time^2

calculateAcceleration :: Double -> Double -> Double
calculateAcceleration force mass = force / mass

calculateVelocity :: Double -> Double -> Double -> Double
calculateVelocity initialVelocity acceleration time = initialVelocity + acceleration * time

calculateVelocityWithFinal :: Double -> Double -> Double -> Double
calculateVelocityWithFinal initialVelocity finalVelocity time = (finalVelocity - initialVelocity) / time

main :: IO ()
main = run 8000 app

app :: Application
app = cors (const $ Just simpleCorsResourcePolicy) $ \req respond -> do
    body <- requestBody req
    let lazyBody = BL.fromStrict body
    let maybeInput = decode lazyBody :: Maybe Value
    print maybeInput
    let result = case maybeInput of
                    Just input -> either (const $ object ["result" .= ("Invalid calculation" :: String)]) id (parseEither calculateResult input)
                    Nothing    -> object ["result" .= ("Invalid input" :: String)]
    respond $ responseLBS status200 [("Content-Type", "application/json")] (encode result)

-- Function to handle calculations
calculateResult :: Value -> Parser Value
calculateResult = withObject "Object" $ \o -> do
    choice <- o .: "choice" :: Parser String
    subChoice <- o .: "subChoice" :: Parser String
    case (choice, subChoice) of
        ("displacement", "1") -> calculateDisplacementWithoutVelocityOrAccelerationResult o
        ("displacement", "2") -> calculateDisplacementResult o
        ("acceleration", "1") -> calculateAccelerationResult o
        ("acceleration", "2") -> calculateAccelerationForceMassResult o
        ("velocity", "1") -> calculateVelocityResult o
        ("velocity", "2") -> calculateVelocityWithFinalResult o
        _ -> return $ object ["result" .= ("Invalid choice or sub-choice" :: String)]

-- Displacement without velocity or acceleration
calculateDisplacementWithoutVelocityOrAccelerationResult :: Object -> Parser Value
calculateDisplacementWithoutVelocityOrAccelerationResult o = do
    ip <- o .: "initialPosition" :: Parser Double
    fp <- o .: "finalPosition" :: Parser Double
    return $ object ["result" .= calculateDisplacementWithoutVelocityOrAcceleration ip fp]

-- Displacement with velocity and acceleration
calculateDisplacementResult :: Object -> Parser Value
calculateDisplacementResult o = do
    iv <- o .: "initialVelocity" :: Parser Double
    a <- o .: "acceleration" :: Parser Double
    t <- o .: "time" :: Parser Double
    return $ object ["result" .= calculateDisplacement iv a t]

-- Acceleration from force and mass
calculateAccelerationResult :: Object -> Parser Value
calculateAccelerationResult o = do
    f <- o .: "force" :: Parser Double
    m <- o .: "mass" :: Parser Double
    return $ object ["result" .= calculateAcceleration f m]

-- Acceleration from force and mass
calculateAccelerationForceMassResult :: Object -> Parser Value
calculateAccelerationForceMassResult o = do
    f <- o .: "force" :: Parser Double
    m <- o .: "mass" :: Parser Double
    return $ object ["result" .= calculateAcceleration f m]

-- Velocity from initial velocity, acceleration, and time
calculateVelocityResult :: Object -> Parser Value
calculateVelocityResult o = do
    iv <- o .: "initialVelocity" :: Parser Double
    a <- o .: "acceleration" :: Parser Double
    t <- o .: "time" :: Parser Double
    return $ object ["result" .= calculateVelocity iv a t]

-- Velocity with final velocity calculation
calculateVelocityWithFinalResult :: Object -> Parser Value
calculateVelocityWithFinalResult o = do
    iv <- o .: "initialVelocity" :: Parser Double
    fv <- o .: "finalVelocity" :: Parser Double
    t <- o .: "time" :: Parser Double
    return $ object ["result" .= calculateVelocityWithFinal iv fv t]

-- Define a CORS policy
simpleCorsResourcePolicy :: CorsResourcePolicy
simpleCorsResourcePolicy = CorsResourcePolicy
    { corsOrigins = Nothing
    , corsMethods = ["GET", "POST", "OPTIONS"]
    , corsRequestHeaders = ["Content-Type"]
    , corsMaxAge = Nothing
    , corsExposedHeaders = Nothing
    , corsRequireOrigin = False
    , corsVaryOrigin = True
    , corsIgnoreFailures = False
    }