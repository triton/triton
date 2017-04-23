{ stdenv
, fetchurl
, python2

, cryptsetup
, glib
, gnupg
, gpgme
, nss
, nspr
, util-linux_lib
}:

stdenv.mkDerivation rec {
  name = "volume_key-0.3.9";

  src = fetchurl {
    url = "https://releases.pagure.org/volume_key/${name}.tar.xz";
    multihash = "QmVUT6fW9bLZqFu1X2En8kpof9z2Ga9zN5ZZmfaemA2Dai";
    sha256 = "450a54fe9bf56acec6850c1e71371d3e4913c9ca1ef0cdc3a517b4b6910412a6";
  };

  nativeBuildInputs = [
    python2
  ];

  buildInputs = [
    cryptsetup
    glib
    gnupg
    gpgme
    nss
    nspr
    util-linux_lib
  ];

  postPatch = ''
    grep -q '#include <config.h>' lib/libvolume_key.h
    sed -i '/#include <config.h>/d' lib/libvolume_key.h
  '';

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I$(find "$(dirname "$(type -tP python)")"/.. -name Python.h -exec dirname {} \;)"
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
