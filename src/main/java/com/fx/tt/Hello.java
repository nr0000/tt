package com.fx.tt;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.InetAddress;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@RestController
@RequestMapping("/api")
public class Hello {
    @Autowired
    private Myconfig myconfig;

    @RequestMapping("/hello")
    public String index() {
        return "Hello World-2";
    }

    @RequestMapping("time")
    public String getTime() {
        LocalDateTime localDateTime = LocalDateTime.now();
        return localDateTime.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);
    }

    @RequestMapping("version")
    public String getVersion() {
        return "1.1";
    }

    @RequestMapping("env")
    public String getEnv() {
        return myconfig.getEnv();
    }


    @RequestMapping("ip")
    public String getIp() {
        InetAddress ia = null;
        try {
            ia = ia.getLocalHost();

            String localname = ia.getHostName();
            String localip = ia.getHostAddress();
            System.out.println("本机名称是：" + localname);
            System.out.println("本机的ip是 ：" + localip);
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
//        InetAddress ia1 = InetAddress.getLocalHost();//获取本地IP对象
        return ia.getHostAddress();
    }
}
