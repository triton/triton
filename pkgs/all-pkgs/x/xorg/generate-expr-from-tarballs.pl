#! /usr/bin/perl -w

# Typical command to generate the list of tarballs:

# export i="mirror://xorg/X11R7.7/src/everything/"; cat $(PRINT_PATH=1 nix-prefetch-url $i | tail -n 1) | perl -e 'while (<>) { if (/(href|HREF)="([^"]*.bz2)"/) { print "$ENV{'i'}$2\n"; }; }' | sort > tarballs-7.7.list
# manually update extra.list
# then run: cat tarballs-7.7.list extra.list old.list | perl ./generate-expr-from-tarballs.pl
# tarballs-x.y.list is generated + changes for individual packages
# extra.list are packages not contained in the tarballs
# old.list are packages that used to be part of the tarballs


use strict;

my $tmpDir = "/tmp/xorg-unpack";


my %pkgURLs;
my %pkgHashes;
my %pkgNames;
my %pkgRequires;
my %pkgRequiresNative;

my %pcMap;

my %extraAttrs;


my @missingPCs = ("fontconfig", "libdrm", "libXaw", "zlib", "perl", "python", "python3", "mkfontscale", "mkfontdir", "bdftopcf", "libxslt", "openssl", "gperf", "gnum4", "libunwind", "libcacard", "spice-protocol", "libbsd", "intltool", "bison", "flex");
$pcMap{$_} = $_ foreach @missingPCs;
$pcMap{"libpci"} = "pciutils";
$pcMap{"spice-server"} = "spice";
$pcMap{"freetype2"} = "freetype";
$pcMap{"epoxy"} = "libepoxy";
$pcMap{"libsystemd-daemon"} = "systemd_lib";
$pcMap{"libsystemd"} = "systemd_lib";
$pcMap{"libpng12"} = "libpng";
$pcMap{"libpng"} = "libpng";
$pcMap{"libpcsclite"} = "pcsclite_lib";
$pcMap{"dbus-glib-1"} = "dbus-glib";
$pcMap{"fuse"} = "fuse";
$pcMap{"gconf-2.0"} = "gconf";
$pcMap{"glib-2.0"} = "glib";
$pcMap{"libdrm_intel"} = "libdrm";
$pcMap{"libdrm_nouveau"} = "libdrm";
$pcMap{"libdrm_amdgpu"} = "libdrm";
$pcMap{"libdrm_radeon"} = "libdrm";
$pcMap{"librsvg-2.0"} = "librsvg";
$pcMap{"dbus-1"} = "dbus";
$pcMap{"cairo"} = "cairo";
$pcMap{"utilmacros"} = "utilmacros";
$pcMap{"uuid"} = "util-linux_lib";
$pcMap{"libudev"} = "systemd_lib";
$pcMap{"mesa"} = "mesa_noglu";
$pcMap{"gl"} = "mesa_noglu";
$pcMap{"wayland-client"} = "wayland";
$pcMap{"libevdev"} = "libevdev";
$pcMap{"mtdev"} = "mtdev";
$pcMap{"libinput"} = "libinput";
$pcMap{"gbm"} = "mesa_noglu";
$pcMap{"glesv2"} = "mesa_noglu";
$pcMap{"egl"} = "mesa_noglu";
$pcMap{"dri"} = "mesa_noglu";
$pcMap{"libsystem"} = "systemd_lib";

my $downloadCache = "./download-cache";
$ENV{'NIX_DOWNLOAD_CACHE'} = $downloadCache;
mkdir $downloadCache, 0755;


while (<>) {
    chomp;
    my $tarball = "$_";
	next if $tarball =~ /[aA]pple/;
    print "\nDOING TARBALL $tarball\n";

    my $pkg;
    if ($tarball =~ s/:([a-zA-Z0-9_]+)$//) {
        $pkg = $1;
    } else {
        $tarball =~ /\/((?:(?:[A-Za-z0-9]|(?:-[^0-9])|(?:-[0-9]*[a-z]))+))[^\/]*$/;
        die unless defined $1;
        $pkg = $1;
        $pkg =~ s/-//g;
        #next unless $pkg eq "xcbutil";
    }

    $tarball =~ /\/([^\/]*)\.tar\.(bz2|gz|xz)$/;
    my $pkgName = $1;

    print "  $pkg $pkgName\n";

    if (defined $pkgNames{$pkg}) {
        print "  SKIPPING\n";
        next;
    }

    $pkgURLs{$pkg} = $tarball;
    $pkgNames{$pkg} = $pkgName;

    my ($hash, $path) = `PRINT_PATH=1 QUIET=1 nix-prefetch-url -I nixpkgs=../../../../ '$tarball'`;
    chomp $hash;
    chomp $path;
    $pkgHashes{$pkg} = $hash;

    print "\nunpacking $path\n";
    system "rm -rf '$tmpDir'";
    mkdir $tmpDir, 0700;
    system "cd '$tmpDir' && tar xf '$path'";
    die "cannot unpack `$path'" if $? != 0;
    print "\n";

    my $pkgDir = `echo $tmpDir/*`;
    chomp $pkgDir;

    my $provides = `find $pkgDir -name "*.pc.in"`;
    my @provides2 = split '\n', $provides;
    my @requires = ();
    my @requiresNative = ();

    foreach my $pcFile (@provides2) {
        my $pc = $pcFile;
        $pc =~ s/.*\///;
        $pc =~ s/.pc.in//;
        print "PROVIDES $pc\n";
        die "collision with $pcMap{$pc}" if defined $pcMap{$pc};
        $pcMap{$pc} = $pkg;

        open FOO, "<$pcFile" or die;
        while (<FOO>) {
            if (/Requires:(.*)/) {
                my @reqs = split ' ', $1;
                foreach my $req (@reqs) {
                    next unless $req =~ /^[a-z]+$/;
                    print "REQUIRE (from $pc): $req\n";
                    push @requires, $req;
                }
            }
        }
        close FOO;

    }

    my $file;
    {
        local $/;
        open FOO, "cd '$tmpDir'/* && grep -v '^ *#' configure.ac |";
        $file = <FOO>;
        close FOO;
    }

    if ($file =~ /XAW_CHECK_XPRINT_SUPPORT/) {
        push @requires, "libXaw";
    }

    if ($file =~ /zlib is required/ || $file =~ /AC_CHECK_LIB\(z\,/) {
        push @requires, "zlib";
    }

    if ($file =~ /AC_CHECK_LIB\(\[bsd\]/) {
        push @requires, "libbsd";
    }

    if ($file =~ /Perl is required/) {
        push @requiresNative, "perl";
    }

    if ($file =~ /AC_PATH_PROG\(BDFTOPCF/) {
        push @requiresNative, "bdftopcf";
    }

    if ($file =~ /AC_PATH_PROG\(MKFONTSCALE/) {
        push @requiresNative, "mkfontscale";
    }

    if ($file =~ /AC_PATH_PROG\(MKFONTDIR/) {
        push @requiresNative, "mkfontdir";
    }

    if ($file =~ /AM_PATH_PYTHON/) {
        push @requiresNative, "python";
    }

    if ($file =~ /AC_PATH_PROG\(FCCACHE/) {
        # Don't run fc-cache.
        die if defined $extraAttrs{$pkg};
        $extraAttrs{$pkg} = "    preInstall = \"installFlags=(FCCACHE=true)\";\n";
    }

    if ($file =~ /XORG_MACROS/) {
        push @requiresNative, "utilmacros";
    }

	if ($file =~ /python version 3/) {
        push @requiresNative, "python3";
    }

    my $isFont;

    if ($file =~ /XORG_FONT_BDF_UTILS/) {
        push @requiresNative, "bdftopcf", "mkfontdir";
        $isFont = 1;
    }

    if ($file =~ /XORG_FONT_SCALED_UTILS/) {
        push @requiresNative, "mkfontscale", "mkfontdir";
        $isFont = 1;
    }

    if ($file =~ /XORG_FONT_UCS2ANY/) {
        push @requiresNative, "fontutil", "mkfontscale";
        $isFont = 1;
    }

    if ($isFont) {
        $extraAttrs{$pkg} = "    configureFlags = [ \"--with-fontrootdir=\$(out)/lib/X11/fonts\" ];\n";
    }

    my $finalfile;
    {
        local $/;
        open FOO, "cd '$tmpDir'/* && grep -v '^ *#' configure |";
        $finalfile = <FOO>;
        close FOO;
    }

	if ($finalfile =~ /xorg-macros/) {
		push @requiresNative, "utilmacros";
	}

    if ($finalfile =~ /intltool/) {
        push @requiresNative, "intltool";
    }

    if ($finalfile =~ /checking for m4/) {
        push @requiresNative, "gnum4";
    }

    if ($finalfile =~ /--with-perl/) {
        push @requiresNative, "perl";
    }

    if ($finalfile =~ /'bison /) {
        push @requiresNative, "bison";
    }

    if ($finalfile =~ / flex /) {
        push @requiresNative, "flex";
    }

    my %fileVars;
    while ($file =~ /\n([0-9A-Z_]+)=\"([^"]*)\"/g) {
        $fileVars{$1} = $2;
    }

    sub process {
        my $requires = shift;
        my $fileVars = shift;
        my $s = shift;
        $s =~ s/\[/\ /g;
        $s =~ s/\]/\ /g;
        $s =~ s/\,/\ /g;
        foreach my $req (split / /, $s) {
            next if $req eq ">=";
            #next if $req =~ /^\$/;
            next if $req =~ /^[0-9]/;
            next if $req =~ /^\s*$/;
            next if $req =~ /apple/;
            next if $req eq '$REQUIRED_MODULES';
            next if $req eq '$REQUIRED_LIBS';
            next if $req eq '$XDMCP_MODULES';
            next if $req eq '$XORG_MODULES';
            next if $req =~ /_VERSION/;
            if ($req =~ /\$([A-Z0-9_]*)/) {
                if (!exists ${$fileVars}{$1}) {
                    "Couldn't find: " . $1 . "\n";
                    next
                }
                my $var = ${$fileVars}{$1};
                process($requires, $fileVars, $var);
            } else {
                print "REQUIRE: $req\n";
                push @{$requires}, $req;
            }
        }
    }

    #process \@requires, $1 while $file =~ /PKG_CHECK_MODULES\([^,]*,\s*[\[]?([^\)\[]*)/g;
    process \@requires, \%fileVars, $1 while $file =~ /PKG_CHECK_MODULES\([^,]*,([^\)\,]*)/g;
    process \@requires, \%fileVars, $1 while $file =~ /MODULES=\"(.*)\"/g;
    process \@requires, \%fileVars, $1 while $file =~ /REQUIRED_LIBS=\"(.*)\"/g;
    process \@requires, \%fileVars, $1 while $file =~ /REQUIRED_MODULES=\"(.*)\"/g;
    process \@requires, \%fileVars, $1 while $file =~ /REQUIRES=\"(.*)\"/g;
    process \@requires, \%fileVars, $1 while $file =~ /X11_REQUIRES=\'(.*)\'/g;
    process \@requires, \%fileVars, $1 while $file =~ /XDMCP_MODULES=\"(.*)\"/g;
    process \@requires, \%fileVars, $1 while $file =~ /XORG_MODULES=\"(.*)\"/g;
    process \@requires, \%fileVars, $1 while $file =~ /NEEDED=\"(.*)\"/g;
    process \@requires, \%fileVars, $1 while $file =~ /ivo_requires=\"(.*)\"/g;
    process \@requires, \%fileVars, $1 while $file =~ /XORG_DRIVER_CHECK_EXT\([^,]*,([^\)]*)\)/g;

    #push @requiresNative, "libxslt" if $pkg =~ /libxcb/;
    #push @requiresNative, "gperf", "m4", "xproto" if $pkg =~ /xcbutil/;

    print "REQUIRES $pkg => @requires\n";
    print "REQUIRES NATIVE $pkg => @requiresNative\n";
    $pkgRequires{$pkg} = \@requires;
    $pkgRequiresNative{$pkg} = \@requiresNative;

    print "done\n";
}


print "\nWRITE OUT\n";

open OUT, ">default.nix";

print OUT "";
print OUT <<EOF;
# THIS IS A GENERATED FILE.  DO NOT EDIT!
args @ { fetchurl, fetchgit, fetchpatch, stdenv, pkgconfig, intltool, freetype, fontconfig
, libxslt, expat, libpng, zlib, perl, mesa_noglu, mesa_drivers, spice-protocol, spice
, dbus, util-linux_lib, openssl, gperf, gnum4, libevdev, tradcpp, libinput, mcpp, makeWrapper, autoreconfHook
, autoconf, automake, libtool, xmlto, asciidoc, flex, bison, python, mtdev, cairo, glib
, libepoxy, wayland, libbsd, systemd_lib, gettext, pciutils, python3, ... }: with args;

let

  mkDerivation = name: attrs:
    let newAttrs = (overrides."\${name}" or (x: x)) attrs;
        stdenv = newAttrs.stdenv or args.stdenv;
    in stdenv.mkDerivation (removeAttrs newAttrs [ "stdenv" ] // {
      builder = ./builder.sh;
      postPatch = (attrs.postPatch or "") + ''
        patchShebangs .
      '';
      meta.platforms = with stdenv.lib.platforms;
        x86_64-linux;
	});

  overrides = import ./overrides.nix {inherit args xorg;};

  xorg = rec {

EOF


foreach my $pkg (sort (keys %pkgURLs)) {
    print "$pkg\n";

    my %requires = ();
    my %requiresNative = ();
    my $inputs = "";
    my $inputsNative = "";
    foreach my $req (sort @{$pkgRequires{$pkg}}) {
        if (defined $pcMap{$req}) {
            # Some packages have .pc that depends on itself.
            next if $pcMap{$req} eq $pkg;
            if (!defined $requires{$pcMap{$req}}) {
                $inputs .= "$pcMap{$req} ";
                $requires{$pcMap{$req}} = 1;
            }
        } else {
            print "  NOT FOUND: $req\n";
        }
    }
    foreach my $req (sort @{$pkgRequiresNative{$pkg}}) {
        if (defined $pcMap{$req}) {
            # Some packages have .pc that depends on itself.
            next if $pcMap{$req} eq $pkg;
            if (!defined $requiresNative{$pcMap{$req}}) {
                $inputsNative .= "$pcMap{$req} ";
                $requiresNative{$pcMap{$req}} = 1;
            }
        } else {
            print "  NOT FOUND: $req\n";
        }
    }

    my $extraAttrs = $extraAttrs{"$pkg"};
    $extraAttrs = "" unless defined $extraAttrs;

    print OUT <<EOF
  $pkg = (mkDerivation "$pkg" {
    name = "$pkgNames{$pkg}";
    src = fetchurl {
      url = $pkgURLs{$pkg};
      sha256 = "$pkgHashes{$pkg}";
    };
    nativeBuildInputs = [ $inputsNative];
    buildInputs = [ $inputs];
$extraAttrs
  }) // {inherit $inputs;};

EOF
}

print OUT "}; in xorg\n";

close OUT;
