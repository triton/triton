# This module provides the proprietary NVIDIA X11 / OpenGL drivers.

{ config, lib, pkgs, ... }:

let
  inherit (lib)
    elem
    mkIf
    optionals
    optionalString
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

    boot.kernelModules = optionals nvidia-drivers_kernelspace.drm [
      "nvidia-drm"
    ] ++ optionals nvidia-drivers_kernelspace.kms [
      "nvidia-modeset"
    ] ++ optionals nvidia-drivers_kernelspace.uvm [
      "nvidia-uvm"
    ];

    boot.kernelParams = optionals nvidia-drivers_kernelspace.kms [
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
    services.udev.extraRules = optionalString nvidia-drivers_kernelspace.uvm ''
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
        # x11glvnd module
        pkgs.libglvnd
        nvidia-drivers_userspace
      ];
      libPath = [
        nvidia-drivers_userspace
      ];
    };

    services.xserver.screenSection = ''
      Option "RandRRotation" "on"
    '';

  };

}
