{ stdenv
, curl_minimal
, gnupg
, lib
, minisign
, openssl
, signify
, textencode
, writeText
, ...
}: # Note that `curl' and `openssl' may be `null', in case of the native stdenv.

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

, recursiveHash ? false

, # Additional curl options needed for the download to succeed.
  curlOpts ? ""

, sha256Url ? ""
, sha256Urls ? [ ]
, sha256Confirm ? ""
, sha512Url ? ""
, sha512Urls ? [ ]
, sha512Confirm ? ""

, sha1Confirm ? ""
, sha1Url ? ""
, sha1Urls ? [ ]
, md5Confirm ? ""
, md5Url ? ""
, md5Urls ? [ ]

, minisignPub ? ""
, minisignUrl ? ""
, minisignUrls ? [ ]

, pgpKeyFingerprint ? ""
, pgpKeyFingerprints ? [ ]
, pgpKeyFile ? null
, pgpsigUrl ? ""
, pgpsigUrls ? [ ]
, pgpsigMd5Url ? ""
, pgpsigMd5Urls ? [ ]
, pgpsigSha1Url ? ""
, pgpsigSha1Urls ? [ ]
, pgpsigSha256Url ? ""
, pgpsigSha256Urls ? [ ]
, pgpsigSha512Url ? ""
, pgpsigSha512Urls ? [ ]
, pgpDecompress ? false

, signifyPub ? ""
, signifyUrl ? ""
, signifyUrls ? [ ]

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

, # Meta information, if any.
  meta ? { }
}:
let
  common = import ./common.nix;

  mirrors = import ./mirrors.nix;

  inherit (lib)
    concatStrings
    concatStringsSep
    flip
    mapAttrsToList
    optionals
    replaceChars;

  # Write the list of mirrors to a file that we can reuse between
  # fetchurl instantiations, instead of passing the mirrors to
  # fetchurl instantiations via environment variables.  This makes the
  # resulting store derivations (.drv files) much smaller, which in
  # turn makes nix-env/nix-instantiate faster.
  mirrorsFile = writeText "mirrors-list" (concatStrings (
    flip mapAttrsToList mirrors (mirror: urls: ''
      ${mirror} ${concatStringsSep " " urls}
    '')
  ));

  impureEnvVars = common.impureEnvVars ++ [
    # This variable allows the user to pass additional options to curl
    "NIX_CURL_FLAGS"
  ];

  urls_ = urls;
  sha512Urls_ = (if sha512Url != "" then [ sha512Url ] else [ ]) ++ sha512Urls;
  sha256Urls_ = (if sha256Url != "" then [ sha256Url ] else [ ]) ++ sha256Urls;
  sha1Urls_ = (if sha1Url != "" then [ sha1Url ] else [ ]) ++ sha1Urls;
  md5Urls_ = (if md5Url != "" then [ md5Url ] else [ ]) ++ md5Urls;
  minisignUrls_ = (if minisignUrl != "" then [ minisignUrl ] else [ ]) ++ minisignUrls;
  pgpsigUrls_ = (if pgpsigUrl != "" then [ pgpsigUrl ] else [ ]) ++ pgpsigUrls;
  pgpsigMd5Urls_ = (if pgpsigMd5Url != "" then [ pgpsigMd5Url ] else [ ]) ++ pgpsigMd5Urls;
  pgpsigSha1Urls_ = (if pgpsigSha1Url != "" then [ pgpsigSha1Url ] else [ ]) ++ pgpsigSha1Urls;
  pgpsigSha256Urls_ = (if pgpsigSha256Url != "" then [ pgpsigSha256Url ] else [ ]) ++ pgpsigSha256Urls;
  pgpsigSha512Urls_ = (if pgpsigSha512Url != "" then [ pgpsigSha512Url ] else [ ]) ++ pgpsigSha512Urls;
  pgpKeyFingerprints_ = map (n: replaceChars [ " " ] [ "" ] n) ((if pgpKeyFingerprint != "" then [ pgpKeyFingerprint ] else [ ]) ++ pgpKeyFingerprints);
  signifyUrls_ = (if signifyUrl != "" then [ signifyUrl ] else [ ]) ++ signifyUrls;
in
stdenv.mkDerivation {
  inherit
    name
    outputHash
    outputHashAlgo
    executable;

  inherit
    impureEnvVars;

  outputHashMode = if recursiveHash || executable then "recursive" else "flat";
  preferLocalBuild = true;

  builder = ./builder.sh;

  buildInputs = [
    curl_minimal.bin
    openssl.bin
    textencode
  ] ++ optionals (pgpKeyFile != null || pgpKeyFingerprints_ != [ ]) [
    gnupg
  ] ++ optionals (minisignPub != "") [
    minisign
  ] ++ optionals (signifyPub != "") [
    signify
  ];

  urls = urls_;
  sha512Urls = sha512Urls_;
  sha256Urls = sha256Urls_;
  sha1Urls = sha1Urls_;
  md5Urls = md5Urls_;
  minisignUrls = minisignUrls_;
  pgpsigUrls = pgpsigUrls_;
  pgpsigMd5Urls = pgpsigMd5Urls_;
  pgpsigSha1Urls = pgpsigSha1Urls_;
  pgpsigSha256Urls = pgpsigSha256Urls_;
  pgpsigSha512Urls = pgpsigSha512Urls_;
  pgpKeyFingerprints = pgpKeyFingerprints_;
  signifyUrls = signifyUrls_;

  inherit
    failEarly
    hashOutput
    insecureHashOutput
    insecureProtocolDowngrade
    curlOpts
    mirrorsFile
    preFetch
    postFetch
    postVerification
    downloadToTemp
    sha1Confirm
    md5Confirm
    multihash
    minisignPub
    pgpKeyFile
    pgpDecompress
    showURLs
    signifyPub;
}
