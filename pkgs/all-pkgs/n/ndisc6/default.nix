{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "ndisc6-1.0.4";
  
  src = fetchurl {
    url = "https://www.remlab.net/files/ndisc6/${name}.tar.bz2";
    multihash = "QmYqLavHVPbYNaXCKvdxmx8WwgMtUZEBCbu2vz4Ge6sgPP";
    hashOutput = false;
    sha256 = "abb1da4a98d94e5abe1dd7b1c975de540306b0581cbbd36aff035118b2f25c1f";
  };

  postPatch = ''
    sed -i '/ch\(mod\|own\)/d' Makefile.in
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "localstatedir=$TMPDIR"
    )
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src) urls outputHash outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "9480 5833 53E3 34D2 F03F  E80C C3EC 6DBE DD6D 12BD";
      };
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
