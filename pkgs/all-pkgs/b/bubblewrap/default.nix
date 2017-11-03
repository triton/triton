{ stdenv
, fetchurl
, lib

, libcap
, libselinux
}:

let
  version = "0.2.0";
in
stdenv.mkDerivation rec {
  name = "bubblewrap-${version}";

  src = fetchurl {
    url = "https://github.com/projectatomic/bubblewrap/releases/download/"
      + "v${version}/${name}.tar.xz";
    sha256 = "ccb61a3718b927765dafd3587c5b619d28c39a3f8b05a4b41e93b2fb2c181c2a";
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
