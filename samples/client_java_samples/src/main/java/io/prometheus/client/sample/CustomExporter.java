package io.prometheus.client.sample;

import io.prometheus.client.exporter.HTTPServer;
import io.prometheus.client.hotspot.DefaultExports;
import io.prometheus.client.sample.collectors.YourCustomCollector;
import io.prometheus.client.sample.collectors.YourCustomCollector2;

import java.io.IOException;

public class CustomExporter {


    public static void main(String[] args) throws IOException {

        new YourCustomCollector().register();
        new YourCustomCollector2().register();

        DefaultExports.initialize();
        HTTPServer server = new HTTPServer(1234);
    }
}
