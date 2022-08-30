# maltrail-mikrotik-docker
Maltrail IDS with support for mikrotik packet sniffer stream in docker.

# Setup mikrotik
* Winbox > Tools > Packet Sniffer.
* Enable Streaming server (insert IP address of your Docker host computer)
* Enable Filter Stream.
* Add filter in filter tab to filter trafic what you want monitor.
* Start the packet sniffer.

# Build maltrail docker image

```sh
docker build . -t maltrail
```

* Dont forget password from build. Password is random generated

```sh
Step 9/13 : RUN PASS=$(openssl rand -base64 24)     && HASH=$(echo -n $PASS | sha256sum | cut -d " " -f 1)     && sed -i "s/9ab3cd9d67bf49d01f6a2e33d0bd9bc804ddbe6ce1ff5d219c42624851db5dbc/$HASH/g" /opt/maltrail/maltrail.conf     && echo "password for web interface is $PASS and user is admin"
 ---> Running in 8ecbdbaba788
password for web interface is XXXXXXXX and user is admin
```

# Run maltrail Docker image

```sh
docker run -d -p 37008:37008 -p 8337:8337 -p 8338:8338 maltrail
```

# Access web interface

On address (docker host IP):8338 is web interface. For access use password and username from build.
