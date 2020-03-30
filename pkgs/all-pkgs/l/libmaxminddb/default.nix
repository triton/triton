{ stdenv
, fetchurl
}:

let
  version = "1.4.2";
in
stdenv.mkDerivation rec {
  name = "libmaxminddb-${version}";

  src = fetchurl {
    url = "https://github.com/maxmind/libmaxminddb/releases/download/${version}/${name}.tar.gz";
    sha256 = "dd582aa971be23dee960ec33c67fb5fd38affba508e6f00ea75959dbd5aad156";
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
