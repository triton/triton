{ stdenv, curl, openssl, minisign, gnupg }: # Note that `curl' and `openssl' may be `null', in case of the native stdenv.

let

  mirrors = import ./mirrors.nix;

  # Write the list of mirrors to a file that we can reuse between
  # fetchurl instantiations, instead of passing the mirrors to
  # fetchurl instantiations via environment variables.  This makes the
  # resulting store derivations (.drv files) much smaller, which in
  # turn makes nix-env/nix-instantiate faster.
  mirrorsFile = stdenv.mkDerivation {
    name = "mirrors-list";
    buildCommand = stdenv.lib.concatStrings (
      stdenv.lib.flip stdenv.lib.mapAttrsToList mirrors (mirror: urls: ''
        echo '${mirror} ${stdenv.lib.concatStringsSep " " urls}' >> "$out"
      '')
    );
    preferLocalBuild = true;
  };

  # Names of the master sites that are mirrored (i.e., "sourceforge",
  # "gnu", etc.).
  sites = builtins.attrNames mirrors;

  impureEnvVars = [
    # We borrow these environment variables from the caller to allow
    # easy proxy configuration.  This is impure, but a fixed-output
    # derivation like fetchurl is allowed to do so since its result is
    # by definition pure.
    "http_proxy" "https_proxy" "ftp_proxy" "all_proxy" "no_proxy"

    # This variable allows the user to pass additional options to curl
    "NIX_CURL_FLAGS"

    # This allows the end user to specify the local ipfs host:port which hosts
    # the content
    "IPFS_API"
  ] ++ (map (site: "NIX_MIRRORS_${site}") sites);

in

{ # URL to fetch.
  url ? ""

, # Alternatively, a list of URLs specifying alternative download
  # locations.  They are tried in order.
  urls ? []

, # Additional curl options needed for the download to succeed.
  curlOpts ? ""

, # Name of the file.  If empty, use the basename of `url' (or of the
  # first element of `urls').
  name ? ""

  # Different ways of specifying the hash.
, outputHash ? ""
, outputHashAlgo ? ""
, sha256 ? ""
, sha512 ? ""

, sha1Confirm ? ""
, md5Confirm ? ""

, multihash ? ""

, minisignPub ? ""
, minisignUrl ? ""
, minisignUrls ? []

, pgpKeyId ? ""
, pgpKeyIds ? []
, pgpKeyFingerprint ? ""
, pgpKeyFingerprints ? []
, pgpKeyFile ? null
, pgpsigUrl ? ""
, pgpsigUrls ? []

, recursiveHash ? false

, # Shell code executed before the file has been fetched.
  # This can do things like force a site to generate the file.
  preFetch ? ""

, # Shell code executed after the file has been fetched
  # successfully. This can do things like check or transform the file.
  postFetch ? ""

, # Shell code executed after the verifications have been performed
  # This does not include the final checksum
  postVerification ? ""

, # Whether to download to a temporary path rather than $out. Useful
  # in conjunction with postFetch. The location of the temporary file
  # is communicated to postFetch via $downloadedFile.
  downloadToTemp ? false

, # If true, set executable bit on downloaded file
  executable ? false

, # If set, don't download the file, but write a list of all possible
  # URLs (resulting from resolving mirror:// URLs) to $out.
  showURLs ? false

, # Meta information, if any.
  meta ? {}
}:

let

  hasHash = showURLs || (outputHash != "" && outputHashAlgo != "")
    || sha256 != "" || sha512 != "";

  urls_ = (if url != "" then [ url ] else [ ]) ++ urls;
  minisignUrls_ = (if minisignUrl != "" then [ minisignUrl ] else [ ]) ++ minisignUrls;
  pgpsigUrls_ = (if pgpsigUrl != "" then [ pgpsigUrl ] else [ ]) ++ pgpsigUrls;
  pgpKeyIds_ = (if pgpKeyId != "" then [ pgpKeyId ] else [ ]) ++ pgpKeyIds;
  pgpKeyFingerprints_ = (if pgpKeyFingerprint != "" then [ pgpKeyFingerprint ] else [ ]) ++ pgpKeyFingerprints;

in

assert urls_ != [ ] || multihash != "";

assert stdenv.lib.length pgpKeyIds_ == stdenv.lib.length pgpKeyFingerprints_;

if (!hasHash) then throw "Specify hash for fetchurl fixed-output derivation: ${stdenv.lib.concatStringsSep ", " urls_}" else stdenv.mkDerivation {
  name =
    if name != "" then name
    else baseNameOf (toString (builtins.head urls_));

  builder = ./builder.sh;

  buildInputs = [
    curl
    openssl
  ] ++ stdenv.lib.optionals (minisignPub != "") [
    minisign
  ] ++ stdenv.lib.optionals (pgpKeyFile != null || pgpKeyIds_ != []) [
    gnupg
  ];

  urls = urls_;
  minisignUrls = minisignUrls_;
  pgpsigUrls = pgpsigUrls_;
  pgpKeyIds = pgpKeyIds_;
  pgpKeyFingerprints = pgpKeyFingerprints_;

  # New-style output content requirements.
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

  outputHashMode = if (recursiveHash || executable) then "recursive" else "flat";

  inherit curlOpts showURLs mirrorsFile impureEnvVars preFetch postFetch postVerification downloadToTemp executable sha1Confirm md5Confirm multihash minisignPub pgpKeyFile;

  # Doing the download on a remote machine just duplicates network
  # traffic, so don't do that.
  preferLocalBuild = true;

  inherit meta;
}
