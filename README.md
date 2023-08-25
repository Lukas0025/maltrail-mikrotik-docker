# maltrail-mikrotik-docker
Maltrail (https://github.com/stamparm/maltrail) IDS with support for mikrotik packet sniffer stream in docker.

## Introduction

**Maltrail** is a malicious traffic detection system, utilizing publicly available (black)lists containing malicious and/or generally suspicious trails, along with static trails compiled from various AV reports and custom user defined lists, where trail can be anything from domain name (e.g. `zvpprsensinaix.com` for [Banjori](http://www.johannesbader.ch/2015/02/the-dga-of-banjori/) malware), URL (e.g. `hXXp://109.162.38.120/harsh02.exe` for known malicious [executable](https://www.virustotal.com/en/file/61f56f71b0b04b36d3ef0c14bbbc0df431290d93592d5dd6e3fffcc583ec1e12/analysis/)), IP address (e.g. `185.130.5.231` for known attacker) or HTTP User-Agent header value (e.g. `sqlmap` for automatic SQL injection and database takeover tool). Also, it uses (optional) advanced heuristic mechanisms that can help in discovery of unknown threats (e.g. new malware).

![Reporting tool](https://i.imgur.com/Sd9eqoa.png)

## Setup mikrotik
* Winbox > Tools > Packet Sniffer.
* Enable Streaming server (insert IP address of your Docker host computer)
* Enable Filter Stream.
* Add filter in filter tab to filter trafic what you want monitor.
* Start the packet sniffer.

## Build maltrail docker image

```sh
docker build . -t maltrail --progress=plain --no-cache
```

* Dont forget password from build. Password is random generated

```sh
Step 9/13 : RUN PASS=$(openssl rand -base64 24)     && HASH=$(echo -n $PASS | sha256sum | cut -d " " -f 1)     && sed -i "s/9ab3cd9d67bf49d01f6a2e33d0bd9bc804ddbe6ce1ff5d219c42624851db5dbc/$HASH/g" /opt/maltrail/maltrail.conf     && echo "password for web interface is $PASS and user is admin"
 ---> Running in 8ecbdbaba788
password for web interface is XXXXXXXX and user is admin
```

## Run maltrail Docker image

```sh
docker run -d -p 37008:37008/udp -p 8337:8337 -p 8338:8338 maltrail
```

Ports:
* 8337/udp - maltrail sensor port listener
* 8338/tcp - maltrail web interface
* 37008/udp - mikrotik packet sniffer stream listener


## Access web interface

On address (docker host IP):8338 is web interface. For access use password and username from build.

## Verify funkcionality of IDS

### Port scanning

Run nmap port scanning from some computer in network to another.

```sh
nmap -p0-65535 (IP OF ANOTHER COMPUTER)
```

## Finding issue

Get some logs from docker container.

```sh
# for list containers
docker ps                                                                
# get the logs  
docker logs -f {name/id of maltrail container} 
```
more info for docker logs: https://docs.docker.com/engine/reference/commandline/logs/

It shut by useful to determinate if Mikrotik sending sniffer stream to docker. For this exec to container and stop running service and start 

```sh
# for list containers
docker ps 
# exec in container
docker exec -it {name/id of maltrail container} sh 
# in container
# for find pid of tzsp2pcap ctrl+c for close of top
top 
kill {pid of tzsp2pcap}
# for make sure tzsp2pcap is kiled
top
# read mikrotik sniffer stream in terminal
tzsp2pcap/tzsp2pcap  -f 

# if you want see packets heders in readeble fromat
apt update
apt install tcpdump
tzsp2pcap/tzsp2pcap  -f | tcpdump -r -
```

more info for docker exec: https://docs.docker.com/engine/reference/commandline/exec/

Now you must see all sniffed packets in terminal if not please make sure if mikrotik packet stream if running, if yes check firewall rules for port `37008/udp`.  if firewall allowed this port please check `tzsp2pcap` on your main host outside of container.

### Note
it take some time to display threat in webinterface, please wait some time after you create test threat. Make sure if you not filter out threat with mikrotik filter.

## Open issue on github
If you cant find reason for issue you can open issue on github. On issue please write logs from docker container and test if mikrotik stream is going to container.

