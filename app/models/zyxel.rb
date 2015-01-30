class Zyxel

  def serial_uptime_switch(serial)
    case serial
      when "zyxel2024" then return {download_time_rom:30, download_time_bin:60, download_time_switch:180 }
      when "zyxel3124" then return {download_time_rom:30, download_time_bin:60, download_time_switch:180 }
      when "zyxel3528" then return {download_time_rom:30, download_time_bin:60, download_time_switch:180 }
    end
  end

  def work(tty, switch)
   puts switch
  end

end