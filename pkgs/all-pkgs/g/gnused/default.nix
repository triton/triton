{ stdenv
, fetchurl
, perl

, acl

, type ? "full"
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;

  version = "4.7";

  tarballUrls = version: [
    "mirror://gnu/sed/sed-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "gnused-${type}-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "2885768cd0a29ff8d58a6280a270ff161f6a3deb5690b2be6c49f46d4c67bd6a";
  };

  nativeBuildInputs = optionals (type == "full") [
    perl
  ];

  buildInputs = optionals (type == "full") [
    acl
  ];

  postPatch = optionalString (type == "full") ''
    patchShebangs build-aux/help2man
  '';

  postInstall = optionalString (type != "full") ''
    rm -r "$out"/share
  '';

  allowedReferences = [
    "out"
    stdenv.cc.libc
    stdenv.cc.cc
  ] ++ optionals (type == "full") [
    acl
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "4.7";
      inherit (src) outputHashAlgo;
      outputHash = "2885768cd0a29ff8d58a6280a270ff161f6a3deb5690b2be6c49f46d4c67bd6a";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "155D 3FC5 00C8 3448 6D1E  EA67 7FD9 FCCB 000B EEEE";
      };
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/sed/;
    description = "GNU sed, a batch stream editor";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
