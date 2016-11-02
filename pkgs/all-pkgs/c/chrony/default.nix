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
  name = "chrony-2.4";

  baseUrls = [
    "https://download.tuxfamily.org/chrony/${name}"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.tar.gz") baseUrls;
    hashOutput = false;
    multihash = "QmSeJ32G6XR57L6hfP5ecytfnPXhHebaAYmMQuRf46eMGY";
    sha256 = "8d04e7cda2333289c2104b731d39c3c1db94816e43bae35d7ee4e7ae8af6391f";
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
