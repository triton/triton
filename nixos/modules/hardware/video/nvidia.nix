# This module provides the proprietary NVIDIA X11 / OpenGL drivers.

{ config, lib, pkgs, ... }:

with {
  inherit (lib)
    elem
    mkIf
    optionals
    optionalString
    singleton;
};

let

  drivers = config.services.xserver.videoDrivers;

  # FIXME: should introduce an option like
  # ‘hardware.video.nvidia.package’ for overriding the default NVIDIA
  # driver.
  nvidiaForKernel = kernelPackages:
    if elem "nvidia" drivers || elem "nvidia-long" drivers then
      kernelPackages.nvidia-drivers_long-lived
    else if elem "nvidia-short" drivers then
      kernelPackages.nvidia-drivers_short-lived
    else if elem "nvidia-beta" drivers then
      kernelPackages.nvidia-drivers_beta
    else if elem "nvidia-legacy304" drivers then
      kernelPackages.nvidia-drivers_legacy304
    else if elem "nvidia-legacy340" drivers then
      kernelPackages.nvidia-drivers_legacy340
    else
      null;

  nvidia-drivers = nvidiaForKernel config.boot.kernelPackages;
  nvidia-drivers_libs32 = (nvidiaForKernel pkgs.pkgs_32.linuxPackages).override {
    buildConfig = "userspace";
    libsOnly = true;
    kernel = null;
  };

  enabled = nvidia-drivers != null;
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
      nvidia-drivers
    ];

    environment.etc."OpenCL/vendors/nvidia.icd".source =
      "${nvidia-drivers}/etc/OpenCL/vendors/nvidia.icd";
    environment.etc."nvidia/nvidia-application-profiles-rc.d".source =
      "${nvidia-drivers}/etc/nvidia/nvidia-application-profiles-rc.d";

    environment.systemPackages = [
      nvidia-drivers
    ];

    hardware.opengl.package = nvidia-drivers;
    hardware.opengl.package32 = nvidia-drivers_libs32;

    services.acpid.enable = true;

    # Create /dev/nvidia-uvm when the nvidia-uvm module is loaded.
    services.udev.extraRules = optionalString nvidia-drivers.cudaUVM ''
      KERNEL=="nvidia_uvm", RUN+="${pkgs.stdenv.shell} -c 'mknod -m 666 /dev/nvidia-uvm c $(grep nvidia-uvm /proc/devices | cut -d \  -f 1) 0'"
    '';

    services.xserver.drivers = singleton {
      name = "nvidia";
      modules = [
        # x11glvnd module
        pkgs.libglvnd
        pkgs.libva-vdpau-driver
        nvidia-drivers
      ];
      libPath = [
        nvidia-drivers
      ];
    };

    services.xserver.screenSection = ''
      Option "RandRRotation" "on"
    '';

  };

}
