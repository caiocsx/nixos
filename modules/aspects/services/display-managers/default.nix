{ den, ... }:
{
  den.aspects.display-manager =
    { host, ... }:
    let
      displayManagers = {
        ly = den.aspects.ly;
        noctalia-greeter = den.aspects.noctalia-greeter;
        sddm = den.aspects.sddm;
      };
    in
    {
      includes = [ displayManagers.${host.displayManager} ];
    };
}
