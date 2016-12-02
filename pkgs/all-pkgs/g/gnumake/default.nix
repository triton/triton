{ stdenv
, fetchTritonPatch
, fetchurl
}:

let
  version = "4.2.1";

  tarballUrls = version: [
    "mirror://gnu/make/make-${version}.tar.bz2"
  ];
in
stdenv.mkDerivation rec {
  name = "gnumake-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "d6e262bf3601b42d2b1e4ef8310029e1dcf20083c5446b4b7aa67081fdffc589";
  };

  patches = [
    # Purity: don't look for library dependencies (of the form `-lfoo') in /lib
    # and /usr/lib. It's a stupid feature anyway. Likewise, when searching for
    # included Makefiles, don't look in /usr/include and friends.
    (fetchTritonPatch {
      rev = "6f9e7e9f66f12ecaa55dcae27460b37f1ee40de4";
      file = "gnumake/impure-dirs.patch";
      sha256 = "64efcd56eb445568f2e83d3c4535f645750a3f48ae04999ca4852e263819d416";
    })
  ];

  setupHook = ./setup-hook.sh;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "4.2.1";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "3D25 54F0 A153 38AB 9AF1  BB9D 96B0 4715 6338 B6D4";
      inherit (src) outputHashAlgo;
      outputHash = "d6e262bf3601b42d2b1e4ef8310029e1dcf20083c5446b4b7aa67081fdffc589";
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
