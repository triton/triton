{ stdenv
, fetchurl
, groff

, cyrus-sasl
, db
, openssl
}:

let
  fileUrls = name: [
    "https://www.openldap.org/software/download/OpenLDAP/openldap-release/${name}"
  ];
in
stdenv.mkDerivation rec {
  name = "openldap-2.4.46";

  src = fetchurl {
    urls = map (n: "${n}.tgz") (fileUrls name);
    multihash = "Qmd89FnzzUsPf9xBwfxfHpnpcPjWPeJuuZ8oz5qR1mLsoV";
    hashOutput = false;
    sha256 = "9a90dcb86b99ae790ccab93b7585a31fbcbeec8c94bf0f7ab0ca0a87ea0c4b2d";
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

  postInstall = ''
    # Fix the installation of so files
    for so in $(find "$out"/lib -name \*.so\*); do
      if [ -f "$so" ]; then
        chmod +x "$so"
      fi
    done
  '';

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
