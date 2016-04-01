{ stdenv, fetchFromGitHub, popt }:

stdenv.mkDerivation rec {
  name = "efivar-${version}";
  version = "0.21";

  src = fetchFromGitHub {
    owner = "rhinstaller";
    repo = "efivar";
    rev = version;
    sha256 = "4c74ef0924fef8c0acb9d60d884d626edf4e27786275f0da4e18e55aef73f7ee";
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
