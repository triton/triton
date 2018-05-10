{ stdenv
, cmake
, fetchFromGitHub
, ninja

, curl
, krb5_lib
, openssl
, zlib
}:

let
  rev = "1fe8a067f95c86596261b2049a0b68c003877d08";
  date = "2018-05-09";
in
stdenv.mkDerivation rec {
  name = "mariadb-connector-c-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "MariaDB";
    repo = "mariadb-connector-c";
    inherit rev;
    sha256 = "0e23b68fc623679894d72b6d95ed38ab293b8e64968930047f41b4392ddcde64";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    curl
    krb5_lib
    openssl
    zlib
  ];

  cmakeFlags = [
    "-DINSTALL_LIBDIR=lib"
    "-DWITH_MYSQLCOMPAT=ON"
    "-DWITH_UNITTEST=OFF"
    "-DWITH_EXTERNAL_ZLIB=ON"
  ];

  # Hack to make sure we include the libpath in the _config binaries
  preBuild = ''
    sed \
      -e 's,-lz,-L${zlib}/lib -lz,g' \
      -e 's,-lssl,-L${openssl}/lib -lssl,g' \
      -i mariadb_config/mariadb_config.c
  '';

  postInstall = ''
    ln -sv mariadb_config "$out"/bin/mysql_config
    ln -sv mariadb "$out"/include/mysql
  '';

  # Make sure we have all the needed lib paths
  preFixupCheck = ''
    echo 'void main() {}' | NIX_LDFLAGS= gcc -x c -o main - $("$out"/bin/mariadb_config --libs)
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
