# This module provides the proprietary NVIDIA X11 / OpenGL drivers.

{ config, lib, pkgs, ... }:

let
  inherit (lib)
    elem
    mkIf
    singleton;

  drivers = config.services.xserver.videoDrivers;

  # FIXME: should introduce an option like
  # ‘hardware.video.nvidia.package’ for overriding the default NVIDIA
  # driver.
  nvidiaKernelspace = kernelspacePackages:
    if elem "nvidia" drivers || elem "nvidia-long-lived" drivers then
      kernelspacePackages.nvidia-drivers_long-lived
    else if elem "nvidia-short-lived" drivers then
      kernelspacePackages.nvidia-drivers_short-lived
    else if elem "nvidia-beta" drivers then
      kernelspacePackages.nvidia-drivers_beta
    else if elem "nvidia-latest" drivers then
      kernelspacePackages.nvidia-drivers_latest
    else if elem "nvidia-tesla" drivers then
      kernelspacePackages.nvidia-drivers_tesla
    else
      null;

  nvidiaUserspace = userspacePackages:
    if elem "nvidia" drivers || elem "nvidia-long-lived" drivers then
      userspacePackages.nvidia-drivers_long-lived
    else if elem "nvidia-short-lived" drivers then
      userspacePackages.nvidia-drivers_short-lived
    else if elem "nvidia-beta" drivers then
      userspacePackages.nvidia-drivers_beta
    else if elem "nvidia-latest" drivers then
      userspacePackages.nvidia-drivers_latest
    else if elem "nvidia-tesla" drivers then
      userspacePackages.nvidia-drivers_tesla
    else
      null;

  nvidia-drivers_kernelspace = nvidiaKernelspace config.boot.kernelPackages;

  nvidia-drivers_userspace = nvidiaUserspace pkgs;
  nvidia-drivers_userspace_libs32 = (nvidiaUserspace pkgs.pkgs_32).override {
    libsOnly = true;
  };

  enabled =
    nvidia-drivers_kernelspace != null
    && nvidia-drivers_userspace != null;
in

{

  config = mkIf (config.services.xserver.enable && enabled) {

    boot.blacklistedKernelModules = [
      "nouveau"
      "nvidiafb"
      "rivafb"
      "rivatv"
    ];

    boot.extraModulePackages = [
      nvidia-drivers_kernelspace
    ];

    boot.kernelModules = [
      "nvidia"
      "nvidia_drm"
      "nvidia_modeset"
      "nvidia_uvm"
    ];

    boot.initrd.availableKernelModules = [
      "nvidia"
      "nvidia_drm"
      "nvidia_modeset"
      "nvidia_uvm"
    ];

    boot.kernelParams = [
      "nvidia-drm.modeset=1"
    ];

    environment.etc."OpenCL/vendors/nvidia.icd".source =
      "${nvidia-drivers_userspace}/etc/OpenCL/vendors/nvidia.icd";
    environment.etc."nvidia/nvidia-application-profiles-rc.d".source =
      "${nvidia-drivers_userspace}/etc/nvidia/nvidia-application-profiles-rc.d";
    environment.etc."nvidia/nvidia-application-profiles-key-documentation".source =
      "${nvidia-drivers_userspace}/share/nvidia/nvidia-application-profiles-key-documentation";

    environment.systemPackages = [
      nvidia-drivers_userspace
    ];

    hardware.opengl.package = nvidia-drivers_userspace;
    hardware.opengl.package32 = nvidia-drivers_userspace_libs32;
    hardware.opengl.extraPackages = [ pkgs.libva-vdpau-driver ];

    services.acpid.enable = true;

    # Create /dev/nvidia-uvm when the nvidia-uvm module is loaded.
    services.udev.extraRules = ''
      KERNEL=="nvidia", RUN+="${pkgs.stdenv.shell} -c 'mknod -m 666 /dev/nvidiactl c $(grep nvidia-frontend /proc/devices | cut -d \  -f 1) 255'"
      KERNEL=="nvidia_modeset", RUN+="${pkgs.stdenv.shell} -c 'mknod -m 666 /dev/nvidia-modeset c $(grep nvidia-frontend /proc/devices | cut -d \  -f 1) 254'"
      KERNEL=="card*", SUBSYSTEM=="drm", DRIVERS=="nvidia", RUN+="${pkgs.stdenv.shell} -c 'mknod -m 666 /dev/nvidia%n c $(grep nvidia-frontend /proc/devices | cut -d \  -f 1) %n'"
      KERNEL=="nvidia_uvm", RUN+="${pkgs.stdenv.shell} -c 'mknod -m 666 /dev/nvidia-uvm c $(grep nvidia-uvm /proc/devices | cut -d \  -f 1) 0'"
    '';

    services.xserver.deviceSection =
      /* Some laptops with nvida gpus cannot change screen brightness
         after X.Org has been started without this option enabled */ ''
        Option "RegistryDwords" "EnableBrightnessControl=1"
      '';

    services.xserver.drivers = singleton {
      name = "nvidia";
      modules = [
        nvidia-drivers_userspace
      ];
      libPath = [
        nvidia-drivers_userspace
      ];
    };

    services.xserver.screenSection = ''
      Option "RandRRotation" "on"
    '';
    #  Option "metamodes" "nvidia-auto-select +0+0 { ForceCompositionPipeline=On, ForceFullCompositionPipeline = On }"
    #  Option "AllowIndirectGLXProtocol" "off"
    #  Option "TripleBuffer" "on"
    #'';

  };

}
