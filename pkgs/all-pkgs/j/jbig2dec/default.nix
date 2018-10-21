{ stdenv
, fetchurl
}:

let
  gsver = "gs924";
  version = "0.15";

  baseUrl = "https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/"
    + "download/${gsver}";
in
stdenv.mkDerivation rec {
  name = "jbig2dec-${version}";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "6bfa1af72de37c7929315933a1ba696540d860936ad98f9de02fc725d7e53854";
  };

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
