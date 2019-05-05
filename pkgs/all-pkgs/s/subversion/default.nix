{ stdenv
, fetchurl

, apr
, apr-util
, cyrus-sasl
, db
, expat
, file
, lz4
, serf
, sqlite
, utf8proc
, zlib
}:

let
  version = "1.12.0";
in
stdenv.mkDerivation rec {
  name = "subversion-${version}";

  src = fetchurl {
    url = "mirror://apache/subversion/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "7fae7c73d8a007c107c0ae5eb372bc0bb013dbfe966fcd5c59cd5a195a5e2edf";
  };

  buildInputs = [
    apr
    apr-util
    cyrus-sasl
    db
    expat
    file
    lz4
    serf
    sqlite
    utf8proc
    zlib
  ];

  configureFlags = [
    "--enable-optimize"
    "--enable-svnxx"
  ];

  installParallel = false;

  preFixup = ''
    rm -r "$out"/lib/*.la
    rm -r "$out"/share/pkgconfig
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprints = [
          "E7B2 A7F4 EC28 BE9F F8B3  8BA4 B64F FF12 09F9 FA74"
          "056F 8016 D9B8 7B1B DE41  7467 99EC 741B 5792 1ACC"
          "BA3C 15B1 337C F0FB 222B  D41A 1BCA 6586 A347 943F"
          "8BC4 DAE0 C5A4 D65F 4044  0107 4F7D BAA9 9A59 B973"
          "A844 790F B574 3606 EE95  9207 76D7 88E1 ED1A 599C"
          "3D1D C66D 6D2E 0B90 3952  8138 C4A6 C625 CCC8 E1DF"
          "7B8C A7F6 451A D89C 8ADC  077B 376A 3CFD 110B 1C95"
          "6011 63CF 9D49 9FD7 18CF  582D 1FB0 64B8 4EEC C493"
          "E966 46BE 08C0 AF0A A0F9  0788 A5FE EE3A C793 7444"
        ];
      };
    };
  };

  meta = with stdenv.lib; {
    description = "A version control system intended to be a compelling replacement for CVS in the open source community";
    homepage = http://subversion.apache.org/;
    maintainers = with maintainers; [
      wkennington
    ];
    plaforms = with platforms;
      x86_64-linux;
  };
}
