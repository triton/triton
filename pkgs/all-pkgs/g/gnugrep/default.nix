{ stdenv
, fetchurl
, fetchTritonPatch
, pcre

, type ? "full"
}:

let
  inherit (stdenv.lib)
    optionalString
    optionals;

  version = "3.4";

  tarballUrls = version: [
    "mirror://gnu/grep/grep-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "gnugrep-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "58e6751c41a7c25bfc6e9363a41786cff3ba5709cf11d5ad903cf7cce31cc3fb";
  };

  buildInputs = [
    pcre
  ];

  patches = [
    (fetchTritonPatch {
      rev = "ea2f05440159d91d94027aca8adc4c43b62fe8f1";
      file = "g/gnugrep/0001-grep-Interpret-argv0-for-the-default-matcher.patch";
      sha256 = "86ef1a8ca3869f926abd5626d03ba3a752aae6c4d2ee1682b5674cb4cd4da4d0";
    })
  ];

  # Our grep understands argv0
  postInstall = ''
    rm "$bin"/bin/egrep "$bin"/bin/fgrep
    ln -sv grep "$bin"/bin/fgrep
    ln -sv grep "$bin"/bin/egrep
  '';

  postFixup = ''
    mkdir -p "$bin"/share2
  '' + optionalString (type == "full") ''
    mv "$bin"/share/locale "$bin"/share2
  '' + ''
    rm -rv "$bin"/share
    mv "$bin"/share2 "$bin"/share
  '';

  outputs = [
    "bin"
  ] ++ optionals (type == "full") [
    "man"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "3.4";
      inherit (src) outputHashAlgo;
      outputHash = "58e6751c41a7c25bfc6e9363a41786cff3ba5709cf11d5ad903cf7cce31cc3fb";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "155D 3FC5 00C8 3448 6D1E  EA67 7FD9 FCCB 000B EEEE";
      };
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
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
}
