{ stdenv
, fetchurl
, lib

, libcap
, libselinux
}:

let
  version = "0.3.1";
in
stdenv.mkDerivation rec {
  name = "bubblewrap-${version}";

  src = fetchurl {
    url = "https://github.com/projectatomic/bubblewrap/releases/download/"
      + "v${version}/${name}.tar.xz";
    sha256 = "deca6b608c54df4be0669b8bb6d254858924588e9f86e116eb04656a3b6d4bf8";
  };

  buildInputs = [
    libcap
    libselinux
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-man"
    "--enable-selinux"
    "--disable-sudo"
    #"--enable-require-userns=yes"
    "--with-priv-mode=none"
  ];

  meta = with lib; {
    description = "Unprivileged sandboxing tool";
    homepage = https://github.com/projectatomic/bubblewrap;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
