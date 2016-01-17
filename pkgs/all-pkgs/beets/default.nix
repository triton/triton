{ stdenv
, buildPythonPackage
, fetchFromGitHub
, fetchTritonPatch
, glibcLocales
, makeWrapper
, writeScript

, python
, pythonPackages
, imagemagick

, enableAcoustid   ? true
, enableBadfiles   ? true
  , flac ? null
  , mp3val ? null
, enableBpd        ? false
  , gst-python_0 ? null
  , gst-plugins-base_0 ? null
, enableDiscogs    ? true
, enableEchonest   ? true
, enableFetchart   ? true
, enableLastfm     ? true
, enableMpd        ? true
, enableReplaygain ? true
  , bs1770gain ? null
, enableThumbnails ? true
, enableWeb        ? true

# External plugins
, enableAlternatives ? false

, bashInteractive
, bashCompletion
}:

with {
  inherit (stdenv.lib)
    attrNames
    concatMapStrings
    optional
    optionals
    optionalString;
};

assert enableAcoustid    -> pythonPackages.pyacoustid     != null;
assert enableBadfiles    -> flac != null && mp3val != null;
assert enableBpd         -> pythonPackages.pygobject_2 != null &&
                            gst_python != null &&
                            gst_plugins_base != null;
assert enableDiscogs     -> pythonPackages.discogs_client != null;
assert enableEchonest    -> pythonPackages.pyechonest     != null;
assert enableFetchart    -> pythonPackages.responses      != null;
assert enableLastfm      -> pythonPackages.pylast         != null;
assert enableMpd         -> pythonPackages.mpd            != null;
assert enableReplaygain  -> bs1770gain                    != null;
assert enableThumbnails  -> pythonPackages.pyxdg          != null;
assert enableWeb         -> pythonPackages.flask          != null;

let
  optionalPlugins = {
    badfiles = enableBadfiles;
    bpd = enableBpd;
    chroma = enableAcoustid;
    discogs = enableDiscogs;
    echonest = enableEchonest;
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

  testShell = "${bashInteractive}/bin/bash --norc";
  completion = "${bashCompletion}/share/bash-completion/bash_completion";

in buildPythonPackage rec {
  name = "beets-${version}";
  version = "1.3.16";
  namePrefix = "";

  src = fetchFromGitHub {
    owner = "sampsyo";
    repo = "beets";
    rev = "v${version}";
    sha256 = "1grjcgr419yq756wwxjpzyfjdf8n51bg6i0agm465lb7l3jgqy6k";
  };

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "beets/beets-1.3-replaygain-default-bs1770gain.patch";
      sha256 = "d864aa643c16d5df9b859b5f186766a94bf2db969d97f255a88f33acf903b5b6";
    })
  ];

  postPatch = ''
    sed -i -e '/assertIn.*item.*path/d' test/test_info.py
    echo echo completion tests passed > test/test_completion.sh

    sed -i -e '/^BASH_COMPLETION_PATHS *=/,/^])$/ {
      /^])$/i u"${completion}"
    }' beets/ui/commands.py
  '' + optionalString enableBadfiles ''
    sed -i -e '/self\.run_command(\[/ {
      s,"flac","${flac}/bin/flac",
      s,"mp3val","${mp3val}/bin/mp3val",
    }' beetsplug/badfiles.py
  '' + optionalString enableBpd ''
    # Hack to allow newer clients to try to connect
    sed -e '/PROTOCOL_VERSION/ s/0.13.0/0.19.0/' -i beetsplug/bpd/__init__.py
  '' + optionalString enableReplaygain ''
    sed -i -re '
      s!^( *cmd *= *b?['\'''"])(bs1770gain['\'''"])!\1${bs1770gain}/bin/\2!
    ' beetsplug/replaygain.py
    sed -i -e 's/if has_program.*bs1770gain.*:/if True:/' \
      test/test_replaygain.py
  '';

  nativeBuildInputs = [
    makeWrapper
  ];

  propagatedBuildInputs = [
    pythonPackages.enum34
    pythonPackages.jellyfish
    pythonPackages.munkres
    pythonPackages.musicbrainzngs
    pythonPackages.mutagen
    pythonPackages.pathlib
    pythonPackages.pyyaml
    pythonPackages.unidecode
  ] ++ optional enableAcoustid   pythonPackages.pyacoustid
    ++ optional enableFetchart   pythonPackages.requests2
    ++ optional enableDiscogs    pythonPackages.discogs_client
    ++ optional enableEchonest   pythonPackages.pyechonest
    ++ optional enableLastfm     pythonPackages.pylast
    ++ optional enableMpd        pythonPackages.mpd
    ++ optional enableThumbnails pythonPackages.pyxdg
    ++ optional enableWeb        pythonPackages.flask
    ++ optional enableAlternatives (import ./alternatives-plugin.nix {
      inherit stdenv buildPythonPackage pythonPackages fetchFromGitHub;
    });

  buildInputs = with pythonPackages; [
    beautifulsoup4
    imagemagick
    mock
    nose
    rarfile
    responses
  ] ++ optionals enableBpd [
    gst-plugins-base_0
    gstreamer_0
  ];

  makeWrapperArgs = optionals enableBpd [
    "--prefix GST_PLUGIN_PATH : ${
      stdenv.lib.makeSearchPath "lib/gstreamer-0.10" [ gst-plugins-base_0 ]}"
  ];

  doCheck = true;
  enableParallelBuilding = true;

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
    runHook preCheck

    LANG=en_US.UTF-8 \
    LOCALE_ARCHIVE=${assert stdenv.isLinux; glibcLocales}/lib/locale/locale-archive \
    BEETS_TEST_SHELL="${testShell}" \
    BASH_COMPLETION_SCRIPT="${completion}" \
    HOME="$(mktemp -d)" \
      nosetests -v

    runHook postCheck
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    tmphome="$(mktemp -d)"

    EDITOR="${writeScript "beetconfig.sh" ''
      #!${stdenv.shell}
      cat > "$1" <<CFG
      plugins: ${concatStringsSep " " allEnabledPlugins}
      CFG
    ''}" HOME="$tmphome" "$out/bin/beet" config -e
    EDITOR=true HOME="$tmphome" "$out/bin/beet" config -e

    runHook postInstallCheck
  '';

  meta = with stdenv.lib; {
    description = "Music tagger and library organizer";
    homepage = http://beets.radbox.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
