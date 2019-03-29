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
      version = "2.0.3";
      sha256 = "ba5c7ba7b9cc8d9fd16d67b6f9872250369b1d01732b430cc43a887789c7f93f";
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
