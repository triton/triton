{ stdenv
, fetchurl
, groff

, cyrus-sasl
, db
, openssl
}:

let
  fileUrls = name: [
    "http://www.openldap.org/software/download/OpenLDAP/openldap-release/${name}"
  ];
in
stdenv.mkDerivation rec {
  name = "openldap-2.4.45";

  src = fetchurl {
    urls = map (n: "${n}.tgz") (fileUrls name);
    multihash = "QmbXtLhJfjNe3QeQb5pzL9BqSEbKgk9Azvfw6YXePH7Ns7";
    hashOutput = false;
    sha256 = "cdd6cffdebcd95161a73305ec13fc7a78e9707b46ca9f84fb897cd5626df3824";
  };

  nativeBuildInputs = [
    groff
  ];

  buildInputs = [
    cyrus-sasl
    db
    openssl
  ];

  # Prevent hostname / user / build directory impurities
  postPatch = ''
    sed -i '/^WHOWHERE=/s,=.*,="nix@localhost:/no-such-path",' build/mkversion
  '';

  configureFlags = [
    "--enable-overlays"
    "--disable-dependency-tracking"   # speeds up one-time build
    "--with-pic"
    "--with-tls"
    "--with-cyrus-sasl"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      md5Urls = map (n: "${n}.md5") (fileUrls name);
      sha1Urls = map (n: "${n}.sha1") (fileUrls name);
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.openldap.org/;
    description = "An open source implementation of the Lightweight Directory Access Protocol";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
