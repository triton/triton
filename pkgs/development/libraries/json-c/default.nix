{ stdenv
, autoconf
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "json-c-0.12";
  src = fetchurl {
    url    = "https://s3.amazonaws.com/json-c_releases/releases/${name}-nodoc.tar.gz";
    sha256 = "0dgvjjyb9xva63l6sy70sdch2w4ryvacdmfd3fg2f2v13lqx5mkg";
  };

  nativeBuildInputs = [
    autoconf
  ];

  patches = [
    ./unused-variable.patch
  ];

  # compatibility hack (for mypaint at least)
  postInstall = ''
    ln -sv json-c.pc "$out/lib/pkgconfig/json.pc"
  '';

  meta = with stdenv.lib; {
    description = "A JSON implementation in C";
    homepage = https://github.com/json-c/json-c/wiki;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
