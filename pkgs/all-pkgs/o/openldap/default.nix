{ stdenv
, fetchurl
, groff

, cyrus-sasl
, db
, icu
, openssl
}:

let
  fileUrls = name: [
    "https://www.openldap.org/software/download/OpenLDAP/openldap-release/${name}"
  ];
in
stdenv.mkDerivation rec {
  name = "openldap-2.4.50";

  src = fetchurl {
    urls = map (n: "${n}.tgz") (fileUrls name);
    multihash = "QmcX3EAj5NvipCTafRAr2xso98XWvz5o8yqkjD1jyL7Hgw";
    hashOutput = false;
    sha256 = "5cb57d958bf5c55a678c6a0f06821e0e5504d5a92e6a33240841fbca1db586b8";
  };

  nativeBuildInputs = [
    groff
  ];

  buildInputs = [
    cyrus-sasl
    db
    icu
    openssl
  ];

  # Prevent hostname / user / build directory impurities
  postPatch = ''
    sed -i '/^WHOWHERE=/s,=.*,="nix@localhost:/no-such-path",' build/mkversion
  '';

  configureFlags = [
    "--enable-overlays"
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
