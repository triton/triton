{ stdenv
, fetchurl

, ncurses
, pam
}:

stdenv.mkDerivation rec {
  name = "screen-4.4.0";

  src = fetchurl {
    url = "mirror://gnu/screen/${name}.tar.gz";
    allowHashOutput = false;
    sha256 = "ef722a54759a3bf23aad272bbf33c414c1078cad6bcd982fada93c0d7917218b";
  };

  buildInputs = [
    ncurses
    pam
  ];

  postPatch = ''
    find . -name Makefile.in | xargs sed -i \
      -e "s|/usr/local|/non-existent|g" \
      -e "s|/usr|/non-existent|g"
  '';

  preConfigure = ''
    configureFlagsArray+=(
      "--infodir=$out/share/info"
      "--mandir=$out/share/man"
    )
  '';

  configureFlags = [
    "--enable-telnet"
    "--enable-pam"
    "--with-sys-screenrc=/etc/screenrc"
    "--enable-colors256"
  ];

  doCheck = true;

  # Some generated headers are not ready when needed
  parallelBuild = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "2EE5 9A5D 0C50 167B 5535  BBF1 B708 A383 C53E F3A4";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/screen/;
    description = "A window manager that multiplexes a physical terminal";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
