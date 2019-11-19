{ stdenv
, fetchurl
, autoreconfHook

, popt
}:

stdenv.mkDerivation rec {
  name = "libnatspec-0.3.0";

  src = fetchurl {
    url = "mirror://sourceforge/natspec/${name}.tar.bz2";
    multihash = "QmSXzeYey2FjPs5NYsXvWiz3xGUamPyWwFerhshqiEYJJn";
    sha256 = "0wffxjlc8svilwmrcg3crddpfrpv35mzzjgchf8ygqsvwbrbb3b7";
  };

  #nativeBuildInputs = [
  #  autoreconfHook
  #];

  buildInputs = [
    popt
  ];

  meta = with stdenv.lib; {
    homepage = http://natspec.sourceforge.net/ ;
    description = "A library intended to smooth national specificities in using of programs";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      powerpc64le-linux
      ++ x86_64-linux;
  };
}
