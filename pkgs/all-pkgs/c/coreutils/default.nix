{ stdenv
, fetchurl

, acl
, attr
, gmp
, libcap
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

  version = "8.29";
in
stdenv.mkDerivation rec {
  name = "coreutils-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "92d0fa1c311cacefa89853bdb53c62f4110cdfda3820346b59cbd098f40f955e";
  };

  buildInputs = [
    acl
    attr
    gmp
    libcap
  ] ++ optionals selinuxSupport [
    libselinux
    libsepol
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "8.29";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "6C37 DC12 121A 5006 BC1D  B804 DF6F D971 3060 37D9";
      inherit (src) outputHashAlgo;
      outputHash = "92d0fa1c311cacefa89853bdb53c62f4110cdfda3820346b59cbd098f40f955e";
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
