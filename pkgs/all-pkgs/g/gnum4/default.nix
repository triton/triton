{ stdenv
, fetchurl

, bootstrap ? false
}:

let
  inherit (stdenv.lib)
    optionalString;

  version = "1.4.18";
in
stdenv.mkDerivation rec {
  name = "${if bootstrap then "bootstrap-" else ""}gnum4-${version}";

  src = fetchurl {
    url = "mirror://gnu/m4/m4-${version}.tar.bz2";
    hashOutput = false;
    sha256 = "6640d76b043bc658139c8903e293d5978309bf0f408107146505eca701e67cf6";
  };

  configureFlags = [
    "--enable-c++"
    "--enable-changeword"
    # We don't want to depend on the bootstrapped shell
    "--with-syscmd-shell=/bin/sh"
  ];

  doCheck = true;

  preFixup = optionalString bootstrap ''
    find "$out" -not -name bin -and -not -name share -mindepth 1 -maxdepth 1 | xargs -r rm -r
  '';

  ccFixFlags = !bootstrap;
  buildDirCheck = !bootstrap;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "AED6 E2A1 85EE B379 F174  76D2 E012 D07A D0E3 CC30";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/m4/;
    description = "GNU M4, a macro processor";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
    ];
    platforms = with platforms;
      x86_64-linux
      ++ i686-linux;
  };
}
