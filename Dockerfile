FROM opensciencegrid/software-base:fresh

LABEL maintainer OSG Software <help@opensciencegrid.org>

RUN groupadd -g 1000 -r condor
RUN useradd -r -g condor -d /var/lib/condor -s /sbin/nologin \
    -u 1000 -c "Owner of HTCondor Daemons" condor

RUN \
 yum -y update  && \
 yum clean all  && \
 rm -rf /var/cache/yum/*

RUN \
 yum -y install --enablerepo=osg-upcoming-rolling osg-flock \
 openssh-clients && \
 yum clean all  && \
 rm -rf /var/cache/yum/*

# In the future, the condor RPMs will create these
RUN \
 install -m 0700 -o root -g root -d /etc/condor/passwords.d && \
 install -m 0700 -o condor -g condor -d /etc/condor/tokens.d

RUN \
 useradd submituser

RUN \
 install -m 0700 -o root -g root -d /root/config && \
 install -m 0700 -o root -g root -d /root/secrets

COPY supervisord.conf /etc/supervisord.conf
COPY condor/*.conf /etc/condor/config.d/
COPY start.sh update-config update-secrets create-flocking-tokens /
COPY fetch-crl.cron /etc/cron.d/fetch-crl

CMD ["/bin/bash", "-x", "/start.sh"]
