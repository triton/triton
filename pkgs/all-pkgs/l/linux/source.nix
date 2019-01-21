{ lib
, fetchurl
, fetchFromGitHub
, source
}:

let
  inherit (lib)
    elemAt
    head
    optionals
    splitString
    tail
    toInt;

  inherit (source)
    version;

  lastMinors = {
    "4" = 20;
  };

  unpatchedVersion =
    let
      rclist = splitString "-" version;
      isRC = [ ] != tail rclist;
      vlist = splitString "." (head rclist);
      majorInt = toInt (elemAt vlist 0);
      minorInt = toInt (elemAt vlist 1);
      correctMajor =
        if isRC && minorInt == 0 then majorInt - 1 else majorInt;
      correctMinor =
        if isRC then
          if minorInt == 0 then lastMinors."${toString correctMajor}" else minorInt - 1
        else
          minorInt;
    in "${toString correctMajor}.${toString correctMinor}";

  directoryUrls = version: [
    "mirror://kernel/linux/kernel/v${head (splitString "." version)}.x"
  ];

  src = if source ? rev then
    fetchFromGitHub {
      inherit (source)
        owner
        repo
        rev
        sha256;
    }
  else
    fetchurl {
      urls =
        let
          version' = if source ? baseSha256 then unpatchedVersion else version;
        in source.baseUrls or (source.urls or (map (n: "${n}/linux-${version'}.tar.xz") (directoryUrls version')));
      hashOutput = false;
      sha256 = source.baseSha256 or source.sha256;
    };

  patch = if source ? patchSha256 && source.patchSha256 != null then
    fetchurl {
      urls = source.patchUrls or (map (n: "${n}/patch-${version}.xz") (directoryUrls version));
      hashOutput = false;
      sha256 = source.patchSha256;
    }
  else
    null;

  pgpKeyFingerprints = [
    "647F 2865 4894 E3BD 4571  99BE 38DB BDC8 6092 693E"
    "ABAF 11C6 5A29 70B1 30AB  E3C4 79BE 3E43 0041 1886"
  ];

  srcsVerification = [
    (fetchurl {
      failEarly = true;
      fullOpts = let v = if source ? baseSha256 then unpatchedVersion else version; in {
        pgpDecompress = true;
        pgpsigUrls = map (n: "${n}/linux-${v}.tar.sign") (directoryUrls v);
        inherit pgpKeyFingerprints;
      };
      inherit (src) urls outputHash outputHashAlgo;
    })
  ] ++ optionals (patch != null) [
    (fetchurl {
      failEarly = true;
      fullOpts = { };
      inherit (patch) urls outputHash outputHashAlgo;
    })
  ];
in {
  inherit
    src
    srcsVerification
    patch;
}
