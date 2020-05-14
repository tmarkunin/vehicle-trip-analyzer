FROM nginx:alpine

RUN apk update
RUN apk add --no-cache py3-pip

ENV PATH=bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
COPY app /app
RUN pip3 install -r /app/requirements.txt
RUN ln -s /usr/bin/python3 /usr/bin/python
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY run.sh /run.sh
CMD ["sh","/run.sh"]
