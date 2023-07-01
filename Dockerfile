FROM ubuntu:focal

RUN apt-get update \ 
    && apt-get upgrade -y \
    && apt-get install -y git python3 python3-dev python3-pip python-is-python3 libpcap-dev build-essential procps schedtool cron tcpreplay \
    && pip3 install pcapy-ng \
    && git clone --depth=1 https://github.com/stamparm/maltrail.git /opt/maltrail \
    && python /opt/maltrail/core/update.py

RUN git clone https://github.com/thefloweringash/tzsp2pcap.git && cd /tzsp2pcap \
    && make

RUN touch /var/log/cron.log

RUN (echo '*/1 * * * * if [ -n "$(ps -ef | grep -v grep | grep server.py)" ]; then : ; else python /opt/maltrail/server.py -c /opt/maltrail/maltrail.conf; fi >> /var/log/cron.log') | crontab
RUN (crontab -l ; echo '*/1 * * * * if [ -n "$(ps -ef | grep -v grep | grep sensor.py)" ]; then : ; else python /opt/maltrail/sensor.py -c /opt/maltrail/maltrail.conf; fi >> /var/log/cron.log') | crontab
RUN (crontab -l ; echo '0 1 * * * cd /opt/maltrail && git pull') | crontab
RUN (crontab -l ; echo '2 1 * * * /usr/bin/pkill -f maltrail') | crontab

RUN PASS=$(openssl rand -base64 24) \
    && HASH=$(echo -n $PASS | sha256sum | cut -d " " -f 1) \
    && sed -i "s/9ab3cd9d67bf49d01f6a2e33d0bd9bc804ddbe6ce1ff5d219c42624851db5dbc/$HASH/g" /opt/maltrail/maltrail.conf \
    && echo "password for web interface is $PASS and user is admin"

EXPOSE 8337/udp
EXPOSE 8338/tcp
EXPOSE 37008/udp

CMD bash -c "python /opt/maltrail/server.py &" && bash -c "python /opt/maltrail/sensor.py &" && bash -c "tzsp2pcap/tzsp2pcap -f | tcpreplay-edit --topspeed --mtu 800 --mtu-trunc -i eth0  -" && cron && tail -f /var/log/cron.log
