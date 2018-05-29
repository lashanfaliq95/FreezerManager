
package com.company;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Random;
import java.util.concurrent.TimeUnit;

public class Main implements Runnable {
    private String deviceId;

    public Main(String deviceId) {
        this.deviceId = deviceId;
    }

    Random rand = new Random();
    public static String accessToken = "385318b7-18c0-32b6-b492-93e43fbb82f2";
public static final String deviceType="FreezerManager";
    public static void main(String[] args) throws IOException {
         ArrayList<String> devices=new ArrayList<>();
        JsonParser jsonParser = new JsonParser();
        String temp = getDevices(0,100);


        JsonObject jsonPayload = jsonParser.parse(temp).getAsJsonObject();
        JsonArray allDevices = jsonPayload.get("devices").getAsJsonArray();
        for (JsonElement device : allDevices) {
            JsonObject tempDevice = device.getAsJsonObject();
            if((tempDevice.get("type").getAsString()).equals(deviceType)){
                devices.add(tempDevice.get("deviceIdentifier").getAsString());
            }
            }
        String temp1=getDevices(101,100);
        JsonObject jsonPayload1 = jsonParser.parse(temp1).getAsJsonObject();
        JsonArray allDevices1 = jsonPayload1.get("devices").getAsJsonArray();
        for (JsonElement device : allDevices1) {
            JsonObject tempDevice = device.getAsJsonObject();
            if((tempDevice.get("type").getAsString()).equals(deviceType)){
                devices.add(tempDevice.get("deviceIdentifier").getAsString());
            }
        }
        System.out.println(devices.size());
        Thread newThread;
        for(int i=0;i<devices.size();i++){
             newThread= new Thread(new Main(devices.get(i)));
             newThread.start();  //should be start();
        }


    }

    @Override
    public void run() {
        String type = "application/json; charset=UTF-8";
        while (true) {
            int temp = rand.nextInt(50) + 1, humidity = rand.nextInt(100) + 1, powerConsumption = rand.nextInt(50) + 1;
            String json = "{\"temperature\":" + temp + ",\"humidity\":" + humidity + ",\"powerConsumption\":" + powerConsumption + "}";
            byte[] out = json.getBytes(StandardCharsets.UTF_8);
            try {
                URL u = new URL("http://localhost:8280/api/device-mgt/v1.0/device/agent/events/publish/FreezerManager/" + deviceId);
                System.out.println(deviceId);
                HttpURLConnection conn = (HttpURLConnection) u.openConnection();
                conn.setDoOutput(true);
                conn.setRequestProperty("authorization", " Bearer " + accessToken);
                conn.setRequestProperty("Content-Type", type);
                conn.setRequestMethod("POST");
                OutputStream os = conn.getOutputStream();
                os.write(out);
                os.flush();
                System.out.println(conn.getResponseMessage());
                TimeUnit.SECONDS.sleep(5);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private static String getDevices(int offset,int limit) throws IOException {
        StringBuffer result = new StringBuffer();
        URL url = new URL("http://localhost:8280/api/device-mgt/v1.0/devices/?offset="+offset+"&limit="+limit);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestProperty("authorization", " Bearer " + accessToken);
        conn.setRequestMethod("GET");
        BufferedReader rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        String line;
        while ((line = rd.readLine()) != null) {
            result.append(line);
        }
        rd.close();
        System.out.println(result);
        return result.toString();
    }

}
