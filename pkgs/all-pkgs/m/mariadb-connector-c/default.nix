{ stdenv
, cmake
, fetchFromGitHub
, ninja

, curl
, krb5_lib
, openssl
, sqlite
, zlib
}:

let
  rev = "5d920a972a1e18ab686b781895d993d6a1aae7fc";
  date = "2017-10-26";
in
stdenv.mkDerivation rec {
  name = "mariadb-connector-c-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "MariaDB";
    repo = "mariadb-connector-c";
    inherit rev;
    sha256 = "6cfaf2516d3a4c9b3a54c0bec4e6134324d7d502828e2615209ea904aaab8b0b";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    curl
    krb5_lib
    openssl
    sqlite
    zlib
  ];

  cmakeFlags = [
    "-DINSTALL_LIBDIR=lib"
    "-DWITH_MYSQLCOMPAT=ON"
    "-DWITH_UNITTEST=OFF"
    "-DWITH_EXTERNAL_ZLIB=ON"
    "-DWITH_SQLITE=ON"
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
