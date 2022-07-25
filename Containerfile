FROM winefedora:latest

RUN dnf update -y
#RUN dnf install winetricks -y
RUN dnf install procps-ng gdb-gdbserver -y

ENTRYPOINT ["wine", "explorer"]
