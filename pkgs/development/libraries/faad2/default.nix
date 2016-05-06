{ stdenv
, fetchurl
, drmSupport ? false # Digital Radio Mondiale
}:

stdenv.mkDerivation rec {
  name = "faad2-2.7";

  src = fetchurl {
    url = "mirror://sourceforge/faac/${name}.tar.bz2";
    sha256 = "1db37ydb6mxhshbayvirm5vz6j361bjim4nkpwjyhmy4ddfinmhl";
  };

  configureFlags = [
    (if drmSupport then "--with-drm" else null)
  ];

  meta = with stdenv.lib; {
    description = "An open source MPEG-4 and MPEG-2 AAC decoder";
    homepage    = http://www.audiocoding.com/faad2.html;
    license     = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms   = with platforms;
      x86_64-linux;
  };
}
