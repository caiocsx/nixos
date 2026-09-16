{ lib }:
let
  lua = lib.generators.mkLuaInline;
in
{
  on = {
    _args = [
      "hyprland.start"
      (lua ''
        function()
          hl.exec_cmd("systemctl --user start graphical-session.target")
        end'')
    ];
  };
}
