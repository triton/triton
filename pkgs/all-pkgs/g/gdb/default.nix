{ stdenv
, fetchurl
, perl
, texinfo
}:

stdenv.mkDerivation rec {
  name = "gdb-8.0.1";

  src = fetchurl {
    url = "mirror://gnu/gdb/${name}.tar.xz";
    hashOutput = false;
    sha256 = "3dbd5f93e36ba2815ad0efab030dcd0c7b211d7b353a40a53f4c02d7d56295e3";
  };

  nativeBuildInputs = [
    perl
    texinfo
  ];

  # The install junks up lib / include with some static library
  # files from the build. We don't want these.
  postInstall = ''
    rm -r "$out"/{include,lib}
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "F40A DB90 2B24 264A A42E  50BF 92ED B04B FF32 5CF3";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
