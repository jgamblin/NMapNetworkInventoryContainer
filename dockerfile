FROM debian:9.4-slim

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
    nmap \
    python3 \
    gawk \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /inventory
COPY nmapcsv.sh index.html continuousscan.sh /inventory/

EXPOSE 1337
CMD ["./inventory/continuousscan.sh"]
