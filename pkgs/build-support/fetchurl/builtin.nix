{ lib
, ...
}:

{ urls
, multihash ? ""
, name
, outputHash
, outputHashAlgo

, hashOutput ? true
, insecureHashOutput ? false
, insecureProtocolDowngrade ? false

, failEarly ? false

, executable ? false

, showURLs ? false
}:

let
  inherit (lib)
    concatStringsSep
    filterAttrs
    hasPrefix
    head
    optionals
    removePrefix
    splitString
    tail;

  common = import ./common.nix;

  mirrors = import ./mirrors.nix;

  urls_ = optionals (multihash != "")
    (map (n: "${n}/ipfs/${multihash}") mirrors.ipfs-cached)
    ++ (map (n:
      if hasPrefix "mirror://" n then
        let
          split = splitString "/" (removePrefix "mirror://" n);
        in
          "${head mirrors."${head split}"}/${concatStringsSep "/" (tail split)}"
      else
        n
      ) urls) ++ optionals (multihash != "")
    (map (n: "${n}/ipfs/${multihash}") mirrors.ipfs-nocache);
in
(filterAttrs (n: _: n != "url") (derivation {
  inherit
    name
    outputHash
    outputHashAlgo
    executable;

  inherit (common)
    impureEnvVars;

  builder = "builtin:fetchurl";
  outputHashMode = if executable then "recursive" else "flat";
  preferLocalBuild = true;

  # For compatability with older nix
  url = head urls_;
  urls = tail urls_;

  system = "builtin";
})) // {
  inherit
    multihash
    urls;
}
