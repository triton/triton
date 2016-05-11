{ stdenv
, buildPythonPackage
, fetchFromGitHub
, fetchTritonPatch
, glibcLocales
, makeWrapper
, writeScript

, python
, python2Packages
, imagemagick

, enableAcousticbrainz ? true
, enableAcoustid ? true
, enableBadfiles ? true
  , flac ? null
  , mp3val ? null
, enableBpd ? false
  , gst-plugins-base_0 ? null
  , gstreamer_0
, enableDiscogs ? true
, enableEchonest ? true
, enableEmbyUpdate ? true
, enableFetchart ? true
, enableLastfm ? true
, enableMpd ? true
, enableReplaygain ? true
  , bs1770gain ? null
, enableThumbnails ? true
, enableWeb ? true

# External plugins
, enableAlternatives ? false

, bash
, bashCompletion
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (stdenv.lib)
    attrNames
    concatMapStrings
    concatStringsSep
    elem
    filterAttrs
    id
    makeSearchPath
    optional
    optionals
    optionalString
    platforms;
in

assert enableAcoustid -> python2Packages.pyacoustid != null;
assert enableBadfiles ->
  flac != null
  && mp3val != null;
assert enableBpd ->
  python2Packages.pygobject_2 != null
  && gst-plugins-base_0 != null
  && gstreamer_0 != null;
assert enableDiscogs -> python2Packages.discogs_client != null;
assert enableEchonest -> python2Packages.pyechonest != null;
assert enableFetchart -> python2Packages.responses != null;
assert enableLastfm -> python2Packages.pylast != null;
assert enableMpd -> python2Packages.mpd != null;
assert enableReplaygain -> bs1770gain != null;
assert enableThumbnails -> python2Packages.pyxdg != null;
assert enableWeb -> python2Packages.flask != null;

let
  optionalPlugins = {
    acousticbrainz = enableAcousticbrainz;
    badfiles = enableBadfiles;
    bpd = enableBpd;
    chroma = enableAcoustid;
    discogs = enableDiscogs;
    echonest = enableEchonest;
    embyupdate = enableEmbyUpdate;
    fetchart = enableFetchart;
    lastgenre = enableLastfm;
    lastimport = enableLastfm;
    mpdstats = enableMpd;
    mpdupdate = enableMpd;
    replaygain = enableReplaygain;
    thumbnails = enableThumbnails;
    web = enableWeb;
  };

  pluginsWithoutDeps = [
    "bench"
    "bpd"
    "bpm"
    "bucket"
    "convert"
    "cue"
    "duplicates"
    "edit"
    "embedart"
    "embyupdate"
    "filefilter"
    "freedesktop"
    "fromfilename"
    "ftintitle"
    "fuzzy"
    "ihate"
    "importadded"
    "importfeeds"
    "info"
    "inline"
    "ipfs"
    "keyfinder"
    "lyrics"
    "mbcollection"
    "mbsubmit"
    "mbsync"
    "metasync"
    "missing"
    "permissions"
    "play"
    "plexupdate"
    "random"
    "rewrite"
    "scrub"
    "smartplaylist"
    "spotify"
    "the"
    "types"
    "zero"
  ];

  enabledOptionalPlugins = attrNames (filterAttrs (_: id) optionalPlugins);

  allPlugins = pluginsWithoutDeps ++ attrNames optionalPlugins;
  allEnabledPlugins = pluginsWithoutDeps ++ enabledOptionalPlugins;

  testShell = "${bash}/bin/bash --norc";
  completion = "${bashCompletion}/share/bash-completion/bash_completion";

in

buildPythonPackage rec {
  name = "beets-${version}";
  version = "1.3.17";
  namePrefix = "";

  src = fetchFromGitHub {
    owner = "sampsyo";
    repo = "beets";
    rev = "v${version}";
    sha256 = "8b8c74478277e6b010cc1319c1e9b6fe97e1a8967bede341ebeabc205b7cc0f3";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  propagatedBuildInputs = [
    python2Packages.enum34
    python2Packages.itsdangerous
    python2Packages.jellyfish
    python2Packages.jinja2
    python2Packages.munkres
    python2Packages.musicbrainzngs
    python2Packages.mutagen
    python2Packages.pathlib
    python2Packages.pyyaml
    python2Packages.unidecode
    python2Packages.werkzeug
  ] ++ optional enableAcoustid python2Packages.pyacoustid
    ++ optional (
      enableFetchart
      || enableEmbyUpdate
      || enableAcousticbrainz) python2Packages.requests2
    ++ optional enableDiscogs python2Packages.discogs_client
    ++ optional enableEchonest python2Packages.pyechonest
    ++ optional enableLastfm python2Packages.pylast
    ++ optional enableMpd python2Packages.mpd
    ++ optional enableThumbnails python2Packages.pyxdg
    ++ optional enableWeb python2Packages.flask
    ++ optional enableAlternatives (import ./alternatives-plugin.nix {
      inherit stdenv buildPythonPackage python2Packages fetchFromGitHub;
    });

  buildInputs = [
    python2Packages.beautifulsoup4
    imagemagick
    python2Packages.mock
    python2Packages.nose
    python2Packages.rarfile
    python2Packages.responses
  ] ++ optionals enableBpd [
    gst-plugins-base_0
    gstreamer_0
  ];

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "beets/beets-1.3-replaygain-default-bs1770gain.patch";
      sha256 = "d864aa643c16d5df9b859b5f186766a94bf2db969d97f255a88f33acf903b5b6";
    })
  ];

  postPatch = ''
    sed -i -e '/assertIn.*item.*path/d' test/test_info.py
    echo echo completion tests passed > test/rsrc/test_completion.sh

    sed -i -e '/^BASH_COMPLETION_PATHS *=/,/^])$/ {
      /^])$/i u"${completion}"
    }' beets/ui/commands.py
  '' + optionalString enableBadfiles ''
    sed -i -e '/self\.run_command(\[/ {
      s,"flac","${flac}/bin/flac",
      s,"mp3val","${mp3val}/bin/mp3val",
    }' beetsplug/badfiles.py
  '' + optionalString enableBpd
  /* Hack to allow newer mpd clients to try to connect to bpd */ ''
    sed -i beetsplug/bpd/__init__.py \
      -e '/PROTOCOL_VERSION/ s/0.13.0/0.19.0/'
  '' + optionalString enableReplaygain ''
    sed -i -re '
      s!^( *cmd *= *b?['\'''"])(bs1770gain['\'''"])!\1${bs1770gain}/bin/\2!
    ' beetsplug/replaygain.py
    sed -i -e 's/if has_program.*bs1770gain.*:/if True:/' \
      test/test_replaygain.py
  '';

  makeWrapperArgs = optionals enableBpd [
    "--prefix GST_PLUGIN_PATH : ${
      makeSearchPath "lib/gstreamer-0.10" [ gst-plugins-base_0 ]}"
  ];

  preCheck = ''
    (${concatMapStrings (s: "echo \"${s}\";") allPlugins}) \
      | sort -u > plugins_defined
    find beetsplug -mindepth 1 \
      \! -path 'beetsplug/__init__.py' -a \
      \( -name '*.py' -o -path 'beetsplug/*/__init__.py' \) -print \
      | sed -n -re 's|^beetsplug/([^/.]+).*|\1|p' \
      | sort -u > plugins_available

    if ! mismatches="$(diff -y plugins_defined plugins_available)"; then
      echo "The the list of defined plugins (left side) doesn't match" \
           "the list of available plugins (right side):" >&2
      echo "$mismatches" >&2
      exit 1
    fi
  '';

  checkPhase = ''
    runHook 'preCheck'

    LANG=en_US.UTF-8 \
    LOCALE_ARCHIVE=${assert (elem targetSystem platforms.linux); glibcLocales}/lib/locale/locale-archive \
    BEETS_TEST_SHELL="${testShell}" \
    BASH_COMPLETION_SCRIPT="${completion}" \
    HOME="$(mktemp -d)" \
      nosetests -v

    runHook 'postCheck'
  '';

  installCheckPhase = ''
    runHook 'preInstallCheck'

    tmphome="$(mktemp -d)"

    EDITOR="${writeScript "beetconfig.sh" ''
      #!${stdenv.shell}
      cat > "$1" <<CFG
      plugins: ${concatStringsSep " " allEnabledPlugins}
      CFG
    ''}" HOME="$tmphome" "$out/bin/beet" config -e
    EDITOR=true HOME="$tmphome" "$out/bin/beet" config -e

    runHook 'postInstallCheck'
  '';

  doCheck = true;
  doInstallCheck = true;

  meta = with stdenv.lib; {
    description = "Music tagger and library organizer";
    homepage = http://beets.radbox.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
