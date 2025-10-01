{pkgs, ...}: {
  home.packages = with pkgs; [
    goverlay
    lm_sensors
  ];

  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
    settings = {
      arch = true;
      background_alpha = 0.4;
      background_color = "020202";
      blacklist = "warp";

      core_bars = true;
      core_load_change = true;
      cpu_color = "2e97cb";
      cpu_load_change = true;
      cpu_load_color = "FFFFFF,FFAA7F,CC0000";
      cpu_load_value = "50,90";
      cpu_mhz = true;
      cpu_power = true;
      cpu_stats = true;
      cpu_temp = true;
      cpu_text = "CPU";

      device_battery = true;

      dynamic_frame_timing = true;

      engine_color = "eb5b5b";
      engine_version = true;
      engine_short_names = true;
      exec_name = true;

      font_size = 38;
      fps = true;
      frametime_color = "00ff00";
      frame_timing = 1;
      frame_timing_detailed = 1;
      gl_vsync = -1;

      gpu_color = "2e9762";
      gpu_core_clock = true;
      gpu_load_change = true;
      gpu_load_color = "FFFFFF,FFAA7F,CC0000";
      gpu_load_value = "50,90";
      gpu_mem_clock = true;
      gpu_name = true;
      gpu_power = true;
      gpu_stats = true;
      gpu_temp = true;
      gpu_text = "GPU";

      io_color = "a491d3";
      io_read = true;
      io_write = true;

      legacy_layout = false;

      no_display = true;

      output_folder = "/home/vilsol";
      position = "top-left";

      procmem = true;
      procmem_shared = true;
      procmem_virt = true;

      ram = true;
      ram_color = "c26693";

      resolution = true;
      round_corners = 5;
      text_color = "ffffff";
      throttling_status = true;
      time = true;

      toggle_hud = "Shift_R+F12";
      toggle_logging = "Shift_L+F2";
      upload_log = "F5";

      vram_color = "ad64c1";
      vram = true;

      vsync = 0;
      vulkan_driver = true;

      wine = true;
      wine_color = "eb5b5b";
    };
  };
}
