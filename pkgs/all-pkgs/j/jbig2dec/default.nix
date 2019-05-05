{ stdenv
, autoconf
, fetchurl
}:

let
  gsver = "gs927";
  version = "0.16";

  baseUrl = "https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/"
    + "download/${gsver}";
in
stdenv.mkDerivation rec {
  name = "jbig2dec-${version}";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "a4f6bf15d217e7816aa61b92971597c801e81f0a63f9fe1daee60fb88e0f0602";
  };

  nativeBuildInputs = [
    # Shouldn't be needed but 0.16 must be broken
    autoconf
  ];

  # Fix the lack of memento.h
  postInstall = ''
    ! test -e "$out"/include/memento.h
    cp memento.h "$out"/include
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        md5Url = "${baseUrl}/MD5SUMS";
        sha512Url = "${baseUrl}/SHA512SUMS";
      };
    };
  };

  meta = with stdenv.lib; {
    homepage = http://jbig2dec.sourceforge.net/;
    description = "Decoder implementation of the JBIG2 image compression format";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
