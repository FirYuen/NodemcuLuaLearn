
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

m = mqtt.Client("NodeMCU_Client_fi", 120,"iotfreetest/thing01","YU7Tov8zFW+WuaLx9s9I3MKyclie9SGDuuNkl6o9LXo=") 

m:on("connect", function(client) print ("connected") end)
m:on("offline", function(client) 

    print ("offline") 
    mqtt_connecting=0
    reconnect()
end)

m:on("message", function(client, topic, data) 
  if data ~= nil then
    print( topic.. ":".. data)
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
