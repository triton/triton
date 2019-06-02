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
  name = "chrony-3.5";

  baseUrls = [
    "https://download.tuxfamily.org/chrony/${name}"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.tar.gz") baseUrls;
    multihash = "QmXHSLpvexGJSGi9ZMFr1WjuRe5ohnbxxZ1G9PeDN46tc1";
    hashOutput = false;
    sha256 = "4e02795b1260a4ec51e6ace84149036305cc9fc340e65edb9f8452aa611339b5";
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
