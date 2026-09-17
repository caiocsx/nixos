{ ... }:
{
  den.aspects.fastfetch.homeManager =
    { pkgs, ... }:
    {
      programs.fastfetch = {
        enable = true;
        settings = {
          modules = [
            {
              type = "custom";
              format = "┌─────────────────────System──────────────────────┐";
            }
            {
              type = "title";
              key = "   󰀄 User";
              keyColor = "blue";
              format = "{1}@{2}";
            }
            {
              type = "kernel";
              key = "   󰻀 Kernel";
              keyColor = "blue";
            }
            {
              type = "os";
              key = "    OS";
              keyColor = "blue";
              format = "{2}";
            }
            {
              type = "wm";
              key = "   󰖯 WM";
              keyColor = "blue";
              format = "{2}";
            }
            {
              type = "packages";
              key = "   󰏗 Packages";
              keyColor = "blue";
            }
            {
              type = "custom";
              format = "└─────────────────────────────────────────────────┘";
            }
            {
              type = "custom";
              format = "┌────────────────────Hardware─────────────────────┐";
            }
            {
              type = "cpu";
              key = "   󰻠 CPU";
              keyColor = "yellow";
              format = "{1}";
            }
            {
              type = "gpu";
              key = "   󰢮 GPU";
              keyColor = "yellow";
              format = "{1}";
            }
            {
              type = "memory";
              key = "   󰍛 Memory";
              keyColor = "yellow";
              format = "{1} / {2} ({3})";
            }
            {
              type = "disk";
              key = "   󰋊 Disk";
              keyColor = "yellow";
              format = "{1} / {2} ({3})";
              folders = "/";
            }
            {
              type = "custom";
              format = "└─────────────────────────────────────────────────┘";
            }
            {
              type = "custom";
              format = "┌─────────────────────Extras──────────────────────┐";
            }
            {
              type = "datetime";
              key = "   󰙹 DateTime";
              keyColor = "magenta";
            }
            {
              type = "uptime";
              key = "   󱑆 Uptime";
              keyColor = "magenta";
            }
            {
              type = "disk";
              key = "   󰞌 OS Age";
              keyColor = "magenta";
              format = "{days} days";
              folders = "/";
            }
            {
              type = "custom";
              format = "└─────────────────────────────────────────────────┘";
            }
            {
              type = "colors";
              symbol = "circle";
              paddingLeft = 2;
              colors = [
                "black"
                "red"
                "green"
                "yellow"
                "blue"
                "magenta"
                "cyan"
                "white"
              ];
            }
            "break"
          ];
        };
      };
    };
}
