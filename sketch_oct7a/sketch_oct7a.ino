#include <WiFi.h>
#include <PubSubClient.h>
#include <DHT.h>

// ====== CẤU HÌNH PHẦN CỨNG ======
#define LED_PIN 18
#define DHT_PIN 4
#define DHT_TYPE DHT22

#define ENA 25
#define IN1 26
#define IN2 27

DHT dht(DHT_PIN, DHT_TYPE);

// ====== CẤU HÌNH WIFI & MQTT ======
const char* ssid = "KimTuyen";
const char* password = "26122018";
const char* mqtt_server = "172.20.10.4"; // IP của EMQX broker

WiFiClient espClient;
PubSubClient client(espClient);
unsigned long lastMsg = 0;

// ====== CÁC TOPIC MQTT ======
const char* sub_topic = "iot/classroom/device01/control";   // Nhận lệnh điều khiển
const char* pub_topic = "iot/classroom/device01/telemetry"; // Gửi dữ liệu cảm biến

// ====== HÀM KẾT NỐI WIFI ======
void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("🔌 Đang kết nối WiFi: ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\n✅ WiFi connected");
  Serial.print("📶 IP: ");
  Serial.println(WiFi.localIP());
}

// ====== CALLBACK NHẬN TIN NHẮN MQTT ======
void callback(char* topic, byte* message, unsigned int length) {
  String msg;
  for (int i = 0; i < length; i++) msg += (char)message[i];
  msg.trim();

  Serial.println("📩 MQTT: " + msg);

  if (msg == "LED_ON") {
    digitalWrite(LED_PIN, HIGH);
    Serial.println("💡 LED BẬT");
  } 
  else if (msg == "LED_OFF") {
    digitalWrite(LED_PIN, LOW);
    Serial.println("💤 LED TẮT");
  } 
  else if (msg == "MOTOR_ON") {
    digitalWrite(ENA, HIGH);
    digitalWrite(IN1, HIGH);
    digitalWrite(IN2, LOW);
    Serial.println("⚙️  Motor QUAY THUẬN");
  } 
  else if (msg == "MOTOR_OFF") {
    digitalWrite(ENA, LOW);
    Serial.println("🛑 Motor DỪNG");
  }
  else if (msg == "MOTOR_REVERSE") {
    digitalWrite(ENA, HIGH);
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, HIGH);
    Serial.println("🔄 Motor QUAY NGƯỢC");
  }
}

// ====== KẾT NỐI MQTT BROKER ======
void reconnect() {
  while (!client.connected()) {
    Serial.print("🔁 Đang kết nối MQTT...");
    if (client.connect("ESP32_Device01")) {
      Serial.println("✅ Kết nối MQTT thành công!");
      client.subscribe(sub_topic);
    } else {
      Serial.print("❌ Lỗi, mã: ");
      Serial.println(client.state());
      delay(2000);
    }
  }
}

// ====== KHỞI TẠO ======
void setup() {
  Serial.begin(115200);

  pinMode(LED_PIN, OUTPUT);
  pinMode(ENA, OUTPUT);
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);

  digitalWrite(LED_PIN, LOW);
  digitalWrite(ENA, LOW);

  dht.begin();
  setup_wifi();
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);
}

// ====== VÒNG LẶP CHÍNH ======
void loop() {
  if (!client.connected()) reconnect();
  client.loop();

  unsigned long now = millis();
  if (now - lastMsg > 5000) {  // Cứ 5 giây gửi dữ liệu cảm biến
    lastMsg = now;

    float t = dht.readTemperature();
    float h = dht.readHumidity();

    if (isnan(t) || isnan(h)) {
      Serial.println("⚠️ Không đọc được dữ liệu DHT22!");
      return;
    }

    // Tạo JSON gửi về MQTT
    String payload = "{";
    payload += "\"temperature\": " + String(t, 1) + ",";
    payload += "\"humidity\": " + String(h, 1) + ",";
    payload += "\"led\": " + String(digitalRead(LED_PIN)) + ",";
    payload += "\"motor\": " + String(digitalRead(ENA)) + "}";
    
    Serial.println("📤 Gửi MQTT: " + payload);
    client.publish(pub_topic, payload.c_str());
  }
}
