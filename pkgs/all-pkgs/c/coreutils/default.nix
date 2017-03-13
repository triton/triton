{ stdenv
, fetchurl
, perl

, acl
, gmp
, selinuxSupport? false
  , libselinux
  , libsepol
}:

let
  inherit (stdenv.lib)
    optionals;

  tarballUrls = version: [
    "mirror://gnu/coreutils/coreutils-${version}.tar.xz"
  ];

  version = "8.27";
in
stdenv.mkDerivation rec {
  name = "coreutils-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "8891d349ee87b9ff7870f52b6d9312a9db672d2439d289bc57084771ca21656b";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    acl
    gmp
  ] ++ optionals selinuxSupport [
    libselinux
    libsepol
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "8.27";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "6C37 DC12 121A 5006 BC1D  B804 DF6F D971 3060 37D9";
      inherit (src) outputHashAlgo;
      outputHash = "8891d349ee87b9ff7870f52b6d9312a9db672d2439d289bc57084771ca21656b";
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
