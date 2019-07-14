{ stdenv
, base_uid ? null
, base_gid ? null
}:

let
  ids = (import ../../../../nixos/modules/misc/ids.nix) {
    inherit (stdenv) lib;
  };

  base_uid' = if base_uid != null then base_uid else ids.config.ids.uids.nixbld;
  base_gid' = if base_gid != null then base_gid else ids.config.ids.gids.nixbld;
in
stdenv.mkDerivation {
  name = "nixos-utils";

  buildCommand = ''
    set -x
    sed ${./nss.c.in} \
      -e "s,@BASE_UID@,${toString base_uid'},g" \
      -e "s,@BASE_GID@,${toString base_gid'},g" \
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
