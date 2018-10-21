{ stdenv
, fetchurl

, lzo
, ncurses
, openssl
, readline
, zlib

, channel ? "1.1"
}:

let
  inherit (stdenv.lib)
    optionals
    versionAtLeast;

  sources = {
    "1.0" = {
      version = "1.0.35";
      multihash = "Qma6sTzNcPA1t1qD4ZF74S6GjrCXBvxR7WLDmh3mJPrQEX";
      sha256 = "18c83b147cc3e2133a7ac2543eeb014d52070de01c7474287d3ccecc9b16895e";
    };
    "1.1" = {
      version = "1.1pre16";
      sha256 = "9934c53f8b22bbcbfa0faae0cb7ea13875fe1990cce75af728a7f4ced2c0230b";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "tinc-${source.version}";

  src = fetchurl {
    url = "https://www.tinc-vpn.org/packages/${name}.tar.gz";
    hashOutput = false;
    inherit (source) sha256;
  };

  buildInputs = [
    lzo
    openssl
    zlib
  ] ++ optionals (versionAtLeast channel "1.1") [
    readline
    ncurses
  ];

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "D62B DD16 8EFB E48B C60E  8E23 4A60 84B9 C0D7 1F4A";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "VPN daemon with full mesh routing";
    homepage="http://www.tinc-vpn.org/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
