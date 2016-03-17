{ stdenv
, fetchurl
, fetchgit
, gettext
}:

let
  date = "2016-02-15";
  gitRev = "bd8bceaed2311651710331a7f8990c3e31be9840";
in
stdenv.mkDerivation rec {
  name = "net-tools-${date}";

  src = fetchurl {
    name = "${name}.tar.xz";
    multihash = "QmQo77UM6kGXvznbkDFYcDeJZV2aLLUzcw8zGiPepRSrZZ";
    sha256 = "ff6f8986a56cdab0f012084def538357fba117ad81660ed6f7130f6c48b8e963";
  };

  nativeBuildInputs = [
    gettext
  ];

  preBuild = ''
    cp ${./config.h} config.h
    cp ${./config.make} config.make
    makeFlagsArray+=(
      "BASEDIR=$out"
      "mandir=/share/man"
    )
  '';

  passthru = {
    sourceTarball = stdenv.mkDerivation rec {
      name = "net-tools-tarball-${date}";

      src = fetchgit {
        url = "http://git.code.sf.net/p/net-tools/code";
        rev = gitRev;
        sha256 = "1h8iryf5qc4svyz2ri1v4a8117w4r79rw6iqn8n7qavg0w45b30k";
      };

      buildPhase = ''
        cp -r ${src} ${name}
        tar Jcf ${name}.tar.xz ${name}
      '';

      installPhase = ''
        mkdir -p $out
        cp ${name}.tar.xz $out
      '';
    };
  };

  meta = with stdenv.lib; {
    description = "Tools for controlling the network subsystem in Linux";
    homepage = http://net-tools.sourceforge.net/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
