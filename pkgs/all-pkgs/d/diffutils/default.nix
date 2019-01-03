{ stdenv
, fetchurl

, type ? "full"
}:

let
  inherit (stdenv.lib)
    optionalString;

  version = "3.7";

  tarballUrls = version: [
    "mirror://gnu/diffutils/diffutils-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "diffutils-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "b3a7a6221c3dc916085f0d205abf6b8e1ba443d4dd965118da364a1dc1cb3a26";
  };

  # We don't want to end up with a dependency on bootstrap-tools
  ac_cv_path_PR_PROGRAM = "pr";

  postInstall = optionalString (type != "full") ''
    rm -r "$out"/share
  '';

  allowedReferences = [
    "out"
    stdenv.cc.libc
    stdenv.cc.cc
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "3.7";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "155D 3FC5 00C8 3448 6D1E  EA67 7FD9 FCCB 000B EEEE";
      inherit (src) outputHashAlgo;
      outputHash = "b3a7a6221c3dc916085f0d205abf6b8e1ba443d4dd965118da364a1dc1cb3a26";
    };
  };

  meta = with stdenv.lib; {
    description = "Commands for showing the differences (diff) between files";
    homepage = http://www.gnu.org/software/diffutils/diffutils.html;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
