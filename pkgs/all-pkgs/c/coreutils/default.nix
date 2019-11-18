{ stdenv
, fetchurl

, acl
, attr
, gmp
, libcap
, libselinux
, libsepol

, type ? "full"
}:

let
  inherit (stdenv.lib)
    optionalString
    optionals;

  tarballUrls = version: [
    "mirror://gnu/coreutils/coreutils-${version}.tar.xz"
  ];

  version = "8.31";
in
stdenv.mkDerivation rec {
  name = "coreutils-${type}-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "ff7a9c918edce6b4f4b2725e3f9b37b0c4d193531cac49a48b56c4d0d3a9e9fd";
  };

  buildInputs = optionals (type == "full") [
    acl
    attr
    gmp
    libcap
    libselinux
    libsepol
  ];

  configureFlags = [
    "--with-linux-crypto"
  ] ++ optionals (type == "small") [
    "--enable-single-binary=symlinks"
  ];

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
      urls = tarballUrls "8.31";
      inherit (src) outputHashAlgo;
      outputHash = "ff7a9c918edce6b4f4b2725e3f9b37b0c4d193531cac49a48b56c4d0d3a9e9fd";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "6C37 DC12 121A 5006 BC1D  B804 DF6F D971 3060 37D9";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "Basic file, shell & text manipulation utilities of the GNU operating system";
    homepage = http://www.gnu.org/software/coreutils/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
    priority = -9;  # This should have a higher priority than everything
  };
}
