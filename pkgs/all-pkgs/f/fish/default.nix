{ stdenv
, fetchurl
, gettext

, ncurses
, pcre2
, python
, which
}:

let
  version = "2.5.0";
in
stdenv.mkDerivation rec {
  name = "fish-${version}";

  src = fetchurl {
    url = "https://github.com/fish-shell/fish-shell/releases/download/${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "f8c0edadca2de379ccf305aeace660a9255fa2180c72e85e97705a24c256b2a5";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    ncurses
    pcre2
  ];

  postPatch = ''
    sed -i 'share/functions/_.fish' \
      -e 's,gettext ,${gettext}/bin/gettext ,g' \
      -e 's,which ,${which}/bin/which ,'
  '';

  configureFlags = [
    "--with-gettext"
    "--without-included-pcre2"
  ];

  preFixup = ''
    sed -i 's,\(^\|[ \t]\)python\([ \t]\|$\),\1${python}/bin/python\2,' "$out/share/fish/functions/fish_update_completions.fish"
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
