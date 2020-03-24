{ stdenv
, fetchTritonPatch
, fetchurl

, type ? "full"
}:

let
  inherit (stdenv.lib)
    optionalString;

  version = "4.3";

  tarballUrls = version: [
    "mirror://gnu/make/make-${version}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "gnumake-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "e05fdde47c5f7ca45cb697e973894ff4f5d79e13b750ed57d7b66d8defc78e19";
  };

  patches = [
    (fetchTritonPatch {
      rev = "3a7cc75d7262018ac16d166a1f55840c89039219";
      file = "g/gnumake/impure-dirs.patch";
      sha256 = "ed2c31197e001e06ba14064c22608272cc4d2eded7e56ae70ae3e66a528a679d";
    })
  ];

  configureFlags = [
    # Workaround broken autodetection
    "make_cv_sys_gnu_glob=yes"
  ];

  postInstall = ''
    # Nothing should be using the header
    rm -r "$out"/include
  '' + optionalString (type != "full") ''
    rm -r "$out"/share
  '';

  allowedReferences = [
    "out"
  ] ++ stdenv.cc.runtimeLibcLibs;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "4.3";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "3D25 54F0 A153 38AB 9AF1  BB9D 96B0 4715 6338 B6D4";
      inherit (src) outputHashAlgo;
      outputHash = "e05fdde47c5f7ca45cb697e973894ff4f5d79e13b750ed57d7b66d8defc78e19";
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/make/;
    description = "A tool to control the generation of non-source files from sources";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
