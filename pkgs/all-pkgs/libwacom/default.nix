{ stdenv
, fetchurl

, glib
, libgudev
, libxml2
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "libwacom-0.21";

  src = fetchurl {
    url = "mirror://sourceforge/linuxwacom/libwacom/${name}.tar.bz2";
    allowHashOutput = false;
    multihash = "QmUxafdFPXyVstcaLxjJxNRNGoJ7HywBDAfhs7CknYkRed";
    sha256 = "c594cacc69a572356a76cd7909b913d3867759a872a2663b2005ff4e99984605";
  };

  postPatch =
  /* Disable docs */ ''
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
