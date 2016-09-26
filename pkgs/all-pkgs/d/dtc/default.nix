{ stdenv
, bison
, fetchgit
, flex
}:

stdenv.mkDerivation rec {
  name = "dtc-${version}";
  version = "1.4.1";

  src = fetchgit {
    version = 1;
    url = "git://git.kernel.org/pub/scm/utils/dtc/dtc.git";
    rev = "refs/tags/v${version}";
    sha256 = "0nkh1rwfsm7yvk5pqlis00a7sxag8y29r3zg1w87hkw7a5pv97gq";
  };

  nativeBuildInputs = [
    flex
    bison
  ];

  installFlags = [
    "INSTALL=install"
    "PREFIX=$(out)"
  ];

  meta = with stdenv.lib; {
    description = "Device Tree Compiler";
    homepage = https://git.kernel.org/cgit/utils/dtc/dtc.git;
    license = licenses.gpl2; # dtc itself is GPLv2, libfdt is dual GPL/BSD
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
