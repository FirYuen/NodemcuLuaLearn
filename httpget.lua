http.get("http://172.16.177.202:8081/stock", nil, function(code, data)
    if (code < 0) then
      print("HTTP request failed")
    else
      print(code, data)
    end
  end)