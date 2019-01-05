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
    optionals
    optionalString;

  tarballUrls = version: [
    "mirror://gnu/coreutils/coreutils-${version}.tar.xz"
  ];

  version = "8.30";
in
stdenv.mkDerivation rec {
  name = "coreutils-${type}-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "e831b3a86091496cdba720411f9748de81507798f6130adeaef872d206e1b057";
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

  postInstall = optionalString (type == "small") ''
    rm -r "$out"/share
  '';

  allowedReferences = [
    "out"
  ] ++ stdenv.cc.runtimeLibcLibs
    ++ optionals (type == "full") [
    acl
    attr
    gmp
    libcap
    libselinux
    libsepol
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "8.30";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "6C37 DC12 121A 5006 BC1D  B804 DF6F D971 3060 37D9";
      inherit (src) outputHashAlgo;
      outputHash = "e831b3a86091496cdba720411f9748de81507798f6130adeaef872d206e1b057";
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
      i686-linux
      ++ x86_64-linux;
    priority = -9;  # This should have a higher priority than everything
  };
}
