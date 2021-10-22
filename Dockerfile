FROM centos:7

#install node, openssh-server
RUN (curl -sL https://rpm.nodesource.com/setup_12.x | bash -) \
  && yum clean all -y \
  && yum update -y \
  && yum install -y nodejs \
  && yum autoremove -y \
  && yum clean all -y \
  && npm install npm --global \
  && yum install -y openssh-server \
  && yum install -y openssh-clients \
  && yum install -y initscripts \
  && echo "root:Docker!" | chpasswd

#add sshd config
COPY sshd_config /etc/ssh/sshd_config
COPY startup.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/startup.sh
RUN ssh-keygen -A
#script to execute the systemctl commands without systemd  
# https://github.com/gdraheim/docker-systemctl-replacement
COPY systemctl.py /usr/bin/systemctl
RUN chmod a+x /usr/bin/systemctl

#copy node application & build
WORKDIR /usr/local/app
COPY app /usr/local/app
RUN npm install 

#expose required ports
EXPOSE 80 2222
ENV PORT 80


ENTRYPOINT ["/usr/local/bin/startup.sh"]
