FROM ubuntu:latest
SHELL ["/bin/bash", "-c"]
RUN apt-get update && apt-get install -y netcat
WORKDIR /app
COPY . .
CMD ./server.sh
