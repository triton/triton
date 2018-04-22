{ stdenv
, fetchurl
, cmake
, ninja

, pam
, python2
}:

stdenv.mkDerivation rec {
  name = "pam_wrapper-1.0.6";

  src = fetchurl {
    url = "mirror://samba/cwrap/${name}.tar.gz";
    sha256 = "00a0ea065aa20c50eb54103fc8a62504114b07ebfd2bf0c86bb8be10f612581b";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    pam
    python2
  ];

  meta = with stdenv.lib; {
    description = "a wrapper for the user, group and hosts NSS API";
    homepage = "https://git.samba.org/?p=uid_wrapper.git;a=summary";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
