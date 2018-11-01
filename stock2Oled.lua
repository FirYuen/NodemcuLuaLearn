function init_spi_display()

    local cs  = 8 -- GPIO15, pull-down 10k to GND
    local dc  = 4 -- GPIO2
    local res = 0 -- GPIO16

    spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 8, 8)

    gpio.mode(8, gpio.INPUT, gpio.PULLUP)

    disp = u8g2.ssd1306_128x64_noname(1, cs, dc, res)
end


function u8g2_prepare()
  disp:setFont(u8g2.font_6x10_tf)
  disp:setFontRefHeightExtendedText()
  disp:setDrawColor(1)
  disp:setFontPosTop()
  disp:setFontDirection(0)
end


function u8g2_box_frame(a)
  disp:drawStr( 0, 0, "drawBox")
  disp:drawBox(5,10,20,10)
  disp:drawBox(10+a,15,30,7)
  disp:drawStr( 0, 30, "drawFrame")
  disp:drawFrame(5,10+30,20,10)
  disp:drawFrame(10+a,15+30,30,7)
end

function u8g2_disc_circle(a)
  disp:drawStr( 0, 0, "drawDisc")
  disp:drawDisc(10,18,9)
  disp:drawDisc(24+a,16,7)
  disp:drawStr( 0, 30, "drawCircle")
  disp:drawCircle(10,18+30,9)
  disp:drawCircle(24+a,16+30,7)
end

function u8g2_r_frame(a)
  disp:drawStr( 0, 0, "drawRFrame/Box")
  disp:drawRFrame(5, 10,40,30, a+1)
  disp:drawRBox(50, 10,25,40, a+1)
end

function u8g2_string(a)
  disp:setFontDirection(0)
  disp:drawStr(30+a,31, " 0")
  disp:setFontDirection(1)
  disp:drawStr(30,31+a, " 90")
  disp:setFontDirection(2)
  disp:drawStr(30-a,31, " 180")
  disp:setFontDirection(3)
  disp:drawStr(30,31-a, " 270")
end

function u8g2_line(a)
  disp:drawStr( 0, 0, "drawLine")
  disp:drawLine(7+a, 10, 40, 55)
  disp:drawLine(7+a*2, 10, 60, 55)
  disp:drawLine(7+a*3, 10, 80, 55)
  disp:drawLine(7+a*4, 10, 100, 55)
end


function u8g2_extra_page(a)
  disp:drawStr( 0, 0, "Unicode")
  disp:setFont(u8g2.font_unifont_t_symbols)
  disp:setFontPosTop()
  disp:drawUTF8(0, 24, "good day")
  if a <= 3 then
    disp:drawUTF8(a*3, 36, "sun")
  else
    disp:drawUTF8(a*3, 36, "rain")
  end
end



function draw1()
  u8g2_prepare()

  local d3 = 8
  local d7 = bit.band(draw_state, 7)

  if d3 == 0 then
    u8g2_box_frame(d7)
  elseif d3 == 1 then
    u8g2_disc_circle(d7)
  elseif d3 == 2 then
    u8g2_r_frame(d7)
  elseif d3 == 3 then
    u8g2_string(d7)
  elseif d3 == 4 then
    u8g2_line(d7)
  elseif d3 == 5 then
    u8g2_triangle(d7)
  elseif d3 == 6 then
    u8g2_ascii_1()
  elseif d3 == 7 then
    u8g2_ascii_2()
  elseif d3 == 8 then
    u8g2_extra_page(d7)
  elseif d3 == 9 then
    d3 = 0
  end
end
 nowData = ""
function draw()

  u8g2_prepare()
  --local d7 = bit.band(draw_state, 7)
    --u8g2_extra_page(d7)
http.get("http://172.16.177.202:8081/stock", nil, function(code, data)
    if (code < 0) then
      print("HTTP request failed")
    else
      print(code, data)
      nowData=data
      
    end
  end)

disp:drawStr( 0, 0, nowData)
    print(nowData)

end


function loop()
  -- picture loop  
  disp:clearBuffer()
  draw()
  disp:sendBuffer()
  
  -- increase the state
  draw_state = draw_state + 1
  if draw_state >= 12*8 then
    draw_state = 0
  end

  loop_tmr:start()
end


draw_state = 0
loop_tmr = tmr.create()
loop_tmr:register(1000, tmr.ALARM_SEMI, loop)

init_spi_display()

print("--- Starting Graphics Test ---")
loop_tmr:start()
