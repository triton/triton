{ stdenv
, fetchurl

, type ? "full"
}:

let
  inherit (stdenv.lib)
    optionalString
    optionals;

  tarballUrls = version: [
    "mirror://gnu/gzip/gzip-${version}.tar.xz"
  ];

  version = "1.10";
in
stdenv.mkDerivation rec {
  name = "gzip-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "8425ccac99872d544d4310305f915f5ea81e04d0f437ef1a230dc9d1c819d7c0";
  };

  # In stdenv-linux, prevent a dependency on bootstrap-tools.
  makeFlags = [
    "SHELL=/bin/sh"
    "GREP=grep"
  ];

  postFixup = ''
    mkdir -p "$bin"/share2
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
      urls = tarballUrls "1.10";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "155D 3FC5 00C8 3448 6D1E  EA67 7FD9 FCCB 000B EEEE";
      outputHash = "8425ccac99872d544d4310305f915f5ea81e04d0f437ef1a230dc9d1c819d7c0";
      inherit (src) outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/gzip/;
    description = "GNU zip compression program";
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
