{ stdenv
, fetchurl

, glib
, libgudev
, libxml2
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "libwacom-0.32";

  src = fetchurl {
    url = "https://github.com/linuxwacom/libwacom/releases/download/${name}/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "6b9dab8bce0471b839c89d34a1b30839de2c24db03796fa8d572817830f85380";
  };

  postPatch = /* Disable docs */ ''
    sed -i Makefile.in \
      -e 's:^\(SUBDIRS = .* \)doc:\1:'
  '';

  buildInputs = [
    glib
    libgudev
    libxml2
    systemd_lib
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "3C2C 43D9 447D 5938 EF45  51EB E23B 7E70 B467 F0BF";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "Library for identifying Wacom tablets and features";
    homepage = http://sourceforge.net/projects/linuxwacom/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };

}
