package io.prometheus.client.sample.metrics;

import io.prometheus.client.Gauge;

public class GaugeExample {

    static final Gauge inprogressRequests = Gauge.build()
            .name("inprogress_requests").help("Inprogress requests.").register();

    void processRequest() {
        inprogressRequests.inc();
        // Your code here.
        inprogressRequests.dec();
    }

}
