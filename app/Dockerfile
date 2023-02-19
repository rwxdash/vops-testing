FROM alpine:3.17

COPY . /opt/app

RUN apk update
RUN apk add --no-cache \
    py3-pip \
    python3 \
    && apk add --virtual build-deps gcc python3-dev musl-dev \
    && apk add --no-cache mariadb-dev

RUN ln -sf python3 /usr/bin/python
RUN pip install pipenv

WORKDIR /opt/app

RUN pipenv install --system
RUN apk del build-deps

CMD ["gunicorn", "--bind", "0.0.0.0:3000", "main:app"]
