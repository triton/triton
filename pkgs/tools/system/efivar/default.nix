{ stdenv, fetchFromGitHub, popt }:

stdenv.mkDerivation rec {
  name = "efivar-${version}";
  version = "0.21";

  src = fetchFromGitHub {
    owner = "rhinstaller";
    repo = "efivar";
    rev = version;
    sha256 = "9f49e3b9ad7641a38190f632d044e1cdc916e6a9bdb08a28f655ac1f7961dcb6";
  };

  buildInputs = [ popt ];

  # 0.21 Has build warnings so disable -Werror
  postPatch = ''
    sed -i 's,-Werror,,g' Make.defaults
  '';

  installFlags = [
    "libdir=$(out)/lib"
    "mandir=$(out)/share/man"
    "includedir=$(out)/include"
    "bindir=$(out)/bin"
  ];

  meta = with stdenv.lib; {
    homepage = http://github.com/vathpela/efivar;
    description = "Tools and library to manipulate EFI variables";
    platforms = platforms.linux;
    license = licenses.lgpl21;
  };
}
