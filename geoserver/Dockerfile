FROM tomcat:9-jre11

LABEL maintainer="Stefan Ziegler stefan.ziegler.de@gmail.com"

VOLUME /geodata

ENV GEOSERVER_VERSION 2.15.2
ENV GEOSERVER_DATA_DIR /var/local/geoserver
ENV GEOSERVER_INSTALL_DIR /usr/local/geoserver

# Uncomment to use APT cache (requires apt-cacher-ng on host)
#RUN echo "Acquire::http { Proxy \"http://`/sbin/ip route|awk '/default/ { print $3 }'`:3142\"; };" > /etc/apt/apt.conf.d/71-apt-cacher-ng

# Microsoft fonts
#RUN echo "deb http://httpredir.debian.org/debian stretch contrib" >> /etc/apt/sources.list
#RUN set -x \
#	&& apt-get update \
#	&& apt-get install -yq ttf-mscorefonts-installer \
#	&& rm -rf /var/lib/apt/lists/*

# SOGIS fonts
ADD fonts/* /usr/share/fonts/truetype/
RUN fc-cache -f && fc-list | sort

# GeoServer
ADD conf/geoserver.xml /usr/local/tomcat/conf/Catalina/localhost/geoserver.xml
RUN mkdir -p ${GEOSERVER_DATA_DIR} \
	&& mkdir ${GEOSERVER_INSTALL_DIR} \
	&& cd ${GEOSERVER_INSTALL_DIR} \
	&& wget http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-war.zip \
	&& unzip geoserver-${GEOSERVER_VERSION}-war.zip \
	&& unzip geoserver.war \
	&& rm -rf geoserver-${GEOSERVER_VERSION}-war.zip geoserver.war target *.txt

# Replace default data directory
RUN mkdir -p /tmp/gs_tmp
ADD data_dir /tmp/gs_tmp
RUN mv /tmp/gs_tmp/* ${GEOSERVER_DATA_DIR}

# GeoServer modules    
#RUN cd ${GEOSERVER_INSTALL_DIR}/WEB-INF/lib \
#    && wget http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-importer-plugin.zip \
#    && unzip -o geoserver-${GEOSERVER_VERSION}-importer-plugin.zip \
#    && rm -rf geoserver-${GEOSERVER_VERSION}-importer-plugin.zip \
#    && wget http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-monitor-plugin.zip \
#    && unzip -o geoserver-${GEOSERVER_VERSION}-monitor-plugin.zip \
#    && rm -rf geoserver-${GEOSERVER_VERSION}-monitor-plugin.zip 
#RUN cd ${GEOSERVER_INSTALL_DIR}/WEB-INF/lib \
#    && wget http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-pyramid-plugin.zip \
#    && unzip -o geoserver-${GEOSERVER_VERSION}-pyramid-plugin.zip \
#    && rm -rf geoserver-${GEOSERVER_VERSION}-pyramid-plugin.zip 

# Enable CORS
RUN sed -i '\:</web-app>:i\
<filter>\n\
    <filter-name>CorsFilter</filter-name>\n\
    <filter-class>org.apache.catalina.filters.CorsFilter</filter-class>\n\
    <init-param>\n\
        <param-name>cors.allowed.origins</param-name>\n\
        <param-value>*</param-value>\n\
    </init-param>\n\
    <init-param>\n\
        <param-name>cors.allowed.methods</param-name>\n\
        <param-value>GET,POST,HEAD,OPTIONS,PUT</param-value>\n\
    </init-param>\n\
</filter>\n\
<filter-mapping>\n\
    <filter-name>CorsFilter</filter-name>\n\
    <url-pattern>/*</url-pattern>\n\
</filter-mapping>' ${GEOSERVER_INSTALL_DIR}/WEB-INF/web.xml

# Tomcat environment
ENV CATALINA_OPTS "-server -Djava.awt.headless=true \
	-Xms2048m -Xmx2048m -XX:+UseConcMarkSweepGC -XX:NewSize=48m \
	-DGEOSERVER_DATA_DIR=${GEOSERVER_DATA_DIR}"

ADD start.sh /usr/local/bin/start.sh
CMD start.sh

EXPOSE 8080