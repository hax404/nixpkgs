import ./make-test-python.nix ({ pkgs, ... }: {
  name = "tor-browser-bundle-bin";
  meta = with pkgs.stdenv.lib.maintainers; {
    maintainers = [ hax404 ];
  };

  machine =
    { pkgs, ... }:

    { imports = [ ./common/x11.nix ];
      environment.systemPackages =
        #[ pkgs.firefox ]
        [ pkgs.tor-browser-bundle-bin pkgs.firefox ]
        ++ [ pkgs.xdotool ];
      hardware.opengl.driSupport = true;
      networking.firewall.enable = false;
      networking.useDHCP = true;
      virtualisation.memorySize = "1024";
    };

  testScript = ''
      machine.wait_for_x()

      # with subtest("Wait until Tor Browser finished loading Start Site"):
      # machine.execute("xterm -e tor-browser || true &")
      # machine.execute("xterm")
      with subtest("Wait until connection window appears"):
          machine.execute("rm -rf /root/.local/")
          machine.execute("XAUTHORITY=/root/.Xauthority DISPLAY=:0 tor-browser &")
          # machine.sleep(10)
          machine.wait_for_window("Connect to Tor")
          machine.sleep(10)
          machine.execute("xdotool mousemove -- 230 230")
          machine.sleep(10)
          machine.execute("xdotool click 1")
          machine.send_chars("\n")
          machine.screenshot("screen_connection_window")

      with subtest("Wait until start site appears"):
          # machine.send_chars("\n")
          # machine.sleep(20)
          # machine.execute("xdotool click 1")
          # machine.send_key("return")
          # machine.send_key("ret")
          machine.wait_for_window("About Tor - Tor Browser")
          machine.sleep(5)
          machine.screenshot("screen_about_tor")

      # with subtest("go to test page"):
      #     machine.execute("xdotool key F6")
      #     machine.sleep(10)
      #     # machine.execute("xterm -e ip &")
      #     # machine.execute("tor-browser")
      #     # machine.wait_for_window("About Tor - Tor Browser")
      #     # machine.execute("xdotool key Return")
      #     machine.send_chars("https://check.torproject.org/\n")
      #     machine.sleep(20)
      #     machine.wait_for_window(
      #         "Congratulations. This browser is configured to use Tor. - Tor Browser"
      #     )
      #     machine.screenshot("screen_browser_test")
    '';

#      with subtest("Wait until Tor Browser finished loading Tor Browser Check"):
#          machine.execute("xdotool key Ctrl+T")
#          # machine.sendKeys("ctrl+t")
#          # machine.sendChars("http://check.torproject.org/")
#          # machine.sendKeys("enter")
#          machine.execute("xdotool type https://check.torproject.org/")
#          machine.execute("xdotool key Return")
#          # machine.wait_for_window("Congratulations. This browser is configured to use Tor.")
#          machine.sleep(40)
#          machine.screenshot("screen_tor_check")

#      with subtest("Hide default browser window"):
#          machine.sleep(2)
#          machine.execute("xdotool key F12")
#
#      with subtest("wait until Firefox draws the developer tool panel"):
#          machine.sleep(10)
#          machine.succeed("xwininfo -root -tree | grep \"Congratulations. This browser is configured to use Tor.\"")
#          machine.screenshot("screen")

#      with subtest("Close default browser prompt"):
#          machine.execute("xdotool key space")
})
