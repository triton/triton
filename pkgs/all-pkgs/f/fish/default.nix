{ stdenv
, fetchurl
, gettext

, ncurses
, pcre2
, python3
}:

let
  version = "2.6.0";
in
stdenv.mkDerivation rec {
  name = "fish-${version}";

  src = fetchurl {
    url = "https://github.com/fish-shell/fish-shell/releases/download/${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "7ee5bbd671c73e5323778982109241685d58a836e52013e18ee5d9f2e638fdfb";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    ncurses
    pcre2
  ];

  configureFlags = [
    "--with-gettext"
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
