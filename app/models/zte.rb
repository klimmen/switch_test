class Zte

def timeout(serial)
    case serial
      when "zte29xx"  then return {all_time:300}
      when "zte29xxE"  then return {all_time:300}
    end
  end



 def switch_connect?(sp)
    t_start = Time.now
    char = 0
    while char < 15 && (Time.now - t_start < 30) do
      sp.read_timeout = 1000
      print sp_char = sp.getc
      if !sp_char.nil?
        char+=1
      end
    end
    return char < 15
  end

  def myreadline(sp,str, timeout, f)
    t_start = Time.now
    start = true
    st_string = ''
    while start do 
      sp.read_timeout = 1000
      print sp_char = sp.getc
      
      if Time.now - t_start > timeout
        start = false    
        return nil         
      end 
      if !sp_char.nil? && sp_char.valid_encoding? 
        f.write sp_char
        st_string << sp_char.to_s
        if st_string.scan(str).any? 
          start = false
          return true 
        end
      end     
    end
  end

def work(name_comport, tty, switch)
  case switch
      when "zte29xx"  then return work_zte29xx(name_comport, tty)
      when "zte29xxE"  then return work_zte29xxE(name_comport, tty)
    end
end

def tty_case(tty)
  case tty
    when "S4" then return 1
    when "S5" then return 2
    when "S6" then return 3
    when "S7" then return 4
    when "S8" then return 5
    when "S9" then return 6
  end
end

def work_zte29xxE(name_comport, tty)
  File.open("log/#{tty}.log", 'w'){ |file| file.write "" }
  f = File.new("log/#{tty}.log", 'a')
  eth_oct_num = tty_case(tty)
  `ifconfig eth#{eth_oct_num}:0 10.40.9#{eth_oct_num}.3 netmask 255.255.255.0 up` 
  sp = SerialPort.new("/dev/tty#{tty}", 9600)  
  (f.close; sp.close; return "#{name_comport}:No connect") if switch_connect?(sp)
  (f.close; sp.close; return "#{name_comport}:Cann't enter to BOOT MODE ")if myreadline(sp, 'Press any key', 30, f).nil?
  sleep 1
  sp.print("\r")
  myreadline(sp, 'ZXR10 Boot', 5, f) 
  sleep 1
  sp.print("c\r")
  (f.close; sp.close; return "#{name_comport}:Incorrectly selected the switch model(excpect zte29xxE)") if myreadline(sp, 'boot location', 5, f).nil?
  sleep 1
  sp.print("1\r")
  myreadline(sp, 'actport', 5, f)
  sleep 1
  sp.print("1\r")
  myreadline(sp, 'serverip', 5, f)
  sleep 1
  sp.print("10.40.9#{eth_oct_num}.100\r")
  myreadline(sp, 'netmask', 5, f)
  sleep 1
  sp.print("255.255.255.0\r")
  myreadline(sp, 'ipaddr', 5, f)
  sleep 1
  sp.print("10.40.9#{eth_oct_num}.4\r")
  myreadline(sp, 'bootfile', 5, f)
  sleep 1
  sp.print("/img/zImage\r")
  myreadline(sp, 'username', 5, f)
  sleep 1
  sp.print("ftpuser\r")
  myreadline(sp, 'password', 5, f)
  sleep 1
  sp.print("1234\r")
  myreadline(sp, 'ZXR10 Boot', 5, f)
  sleep 1
  sp.print("zte\r")
  myreadline(sp, 'BootManager', 5, f)
  sleep 1
  sp.print("cd img\r")
  myreadline(sp, 'BootManager', 5, f)
  sleep 1
  sp.print("rm zImage\r")
  sleep 1
  sp.print("y\r")
  myreadline(sp, 'BootManager', 5, f)
  sleep 1
  sp.print("ftp get zImage\r")
  (f.close; sp.close; return "#{name_comport}:Error in upload zImage") if myreadline(sp, 'Ftp get zImage successfully', 120, f).nil?
  sleep 1
  sp.print("cd ..\r")
  sleep 1
  sp.print("cd cfg\r")
  sleep 1
  sp.print("rm startrun.dat\r")
  sleep 1
  sp.print("y\r")
  myreadline(sp, 'BootManager', 5, f)
  sleep 1
  sp.print("reboot\r")
  (f.close; sp.close; return "#{name_comport}:Incorrect zImage running") if myreadline(sp, 'login', 100, f).nil?
  sleep 1
  sp.print("admin\r")
  sleep 1
  sp.print("zhongxing\r")
  sleep 1
  sp.print("en\r")
  sleep 1
  sp.print("zhongxing\r")
  (f.close; sp.close; return "#{name_comport}:Incorrect login/password") if myreadline(sp, "zte\(cfg\)", 5, f).nil?   			
  f.close
  sp.close
  return "#{name_comport}:OK default"

end

def work_zte29xx(name_comport, tty)
  File.open("log/#{tty}.log", 'w'){ |file| file.write "" }
  f = File.new("log/#{tty}.log", 'a')
  eth_oct_num = tty_case(tty)
  `ifconfig eth#{eth_oct_num}:0 10.40.9#{eth_oct_num}.3 netmask 255.255.255.0 up` 
  sp = SerialPort.new("/dev/tty#{tty}", 9600)
  (f.close; sp.close; return "#{name_comport}:No connect") if switch_connect?(sp)
  (f.close; sp.close; return "#{name_comport}:Cann't enter to BOOT MODE ")if myreadline(sp, 'Press any key', 30, f).nil?
  sleep 1
  sp.print("\r")
  myreadline(sp, 'ZXR10 Boot', 5, f) 
  sleep 1
  sp.print("c\r")
  (f.close; sp.close; return "#{name_comport}:Incorrectly selected the switch model(excpect zte29xx)") if myreadline(sp, 'boot device', 5, f).nil?
  sleep 1
  sp.print("marfec0\r")
  myreadline(sp, 'processor number', 5, f)
  sleep 1
  sp.print("0\r")
  myreadline(sp, 'host name', 5, f)
   sleep 1
  sp.print("f129750\r")
  myreadline(sp, 'file name', 5, f)
  sleep 1
  sp.print("kernel\r")
  myreadline(sp, 'inet on ethernet', 5, f)
  sleep 1
  sp.print("10.40.9#{eth_oct_num}.106\r")
  myreadline(sp, 'inet on backplane', 5, f)
  sleep 1
  sp.print(".\r")
  myreadline(sp, 'host inet', 5, f)
  sleep 1
  sp.print("10.40.9#{eth_oct_num}.107\r")
  myreadline(sp, 'gateway inet', 5, f)
  sleep 1
  sp.print("10.40.9#{eth_oct_num}.101\r")
  myreadline(sp, 'user', 5, f)
  sleep 1
  sp.print("\r")
  myreadline(sp, 'ftp password', 5, f)
  sleep 1
  sp.print("\r")
  myreadline(sp, 'flag', 5, f)
  sleep 1
  sp.print("\r")
  myreadline(sp, 'target name', 5, f)
  sleep 1
  sp.print("\r")
  myreadline(sp, 'startup script', 5, f)
  sleep 1
  sp.print("\r")
  myreadline(sp, 'other', 5, f)
  sleep 1
  sp.print("\r")
  myreadline(sp, 'Bootline has saved to NVRAM', 5, f)
  sleep 2
  sp.print("zte\r")
  myreadline(sp, 'PASSWORD', 5, f) 
  sleep 1
  sp.print("zxr10\r")
  (f.close; sp.close; return "#{name_comport}:Cannot enter to BootManager") if myreadline(sp, 'BootManager', 5, f).nil?
  sleep 2
  sp.print("ls\r")
  myreadline(sp, 'BootManager', 5, f)
  sleep 1
  sp.print("del startcfg.txt\r")
  myreadline(sp, 'BootManager', 5, f)
  sleep 1
  sp.print("del running.cfg\r")
  myreadline(sp, 'BootManager', 5, f)
  sleep 1
  sp.print("tftp 10.40.9#{eth_oct_num}.3 kernel.z 1\r")
  (f.close; sp.close; return "#{name_comport}:Error in upload kernel.z") if myreadline(sp, 'Loading... done!', 180, f).nil?
  sleep 1
  sp.print("reboot\r")
  (f.close; sp.close; return "#{name_comport}:Incorrect kernel.z running") if myreadline(sp, 'login', 100, f).nil?
  sleep 1
  sp.print("admin\r")
  sleep 1
  sp.print("zhongxing\r")
  sleep 1
  sp.print("en\r")
  sleep 1
  sp.print("zhongxing\r")
  (f.close; sp.close; return "#{name_comport}:Incorrect login/password") if myreadline(sp, "zte\(cfg\)", 5, f).nil?         
  f.close
  sp.close
  return "#{name_comport}:OK default"
end

end

