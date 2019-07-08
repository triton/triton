{ stdenv
, fetchurl
, gettext

, bc
, coreutils
, ncurses
, pcre2_lib
, python3
}:

let
  version = "3.0.2";
in
stdenv.mkDerivation rec {
  name = "fish-${version}";

  src = fetchurl {
    url = "https://github.com/fish-shell/fish-shell/releases/download/${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "14728ccc6b8e053d01526ebbd0822ca4eb0235e6487e832ec1d0d22f1395430e";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    ncurses
    pcre2_lib
  ];

  postPatch = ''
    # Hack around building the version file from the git tree
    echo "FISH_BUILD_VERSION = '${version}'" >FISH-BUILD-VERSION-FILE
    sed -i 's,^FISH-BUILD-VERSION-FILE:.*$,FISH-BUILD-VERSION-FILE:,' Makefile.in
  '';

  configureFlags = [
    "--without-included-pcre2"
  ];

  postInstall = ''
    for file in $(find "$out"/share/fish/functions -type f); do
      sed \
        -e 's,\([ (]\|^\)python3\([^a-zA-Z0-9]\|$\),\1${python3.interpreter}\2,' \
        -e 's,\([ (]\|^\)bc\([^a-zA-Z0-9]\|$\),\1${bc}/bin/bc\2,' \
        -e 's,\([ (]\|^\)uname\([^a-zA-Z0-9]\|$\),\1${coreutils}/bin/uname\2,' \
        -i "$file"
    done
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrl = map (n: "${n}.asc") urls;
        pgpKeyFingerprint = "0038 3798 6104 8788 35FA  516D 7A67 D962 D88A 709A ";
      };
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
