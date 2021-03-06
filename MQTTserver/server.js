var Mqtt = require('mqtt');
var RandomString = require('randomstring');

var mqttParam = {
    server: 'ssl://iotfreetest.mqtt.iot.gz.baidubce.com:1884',
    options: {
        username: 'iotfreetest/thing01',
        password: 'YU7Tov8zFW+WuaLx9s9I3MKyclie9SGDuuNkl6o9LXo=',
        clientId: 'test_mqtt_node_' + RandomString.generate()
    },
    topic: 'demoTopic'
};

var mqttClient = Mqtt.connect(mqttParam.server, mqttParam.options);
console.log('Connecting to broker: ' + mqttParam.server);

mqttClient.on('error', function(error) {
    console.error(error);
});

mqttClient.on('message', function(topic, data) {
    console.log('MQTT message received: ' + data);
    if (data.toString() === 'exit') process.exit();
});

mqttClient.on('connect', function() {
    console.log('Connected. Client id is: ' + mqttParam.options.clientId);

    mqttClient.subscribe(mqttParam.topic);
    console.log('Subscribed to topic: ' + mqttParam.topic)

    mqttClient.publish(mqttParam.topic, 'Message from Baidu IoT demo');
    console.log('MQTT message published.');
});

  var timeflag = 1
  function postRandom(){
      if (timeflag){
	mqttClient.publish(mqttParam.topic, RandomString.generate());
		setTimeout(()=>{
        postRandom()
    },2000)
      }
  }
  postRandom()
  setTimeout(()=>{
      timeflag=0
  },1000*15)