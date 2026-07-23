{ ... }:
{
  den.aspects.quickshell.homeManager =
    { ... }:
    {
      programs.quickshell = {
        enable = true;
        configs.default = ./qml;
        activeConfig = "default";
        systemd.enable = true;
      };
    };
}
