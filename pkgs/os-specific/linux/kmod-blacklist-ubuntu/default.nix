{ stdenv
, fetchurl

, findutils
, gnugrep
, kmod
}:

let
  version = "22-1.1ubuntu1";
in
stdenv.mkDerivation {
  name = "kmod-blacklist-${version}";

  src = fetchurl {
    url = "https://launchpad.net/ubuntu/+archive/primary/+files/kmod_${version}.debian.tar.xz";
    #allowHashOutput = false;
    sha256 = "117ae90e093f7f8f43fb2ec9cb4e71e1503847b933d74ea8408bb103ce4be4cc";
  };

  installPhase = ''
    file="$out/etc/modprobe.d/ubuntu.conf"
    mkdir -p "$(dirname "$file")"

    for f in modprobe.d/*.conf; do
      echo "''\n''\n## file: "`basename "$f"`"''\n''\n" >> "$file"
      cat "$f" >> "$file"
    done

    sed \
      -e 's,grep,${gnugrep}/bin/grep,g' \
      -e 's,xargs,${findutils}/bin/xargs,g' \
      -e 's,/sbin/lsmod,${kmod}/bin/lsmod,g' \
      -e 's,/sbin/rmmod,${kmod}/bin/rmmod,g' \
      -e 's,/sbin/modprobe,${kmod}/bin/modprobe,g' \
      -i "$file"
  '';

  preferLocalBuild = true;

  meta = with stdenv.lib; {
    homepage = http://packages.ubuntu.com/source/saucy/kmod;
    description = "Linux kernel module blacklists from Ubuntu";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
