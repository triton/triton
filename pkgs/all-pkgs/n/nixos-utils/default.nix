{ stdenv
}:

let
  ids = (import ../../../../nixos/modules/misc/ids.nix) {
    inherit (stdenv) lib;
  };
in
stdenv.mkDerivation {
  name = "nixos-utils";

  buildCommand = ''
    set -x
    sed ${./nss.c.in} \
      -e "s,@BASE_UID@,${toString ids.config.ids.uids.nixbld},g" \
      -e "s,@BASE_GID@,${toString ids.config.ids.gids.nixbld},g" \
      > nss.c
    gcc -shared -fPIC -Wall -Werror -O2 -o libnss_nixos.so.2 nss.c
    mkdir -p "$out"/lib
    mv libnss_nixos.so.2 "$out"/lib
    set +x
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
