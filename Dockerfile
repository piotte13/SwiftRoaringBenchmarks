FROM swift:4.2.4

RUN apt-get update && apt-get install -y python python-pip

COPY . /usr/src/
WORKDIR /usr/src/


CMD ["bash", "./Scripts/run.sh"]
