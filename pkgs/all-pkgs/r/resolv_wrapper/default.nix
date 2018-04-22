{ stdenv
, fetchurl
, cmake
, ninja
}:

stdenv.mkDerivation rec {
  name = "resolv_wrapper-1.1.5";

  src = fetchurl {
    url = "mirror://samba/cwrap/${name}.tar.gz";
    sha256 = "e989fdaa1385bdf3ef7dbcb83b3f7f15c69e78ca6432e254be390b7c63e1b06c";
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
