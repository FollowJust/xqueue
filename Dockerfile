FROM ubuntu:jammy

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Moscow

RUN apt update && \
  apt-get install -y software-properties-common=0.99.22.1 && apt-get update && \
  apt-get install git=1:2.34.1-1ubuntu1.2 language-pack-en=1:22.04+20220415 libmysqlclient-dev=8.0.29-0ubuntu0.22.04.2 ntp=1:4.2.8p15+dfsg-1ubuntu2 libssl-dev=3.0.2-0ubuntu1.2 python3.10=3.10.4-3 python3-pip=22.0.2+dfsg-1 -qy && \
  rm -rf /var/lib/apt/lists/*

RUN useradd -m --shell /bin/false app
RUN mkdir -p /edx/app/log/
RUN touch /edx/app/log/edx.log
RUN chown app:app /edx/app/log/edx.log

WORKDIR /edx/app/xqueue
COPY requirements /edx/app/xqueue/requirements
COPY requirements.txt /edx/app/xqueue/requirements.txt
RUN pip install -r requirements.txt

COPY . /edx/app/xqueue
RUN chown app /edx/app/xqueue
USER app

RUN python3.10 manage.py migrate && python3.10 manage.py update_users

EXPOSE 8040
CMD gunicorn -c /edx/app/xqueue/xqueue/docker_gunicorn_configuration.py --bind=0.0.0.0:8040 --workers 2 --max-requests=1000 xqueue.wsgi:application