{ stdenv
, fetchurl
, gettext

, ncurses
, pcre2
, python3
}:

let
  version = "2.7.1";
in
stdenv.mkDerivation rec {
  name = "fish-${version}";

  src = fetchurl {
    url = "https://github.com/fish-shell/fish-shell/releases/download/${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "e42bb19c7586356905a58578190be792df960fa81de35effb1ca5a5a981f0c5a";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    ncurses
    pcre2
  ];

  configureFlags = [
    "--without-included-pcre2"
  ];

  preFixup = ''
    sed -i 's,\(^\|[ \t]\)python\([ \t]\|$\),\1${python3}/bin/python3\2,' \
      "$out/share/fish/functions/fish_update_completions.fish"
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpsigUrl = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "0038 3798 6104 8788 35FA  516D 7A67 D962 D88A 709A ";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Smart and user-friendly command line shell";
    homepage = "http://fishshell.com/";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
