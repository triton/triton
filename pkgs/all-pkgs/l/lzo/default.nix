{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "lzo-2.09";

  src = fetchurl {
    url = "${meta.homepage}/download/${name}.tar.gz";
    sha256 = "0k5kpj3jnsjfxqqkblpfpx0mqcy86zs5fhjhgh2kq1hksg7ag57j";
  };

  configureFlags = [
    "--enable-shared"
  ];

  dontDisableStatic = true;

  meta = with stdenv.lib; {
    description = "Real-time data (de)compression library";
    homepage = http://www.oberhumer.com/opensource/lzo;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
