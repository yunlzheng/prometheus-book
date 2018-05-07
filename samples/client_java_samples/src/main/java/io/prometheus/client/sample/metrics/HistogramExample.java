package io.prometheus.client.sample.metrics;

import io.prometheus.client.Histogram;
import io.prometheus.client.sample.mock.Request;

public class HistogramExample {
    static final Histogram requestLatency = Histogram.build()
            .name("requests_latency_seconds").help("Request latency in seconds.")
            .buckets(0.1, 0.2, 0.4, 0.8)
            .register();

    static final Histogram receivedBytes = Histogram.build()
            .name("requests_size_bytes").help("Request size in bytes.").register();


    void processRequest(Request req) {
        Histogram.Timer requestTimer = requestLatency.startTimer();
        try {
            // Your code here.
        } finally {
            receivedBytes.observe(req.size());
            requestTimer.observeDuration();
        }
    }
}
