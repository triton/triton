{ stdenv
, fetchurl
}:

let
  version = "1.3.2";
in
stdenv.mkDerivation rec {
  name = "libmaxminddb-${version}";

  src = fetchurl {
    url = "https://github.com/maxmind/libmaxminddb/releases/download/${version}/${name}.tar.gz";
    sha256 = "e6f881aa6bd8cfa154a44d965450620df1f714c6dc9dd9971ad98f6e04f6c0f0";
  };

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--disable-tests"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
