FROM debezium/example-mysql:1.8

ENV MYSQL_USER=admin
ENV MYSQL_ROOT_PASSWORD=admin
ENV MYSQL_PASSWORD=rt-dwh-c0nflu3nt!

RUN mkdir /data
COPY data/* /data/

COPY conf/my.cnf /etc/mysql/my.cnf
RUN chown -R mysql:mysql /data/

RUN rm /docker-entrypoint-initdb.d/inventory.sql
COPY setup.sql /docker-entrypoint-initdb.d/
ADD setup.sql /docker-entrypoint-initdb.d
RUN chmod a+r /docker-entrypoint-initdb.d/*

EXPOSE 3306