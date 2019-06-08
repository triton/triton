{ stdenv
, fetchFromGitHub
, lib
, makeWrapper
, ruby

, channel
}:

let
  channels = {
    "2" = {
      version = "2.0.10";
      sha256 = "95054968397643d432873d56bc6c9f1d195038c198ecf677dcd59fc09a62d535";
    };
    "1" = {
      version = "1.5.8";
      sha256 = "2955e10d487e2b5a7b7ede9660fa77597806dbd79daff606c57158f1ee4d3966";
    };
  };

  inherit (channels."${channel}")
    version
    sha256;
in
stdenv.mkDerivation rec {
  name = "asciidoctor-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "asciidoctor";
    repo = "asciidoctor";
    rev = "v${version}";
    inherit sha256;
  };

  nativeBuildInputs = [
    makeWrapper
    ruby
  ];

  buildPhase = ''
    gem build asciidoctor.gemspec
  '';

  installPhase = ''
    gem install -i "$out"/${ruby.gemDir} *.gem
    ln -srv "$out"/${ruby.gemDir}/bin "$out"/bin
  '';

  preFixup = ''
    for bin in "$out"/bin/*; do
      wrapProgram "$bin" \
        --set "GEM_PATH" "$out/${ruby.gemDir}"
    done
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
