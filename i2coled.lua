function init_i2c_display()
    -- SDA and SCL can be assigned freely to available GPIOs
    local sda = 1 -- GPIO14
    local scl = 2 -- GPIO12
    local sla = 0x3c
    i2c.setup(0, sda, scl, i2c.SLOW)
    disp = u8g2.ssd1306_i2c_128x64_noname(0, sla)
end



init_i2c_display()

gpio.mode(0, gpio.OUTPUT)
gpio.mode(4, gpio.OUTPUT)

gpio.write(0, gpio.HIGH)
gpio.write(4, gpio.HIGH)
mqtt_connecting=0

function stateTrig(pin)
    local state = gpio.read(pin)
    if (state==0)then
        gpio.write(pin, gpio.HIGH)
     else
        gpio.write(pin, gpio.LOW)
     end
end

function u8g2_prepare()
  disp:setFont(u8g2.font_6x10_tf)
  disp:setFontRefHeightExtendedText()
  disp:setDrawColor(1)
  disp:setFontPosTop()
  disp:setFontDirection(0)
end


function draw(y,str)
    if str ~=nil then
        
        u8g2_prepare()
        disp:setFontDirection(0)
        disp:drawStr( 2,y, str)

    end
end

function write2log(data)
if file.open("log.txt", "a+") then
  file.write(data)
  file.write("\n")
  file.close()
end
end

function wrtoscreen(str)
     disp:clearBuffer()
    
if #str>21 then
strarr={}
     str=string.sub(str,1,126)
    local strlen = #str
    local arrlen=0
     if strlen%21~=0 then
          arrlen=(strlen-strlen%21)/21+1
     else 
          arrlen=(strlen-strlen%21)/21
     end
   
    for i=1,arrlen,1 do
        strarr[i]=string.sub(str,(i-1)*21+1,i*21)
     end

    for j=1,#strarr,1 do

     draw((j-1)*10,strarr[j])
   end
   disp:sendBuffer()
     else 
          disp:clearBuffer()
         
          draw(0,str)
          disp:sendBuffer()
          --print(str)
    end
end


m = mqtt.Client("NodeMCU_Client_ded", 120,"iotfreetest/thing01","YU7Tov8zFW+WuaLx9s9I3MKyclie9SGDuuNkl6o9LXo=") 

m:on("connect", function(client) print ("connected") end)
m:on("offline", function(client) 
    print ("offline") 
    mqtt_connecting=0
    reconnect()
end)

m:on("message", function(client, topic, data) 
  if (data ~= nil and data~="DO NOT ANSWER! DO NOT ANSWER! DO NOT ANSWER!") then
    print( topic.. ":".. data)
          wrtoscreen(data)
          write2log(data)
     if data =="bule on"then
          gpio.write(4, gpio.LOW)   
     elseif data =="bule off"then
          gpio.write(4, gpio.HIGH)
     elseif data =="bule tri"then
      stateTrig(4)
     elseif data =="red on"then
          gpio.write(0, gpio.LOW)   
     elseif data =="red off"then
          gpio.write(0, gpio.HIGH)
     elseif data =="red tri"then
         stateTrig(0)
     elseif data =="ALL off"then
          gpio.write(0, gpio.HIGH)
          gpio.write(4, gpio.HIGH)
     elseif data =="ALL on"then
          gpio.write(0, gpio.LOW)
          gpio.write(4, gpio.LOW)
     elseif data =="i am online"then
            print("on line")
     elseif data =="i am back"then
            print("on line")
      elseif data =="DO NOT ANSWER! DO NOT ANSWER! DO NOT ANSWER!"then
            print("Sended dont answer!")
     else 
        client:publish("demoTopic", "DO NOT ANSWER! DO NOT ANSWER! DO NOT ANSWER!", 0, 0)
    end
  end
 
end)

m:connect("iotfreetest.mqtt.iot.gz.baidubce.com",1883, 0, function(client)
  print("connected")
    mqtt_connecting=1
  client:subscribe("demoTopic", 0, function(client) print("subscribe success") end)
  client:publish("demoTopic", "i am online", 0, 0, function(client) print("sent") end)
end,
function(client, reason)
  print("failed reason: " .. reason)
end)


function reconnect()
    if mqtt_connecting == 0 then
        tmr.alarm(3, 2000, 1, function()
            print("start reconnect!")
            m:close()
            m:connect("iotfreetest.mqtt.iot.gz.baidubce.com",1883, 0, function(client)
            print("connected")
            mqtt_connecting=1
            client:subscribe("demoTopic", 0, function(client) print("subscribe success") end)
            client:publish("demoTopic", "i am back", 0, 0, function(client) print("sent") end)
            stopReconnect()
end,
function(client, reason)
  print("failed reason: " .. reason)
end)
        end)
        mqtt_connecting = 1
    end
end

function stopReconnect()
    -- clear connecting state and clear connect timer!
    mqtt_connecting = 0
    tmr.stop(3)
end

--m:close(); --stop mqtt

