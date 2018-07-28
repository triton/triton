{ stdenv
, fetchurl

, cryptsetup
, glib
, gpgme
, nss
, nspr
, python3
, util-linux_lib
}:

stdenv.mkDerivation rec {
  name = "volume_key-0.3.11";

  src = fetchurl {
    url = "https://releases.pagure.org/volume_key/${name}.tar.xz";
    multihash = "QmUVdxheid5rjbZ7k7kRszh9T3DsVn4iHPa142rGYKz2b2";
    sha256 = "e6b279c25ae477b555f938db2e41818f90c8cde942b0eec92f70b6c772095f6d";
  };

  buildInputs = [
    cryptsetup
    glib
    gpgme
    nss
    nspr
    python3
    util-linux_lib
  ];

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
