{ stdenv
, cc
, fetchurl
, perl

, acl

, type ? "full"
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;

  version = "4.8";

  tarballUrls = version: [
    "mirror://gnu/sed/sed-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "gnused-${type}-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "f79b0cfea71b37a8eeec8490db6c5f7ae7719c35587f21edb0617f370eeff633";
  };

  nativeBuildInputs = [
    cc
  ] ++ optionals (type == "full") [
    perl
  ];

  buildInputs = optionals (type == "full") [
    acl
  ];

  postPatch = optionalString (type == "full") ''
    patchShebangs build-aux/help2man
  '';

  postFixup = ''
    mkdir -p "$bin"/share2
  '' + optionalString (type == "full") ''
    mv "$bin"/share/locale "$bin"/share2
  '' + ''
    rm -rv "$bin"/share
    mv "$bin"/share2 "$bin"/share
  '';

  outputs = [
    "bin"
  ] ++ optionals (type == "full") [
    "man"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "4.8";
      inherit (src) outputHashAlgo;
      outputHash = "f79b0cfea71b37a8eeec8490db6c5f7ae7719c35587f21edb0617f370eeff633";
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
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
}
