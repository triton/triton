{ stdenv
, fetchurl
}:

let
  version = "3.3";
in
stdenv.mkDerivation rec {
  name = "libffi-${version}";

  src = fetchurl {
    urls = [
      "https://github.com/libffi/libffi/releases/download/v${version}/${name}.tar.gz"
      "mirror://sourceware/libffi/${name}.tar.gz"
    ];
    sha256 = "72fba7922703ddfa7a028d513ac15a85c8d54c8d67f55fa5a4802885dc652056";
  };

  disableStatic = false;

  meta = with stdenv.lib; {
    description = "A foreign function call interface library";
    homepage = http://sourceware.org/libffi/;
    # See http://github.com/atgreen/libffi/blob/master/LICENSE .
    license = licenses.free;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
