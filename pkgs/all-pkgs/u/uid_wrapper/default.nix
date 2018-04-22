{ stdenv
, cmake
, fetchurl
, ninja
}:

stdenv.mkDerivation rec {
  name = "uid_wrapper-1.2.4";

  src = fetchurl {
    url = "mirror://samba/cwrap/${name}.tar.gz";
    sha256 = "3c60f65371420074ef437796a36beef2d713c28bd5c5fbf29c3e7a9647cd50fa";
  };

  nativeBuildInputs = [
    cmake
    ninja
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
