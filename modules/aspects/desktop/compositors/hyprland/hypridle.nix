{ ... }:
{
  den.aspects.hypridle.homeManager =
    { config, pkgs, ... }:
    {
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || hyprlock";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl eval 'hl.dispatch(hl.dsp.dpms({'on'}))' && hyprctl hyprsunset gamma 100";
            on_unlock_cmd = "hyprctl hyprsunset gamma 100";
          };
          listener = [
            {
              timeout = 300;
              on-timeout = "hyprctl hyprsunset gamma 50";
              on-resume = "hyprctl hyprsunset gamma 100";
            }
            {
              timeout = 600;
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 1200;
              on-timeout = "hyprctl eval 'hl.dispatch(hl.dsp.dpms({'off'}))'";
              on-resume = "hyprctl eval 'hl.dispatch(hl.dsp.dpms({'on'}))'";
            }
            {
              timeout = 2400;
              on-timeout = "systemctl suspend";
            }
          ];
        };
      };
    };
}
