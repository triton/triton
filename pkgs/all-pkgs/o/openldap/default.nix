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
  name = "openldap-2.4.47";

  src = fetchurl {
    urls = map (n: "${n}.tgz") (fileUrls name);
    multihash = "Qmf5AeXRaN84o9Q4TMp2vi4qxuJAUUFp99CM5YZV7bauiu";
    hashOutput = false;
    sha256 = "f54c5877865233d9ada77c60c0f69b3e0bfd8b1b55889504c650047cc305520b";
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
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        md5Urls = map (n: "${n}.md5") (fileUrls name);
        sha1Urls = map (n: "${n}.sha1") (fileUrls name);
      };
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
