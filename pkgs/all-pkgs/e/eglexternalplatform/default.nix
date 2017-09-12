{ stdenv
, fetchFromGitHub
, lib
}:

let
  versionr = "2017-01-17";
in
stdenv.mkDerivation rec {
  name = "eglexternalplatform-${versionr}";

  src = fetchFromGitHub {
    version = 3;
    owner = "NVIDIA";
    repo = "eglexternalplatform";
    rev = "76e29488ca3a34e5ef58a4c83d8cd857b621de2a";
    sha256 = "b36fecd578b9e7868b1db47391f9a3656ec822b992896cf8822406c171d9d180";
  };

  postPatch = ''
    sed -i eglexternalplatform.pc \
      -e "s,/usr,$out,"
  '';

  configurePhase = ":";

  buildPhase = ":";

  installPhase = ''
    for header in interface/*.h; do
      install -D -m644 -v $header "$out/include/EGL/$(basename "$header")"
    done

    install -D -m644 -v eglexternalplatform.pc \
      $out/lib/pkgconfig/eglexternalplatform.pc
  '';

  meta = with lib; {
    description = "The EGL External Platform interface";
    homepage = https://github.com/NVIDIA/eglexternalplatform;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
