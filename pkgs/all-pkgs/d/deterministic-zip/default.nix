{ stdenv
, lib

, brotli_0-4-0
, brotli_0-5-2
, brotli_0-6-0
, brotli_1-0-2
, brotli_1-0-3
, gnutar_1-29
, gnutar_1-30

, version ? 6
}:

let
  versions = {
    "1" = {
      brotli = brotli_0-4-0;
      tar = gnutar_1-29;
    };
    "2" = {
      brotli = brotli_0-5-2;
      tar = gnutar_1-29;
    };
    "3" = {
      brotli = brotli_0-6-0;
      tar = gnutar_1-29;
    };
    "5" = {
      brotli = brotli_1-0-2;
      tar = gnutar_1-30;
    };
    "6" = {
      brotli = brotli_1-0-3;
      tar = gnutar_1-30;
    };
  };

  inherit (versions."${toString version}")
    brotli
    tar;

  brotliFlags =
    if lib.versionAtLeast brotli.version "1.0.0" then
      [ "-6" "-c" ]
    else
      [ "--quality" "6" ];

  cmd = ''
    ${tar}/bin/tar \
      --sort=name --owner=0 --group=0 --numeric-owner \
      --no-acls --no-selinux --no-xattrs \
      --mode=go=rX,u+rw,a-s \
      --clamp-mtime --mtime=@"''${SOURCE_DATE_EPOCH:-1}" \
      -c "$@" | ${brotli}/bin/brotli ${lib.concatStringsSep " " brotliFlags}
  '';
in
stdenv.mkDerivation {
  name = "deterministic-zip-${toString version}";

  buildCommand = ''
    mkdir -p "$out"/bin
    echo '#! ${stdenv.shell} -e' >>"$out"/bin/deterministic-zip-${toString version}
    echo '${cmd}' >>"$out"/bin/deterministic-zip-${toString version}
    chmod +x "$out"/bin/deterministic-zip-${toString version}
    ln -sv deterministic-zip-${toString version} "$out"/bin/deterministic-zip
  '';

  passthru = {
    inherit
      brotli
      tar
      version;
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    priority = -version;
  };
}
