{ stdenv
, lib
, fetchurl
, python2Packages
}:

stdenv.mkDerivation rec {
  name = "libplist-2.0.0";

  src = fetchurl {
    url = "http://www.libimobiledevice.org/downloads/${name}.tar.bz2";
    multihash = "QmRZ7HWGassyQJv3YWmmYEiYuxarL7sEnaK9cGeJxjDZ8a";
    sha256 = "3a7e9694c2d9a85174ba1fa92417cfabaea7f6d19631e544948dc7e17e82f602";
  };

  nativeBuildInputs = [
    python2Packages.cython
    python2Packages.python
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
