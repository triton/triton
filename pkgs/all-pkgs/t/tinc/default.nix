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
      version = "1.1pre17";
      multihash = "QmQA2SwSAs41EkBvJwaq3KYpeoiPTSzK9mubo1yMBymLhZ";
      sha256 = "61b9c9f9f396768551f39216edcc41918c65909ffd9af071feb3b5f9f9ac1c27";
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
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "D62B DD16 8EFB E48B C60E  8E23 4A60 84B9 C0D7 1F4A";
      };
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
