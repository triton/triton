{ stdenv
, fetchTritonPatch
, fetchurl

, type ? "full"
}:

let
  inherit (stdenv.lib)
    optionalString
    optionals;

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
      rev = "589213884b9474d570acbcb99ab58dbdec3e4832";
      file = "g/gnumake/glibc-2.28.patch";
      sha256 = "fe5b60d091c33f169740df8cb718bf4259f84528b42435194ffe0dd5b79cd125";
    })
    # Purity: don't look for library dependencies (of the form `-lfoo') in /lib
    # and /usr/lib. It's a stupid feature anyway. Likewise, when searching for
    # included Makefiles, don't look in /usr/include and friends.
    (fetchTritonPatch {
      rev = "6f9e7e9f66f12ecaa55dcae27460b37f1ee40de4";
      file = "gnumake/impure-dirs.patch";
      sha256 = "64efcd56eb445568f2e83d3c4535f645750a3f48ae04999ca4852e263819d416";
    })
  ];

  configureFlags = [
    # Workaround broken autodetection
    "make_cv_sys_gnu_glob=yes"
  ];

  postInstall = ''
    # Nothing should be using the header
    rm -rv "$bin"/include
  '';

  outputs = [
    "bin"
  ] ++ optionals (type == "full") [
    "man"
  ];

  postFixup = ''
    mkdir -p "$bin"/share2
  '' + optionalString (type == "full") ''
    mv "$bin"/share/locale "$bin"/share2
  '' + ''
    rm -rv "$bin"/share
    mv "$bin"/share2 "$bin"/share
  '';


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
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
}
