{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "lzo-2.10";

  src = fetchurl {
    url = "https://www.oberhumer.com/opensource/lzo/download/${name}.tar.gz";
    multihash = "QmR7bLmEDBw5ZnHRPCsYQ9rDV5tLNKRbG9KzGqDzYBYNEE";
    sha256 = "c0f892943208266f9b6543b3ae308fab6284c5c90e627931446fb49b4221a072";
  };

  configureFlags = [
    "--enable-shared"
  ];

  disableStatic = false;

  meta = with stdenv.lib; {
    description = "Real-time data (de)compression library";
    homepage = https://www.oberhumer.com/opensource/lzo;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
