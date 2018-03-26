{ stdenv
, fetchurl

, glib
, libgudev
, libxml2
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "libwacom-0.29";

  src = fetchurl {
    url = "mirror://sourceforge/linuxwacom/libwacom/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "9cea00e68ddf342c3f749f6628d33fd3646f1937d7c57053ec6c5728d9a333b6";
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
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "3C2C 43D9 447D 5938 EF45  51EB E23B 7E70 B467 F0BF";
      inherit (src) urls outputHash outputHashAlgo;
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
