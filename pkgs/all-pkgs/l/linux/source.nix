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

  unpatchedVersion =
    let
      rclist = splitString "-" version;
      isRC = [ ] != tail rclist;
      vlist = splitString "." (head rclist);
      minorInt = toInt (elemAt vlist 1);
      correctMinor = if isRC then minorInt - 1 else minorInt;
    in "${elemAt vlist 0}.${toString correctMinor}";

  directoryUrls = [
    "mirror://kernel/linux/kernel/v4.x"
    "mirror://kernel/linux/kernel/v4.x/testing"
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
        in source.baseUrls or (source.urls or (map (n: "${n}/linux-${version'}.tar.xz") directoryUrls));
      hashOutput = false;
      sha256 = source.baseSha256 or source.sha256;
    };

  patch = if source ? patchSha256 && source.patchSha256 != null then
    fetchurl {
      name = "linux-${version}.patch.xz";
      urls = source.patchUrls or (map (n: "${n}/patch-${version}.xz") directoryUrls);
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
      pgpDecompress = true;
      pgpsigUrls = map (n: "${n}/linux-${if source ? baseSha256 then unpatchedVersion else version}.tar.sign") directoryUrls;
      inherit (src) urls outputHash outputHashAlgo;
      inherit pgpKeyFingerprints;
    })
  ] ++ optionals (patch != null) [
    (fetchurl {
      failEarly = true;
      pgpDecompress = true;
      pgpsigUrls = map (n: "${n}/patch-${version}.sign") directoryUrls;
      inherit (patch) urls outputHash outputHashAlgo;
      inherit pgpKeyFingerprints;
    })
  ];
in {
  inherit
    src
    srcsVerification
    patch;
}
