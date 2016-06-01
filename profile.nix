{ config, pkgs, ... }:

{

  user.packages = with pkgs; [ vim mpd ];

  imperativeNix.enable = true;

  user.resourceFiles = [
    { target = ".mpdconf";
      text = ''
        music_directory         "~/.mpd/music"
        playlist_directory      "~/.mpd/playlists"
        db_file                 "~/.mpd/mpd.db"
        pid_file                "~/.mpd/mpd.pid"
        state_file              "~/.mpd/state"
        bind_to_address         "localhost"
        gapless_mp3_playback    "yes"
        input {
            plugin   "curl"
        }
        audio_output {
            type     "pulse"
            name     "My Pulse Output"
        }
        mixer_type              "hardware"
        volume_normalization    "yes"
        filesystem_charset      "UTF-8"
      '';
    }
  ];

  systemd.services.mpd = {
    wantedBy = [ "default.target" ];
    description = "Music Player Daemon";
    path = [ pkgs.mpd ];
    preStart = "mkdir -p ~/.mpd";
    script = "exec mpd --no-daemon";
  };

}
