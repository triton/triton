{ stdenv
, fetchurl

, libcap
, libseccomp
, ncurses
, nspr
, nss
, readline
}:

let
  name = "chrony-3.4";

  baseUrls = [
    "https://download.tuxfamily.org/chrony/${name}"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.tar.gz") baseUrls;
    multihash = "Qmev3vcNHk4yB4dy2YDhy3fngP8KsiCXDVbKVuubzuRwmX";
    hashOutput = false;
    sha256 = "af77e47c2610a7e55c8af5b89a8aeff52d9a867dd5983d848b52d374bc0e6b9f";
  };
  
  buildInputs = [
    libcap
    libseccomp
    ncurses
    nspr
    nss
    readline
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-scfilter"
    "--with-sendmail=/run/current-system/sw/bin/sendmail"
  ];

  preInstall = ''
    installFlagsArray+=(
      "CHRONYVARDIR=$TMPDIR"
    )
  '';

  # Fix impurities in man pages
  preFixup = ''
    sed -i "s,$NIX_BUILD_TOP,/no-such-path,g" $out/share/man/man5/chrony.conf.5
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}-tar-gz-asc.txt") baseUrls;
        pgpKeyFingerprint = "8B1F 4A9A DA73 D401 E308  5A0B 5FF0 6F29 BA1E 013B";
      };
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
