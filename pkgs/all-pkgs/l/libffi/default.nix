{ stdenv
, fetchurl
}:

let
  version = "3.3-rc0";
in
stdenv.mkDerivation rec {
  name = "libffi-${version}";

  src = fetchurl {
    urls = [
      "https://github.com/libffi/libffi/releases/download/v${version}/${name}.tar.gz"
      "mirror://sourceware/libffi/${name}.tar.gz"
    ];
    sha256 = "403d67aabf1c05157855ea2b1d9950263fb6316536c8c333f5b9ab1eb2f20ecf";
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
