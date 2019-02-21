{ stdenv
, cmake
, fetchFromGitHub
, makeWrapper
, lib

, bc
, ffmpeg_head
, jq
, lib-bash
}:

stdenv.mkDerivation rec {
  name = "arkive-2016-11-11";

  src = fetchFromGitHub {
    version = 2;
    owner = "chlorm";
    repo = "arkive";
    rev = "dbe59908ca616ce766ba2a115874962b63bfc297";
    sha256 = "5081d226de1f1c7fe9e9f1d9e94b71fdf5ef86e8fd2a23c631a5d06d70d495c3";
  };

  nativeBuildInputs = [
    cmake
    makeWrapper
  ];

  buildInputs = [
    bc
    ffmpeg_head
    jq
    lib-bash
  ];

  preFixup = ''
    wrapProgram $out/bin/arkive \
      --prefix 'PATH' : "${bc}/bin" \
      --prefix 'PATH' : "${ffmpeg_head}/bin" \
      --prefix 'PATH' : "${jq}/bin" \
      --prefix 'PATH' : "${lib-bash}/bin"
  '';

  meta = with lib; {
    description = "Video encoding automation scripts";
    homepage = https://github.com/chlorm/arkive/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
