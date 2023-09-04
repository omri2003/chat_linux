FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y netcat-openbsd

SHELL ["/bin/bash", "-c"]

WORKDIR /app

COPY . .

CMD ["./server.sh"]
