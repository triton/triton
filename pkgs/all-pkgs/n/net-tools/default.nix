{ stdenv
, fetchgit
, fetchurl
, gettext
}:

let
  date = "2018-11-03";
  gitRev = "0eebece8c964e3cfa8a018f42b2e7e751a7009a0";
in

stdenv.mkDerivation rec {
  name = "net-tools-${date}";

  src = fetchurl {
    name = "${name}.tar.xz";
    multihash = "QmPkw3Rdbu7ym6RHBt76wKexxfYmZhDh1JEJJ4Pb436aRH";
    sha256 = "fdf1a2f2c2bdf3326d275fccd5cf2ca1bb0349d687fdb37e4efe134277ef1966";
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
        version = 6;
        url = "http://git.code.sf.net/p/net-tools/code";
        rev = gitRev;
        sha256 = "8b9ce2a56f7a457184993bb7dd2230c3b125a89dc11f28e8f18551feb8ee1d8a";
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
