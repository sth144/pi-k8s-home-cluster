FROM raspbian/stretch:latest

RUN apt-get update && apt-get install -y curl
RUN curl -L https://install.pivpn.io > install_pivpn.sh
RUN bash install_pivpn.sh
