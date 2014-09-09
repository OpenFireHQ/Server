FROM    centos:centos6
MAINTAINER Peter Willemsen <peter@codebuffet.co>

# Enable EPEL for Node.js
RUN     rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
# Install Node.js and npm
RUN     yum install -y npm

# Bundle app source
COPY . /src

# Install app dependencies
RUN cd /src; npm install

EXPOSE 5454

CMD ["node", "/src/openfire.js", "hack"]
