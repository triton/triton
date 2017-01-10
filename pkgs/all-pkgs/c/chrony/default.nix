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
  name = "chrony-2.4.1";

  baseUrls = [
    "https://download.tuxfamily.org/chrony/${name}"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.tar.gz") baseUrls;
    hashOutput = false;
    multihash = "QmNbsFUpDxzwRqhKZoozsccYR5aG9YyzSPCxu1APcUMHJ2";
    sha256 = "0fd59e0ef625b4459e3a9c7f221c52f56596582bce31abfae5f7369702edb6e0";
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
      pgpsigUrls = map (n: "${n}-tar-gz-asc.txt") baseUrls;
      pgpKeyFingerprint = "8B1F 4A9A DA73 D401 E308  5A0B 5FF0 6F29 BA1E 013B";
      inherit (src) urls outputHash outputHashAlgo;
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
