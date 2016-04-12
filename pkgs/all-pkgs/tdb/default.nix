{ stdenv
, docbook_xml_dtd_42
, docbook_xsl
, fetchurl
, libxslt
, python
, samba

, ncurses
, readline
}:

let
  name = "tdb-1.3.9";

  tarballUrls = [
    "mirror://samba/tdb/${name}.tar"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.gz") tarballUrls;
    allowHashOutput = false;
    sha256 = "7101f726e6d5c70f14e577b01c133e2e6059c4455239115e56a12ba64fc084d2";
  };

  nativeBuildInputs = [
    docbook_xml_dtd_42
    docbook_xsl
    libxslt
    python
  ];

  buildInputs = [
    readline
    ncurses
  ];

  postPatch = ''
    patchShebangs buildtools/bin/waf
  '';

  configureFlags = [
    "--bundled-libraries=NONE"
    "--builtin-libraries=replace"
  ];

  passthru = {
    srcVerified = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") tarballUrls;
      pgpDecompress = true;
      inherit (samba.pgp.library) pgpKeyId pgpKeyFingerprint;
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "The trivial database";
    homepage = http://tdb.samba.org/;
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
