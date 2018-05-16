{ stdenv
, fetchFromGitHub
}:

let
  version = "0.9.7";
in
stdenv.mkDerivation rec {
  name = "libfaketime-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "wolfcw";
    repo = "libfaketime";
    rev = "v${version}";
    sha256 = "ecba09840e254f8b9a884c32ac6ddd23591db23d98c09463941a93dccfc6c004";
  };

  preBuild = ''
    grep -q '\-Werror' src/Makefile
    sed -i 's,-Werror,,g' src/Makefile

    makeFlagsArray+=(
      "PREFIX=$out"
      "LIBDIRNAME=/lib"
    )
  '';

  meta = with stdenv.lib; {
    description = "Report faked system time to programs without having to change the system-wide time";
    homepage = http://www.code-wizards.com/projects/libfaketime/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
