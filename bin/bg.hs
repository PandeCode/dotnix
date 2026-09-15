#! /usr/bin/env nix-shell
#! nix-shell -p "haskellPackages.ghcWithPackages (p: with p; [turtle])" -i runghc

{-# LANGUAGE OverloadedStrings #-}

import Turtle

main :: IO()
main = do
    echo "Hello world!"
