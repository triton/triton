{ stdenv
, fetchurl
, pcre
, perl
}:

let
  version = "3.0";

  tarballUrls = version: [
    "mirror://gnu/grep/grep-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "gnugrep-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "e2c81db5056e3e8c5995f0bb5d0d0e1cad1f6f45c3b2fc77b6e81435aed48ab5";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    pcre
  ];

  doCheck = true;

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
      urls = tarballUrls "3.0";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "155D 3FC5 00C8 3448 6D1E  EA67 7FD9 FCCB 000B EEEE";
      inherit (src) outputHashAlgo;
      outputHash = "e2c81db5056e3e8c5995f0bb5d0d0e1cad1f6f45c3b2fc77b6e81435aed48ab5";
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
