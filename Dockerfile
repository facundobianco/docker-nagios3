FROM debian:8.2
MAINTAINER Facundo Bianco < vando [at] van [dot] do >

#ENV NAGIOSUSER nagiosadmin
#ENV NAGIOSPASS admin
ENV TERM xterm

COPY bin/* /usr/local/bin/
RUN find /usr/local/bin -type f -not -executable -exec chmod +x {} \;

RUN export DEBIAN_FRONTEND=noninteractive ; apt-get update && \
    apt-get install -y --no-install-recommends \
    apache2 exim4 monitoring-plugins-basic nagios3 nagios-images

RUN dpkg-statoverride --update --add nagios www-data 2710 /var/lib/nagios3/rw
RUN dpkg-statoverride --update --add nagios nagios 751 /var/lib/nagios3

COPY conf/update-exim4.conf.conf /etc/exim4/update-exim4.conf.conf
COPY conf/passwd.client /etc/exim4/passwd.client

COPY conf/000-nagios3.conf /etc/apache2/sites-available/
RUN rm /etc/apache2/sites-enabled/000-default.conf
RUN ln -sr /etc/apache2/sites-available/000-nagios3.conf /etc/apache2/sites-enabled

RUN htpasswd -bc /etc/nagios3/users.htpasswd ${NAGIOSUSER:-nagiosadmin} ${NAGIOSPASS:-admin}

EXPOSE 80
CMD ["/usr/local/bin/nagios3.run"]
