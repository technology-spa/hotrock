FROM docker.elastic.co/kibana/kibana:7.2.0

# /usr/share/kibana/bin/kibana-plugin install "https://github.com/bitsensor/elastalert-kibana-plugin/releases/download/1.1.0/elastalert-kibana-plugin-1.1.0-7.2.0.zip" && \
# /usr/share/kibana/bin/kibana-plugin install "https://github.com/pjhampton/kibana-prometheus-exporter/releases/download/7.2.0/kibana-prometheus-exporter-7.2.0.zip" && \
# /usr/share/kibana/bin/kibana-plugin install "https://github.com/sivasamyk/logtrail/releases/download/v0.1.31/logtrail-7.2.0-0.1.31.zip" && \

RUN /usr/share/kibana/bin/kibana-plugin install "https://packages.wazuh.com/wazuhapp/wazuhapp-3.9.3_7.2.0.zip" && \
    /usr/local/bin/kibana-docker --optimize

USER kibana

CMD ["/usr/local/bin/kibana-docker"]
