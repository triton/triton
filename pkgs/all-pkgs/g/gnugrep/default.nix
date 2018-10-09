{ stdenv
, fetchurl
, pcre
, perl
}:

let
  version = "3.1";

  tarballUrls = version: [
    "mirror://gnu/grep/grep-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "gnugrep-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "db625c7ab3bb3ee757b3926a5cfa8d9e1c3991ad24707a83dde8a5ef2bf7a07e";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    pcre
  ];

  # Fix reference to sh in bootstrap-tools, and invoke grep via
  # absolute path rather than looking at argv[0].
  postInstall = ''
    rm $out/bin/egrep $out/bin/fgrep
    echo "#! /bin/sh" > $out/bin/egrep
    echo "exec $out/bin/grep -E \"\$@\"" >> $out/bin/egrep
    echo "#! /bin/sh" > $out/bin/fgrep
    echo "exec $out/bin/grep -F \"\$@\"" >> $out/bin/fgrep
    chmod +x $out/bin/egrep $out/bin/fgrep
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "3.1";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "155D 3FC5 00C8 3448 6D1E  EA67 7FD9 FCCB 000B EEEE";
      inherit (src) outputHashAlgo;
      outputHash = "db625c7ab3bb3ee757b3926a5cfa8d9e1c3991ad24707a83dde8a5ef2bf7a07e";
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/grep/;
    description = "GNU implementation of the Unix grep command";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
