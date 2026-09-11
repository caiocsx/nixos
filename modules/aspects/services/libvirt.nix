{ ... }:
{
  den.aspects.libvirt.nixos =
    { pkgs, ... }:
    {
      virtualisation.libvirtd.enable = true;
      programs.virt-manager.enable = true;
      environment.systemPackages = [
        pkgs.virt-viewer
        pkgs.qemu
      ];
    };
}
