{ stdenv
, fetchgit
, fetchurl
, gettext
}:

let
  date = "2016-07-10";
  gitRev = "115f1af2494ded1fcd21c8419d5e289bc4df380f";
in

stdenv.mkDerivation rec {
  name = "net-tools-${date}";

  src = fetchurl {
    name = "${name}.tar.xz";
    multihash = "QmSDSsjomFu6VZ5szCWGh9hyYQDFRKzFbQRJ1Deafh1cm7";
    sha256 = "fc8ebe223a7144b6cde07eceac3b7ed7e71b350107002a21162542680ddfee2d";
  };

  nativeBuildInputs = [
    gettext
  ];

  postPatch = ''
    patchShebangs configure.sh

    # Force configure to ignore input
    grep -q 'read ans' configure.sh
    sed -i configure.sh \
      -e 's/read ans/true/'

    # FIXME: remove hack when updating
    grep -q '<netinet/ip.h>' iptunnel.c
    sed -i iptunnel.c \
      -e '/<netinet\/ip.h>/d'
  '';

  configurePhase = ''
    set_opt() {
      local opt="$1"
      local ans="$2"
      grep -q "$opt" config.in || {
        echo "invalid netToolsFlag"
        return 1
      }
      sed -i config.in \
        -e "/^bool.* $opt / s:[yn]$:$ans:"
    }

    local -A netToolsFlags=(
      ["I18N"]=y  # gettext
      # Protocols
      ["HAVE_AFIPX"]=n
      ["HAVE_AFATALK"]=n
      ["HAVE_AFAX25"]=n
      ["HAVE_AFNETROM"]=n
      ["HAVE_AFROSE"]=n
      ["HAVE_AFX25"]=n
      ["HAVE_AFECONET"]=n
      ["HAVE_AFDECnet"]=n
      ["HAVE_AFASH"]=n
      ["HAVE_AFBLUETOOTH"]=n
      # Devices
      ["HAVE_HWARC"]=n
      ["HAVE_HWAX25"]=n
      ["HAVE_HWROSE"]=n
      ["HAVE_HWNETROM"]=n
      ["HAVE_HWX25"]=n
      ["HAVE_HWFR"]=n
      ["HAVE_HWASH"]=n
      ["HAVE_HWHDLCLAPB"]=n
      ["HAVE_HWIRDA"]=n
      # Other
      ["HAVE_SELINUX"]=n
    )

    for i in "''${!netToolsFlags[@]}"; do
      set_opt "$i" "''${netToolsFlags["$i"]}"
    done

    ./configure.sh config.in
  '';

  preBuild = ''
    makeFlagsArray+=(
      "BASEDIR=$out"
      "mandir=/share/man"
    )
  '';

  passthru = {
    srcTarball = stdenv.mkDerivation {
      name = "net-tools-tarball-${date}";

      src = fetchgit {
        version = 1;
        url = "http://git.code.sf.net/p/net-tools/code";
        rev = gitRev;
        sha256 = "1f7myyc490nq29dhs45sm2njxwdnck69pm9ixiwgj44mxdmj3rbm";
      };

      buildPhase = ''
        cd ..
        tar Jcfv ${name}.tar.xz $srcRoot
      '';

      installPhase = ''
        mkdir -pv $out
        cp -v ${name}.tar.xz $out
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
