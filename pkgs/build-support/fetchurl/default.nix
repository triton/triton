{ stdenv
, ...} @ pkgArgs:

{ # URL to fetch.
  url ? ""

, # Alternatively, a list of URLs specifying alternative download
  # locations.  They are tried in order.
  urls ? []

, # IPFS Content hash to download from
  multihash ? ""

, # Name of the file.  If empty, use the basename of `url' (or of the
  # first element of `urls').
  name ? ""

  # Different ways of specifying the hash.
, sha256 ? ""
, sha512 ? ""
, outputHash ? ""
, outputHashAlgo ? ""

, # Prints the output of the hash if download fails
  hashOutput ? true

, # Prints the hash even if the download was from an insecure source
  insecureHashOutput ? false

, # Allows the download to be downgraded from secure to insecure via redirect
  insecureProtocolDowngrade ? false

, # If the first download fails, the whole derivation fails
  failEarly ? false

, # If true, set executable bit on downloaded file
  executable ? false

, # If set, don't download the file, but write a list of all possible
  # URLs (resulting from resolving mirror:// URLs) to $out.
  showURLs ? false

, # Passthru data
  passthru ? {}

, # Full options defined in ./full.nix
  fullOpts ? null
} @ args:

let
  inherit (stdenv.lib)
    all
    any
    head
    filterAttrs;

  badAttrs = [
    "fullOpts"
    "passthru"
    "sha256"
    "sha512"
    "url"
  ];

  urls_ = (if url != "" then [ url ] else [ ]) ++ urls;

  args_ = filterAttrs (n: _: all (b: b != n) badAttrs) args // {
    urls = urls_;

    outputHashAlgo =
      if outputHashAlgo != "" then
        outputHashAlgo
      else if sha512 != "" then
        "sha512"
      else if sha256 != "" then
        "sha256"
      else
        throw "Unsupported hash";

    outputHash =
      if outputHash != "" then
        outputHash
      else if sha512 != "" then
        sha512
      else if sha256 != "" then
        sha256
      else
        throw "Unsupported hash";

    name =
      if name != "" then
        name
      else
        baseNameOf (toString (head urls_));
  };
in

assert urls_ != [ ] || multihash != "";

assert any (n: n == args_.outputHashAlgo) [ "sha256" "sha512" ];

(if fullOpts != null then
  import ./full.nix pkgArgs (fullOpts // args_)
else
  import ./builtin.nix pkgArgs args_) // passthru
