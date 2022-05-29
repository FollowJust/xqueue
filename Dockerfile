FROM ubuntu:jammy

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Moscow

RUN apt-get update && \
  apt-get install software-properties-common git language-pack-en libmysqlclient-dev ntp libssl-dev python3.10 python3-pip -qy

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