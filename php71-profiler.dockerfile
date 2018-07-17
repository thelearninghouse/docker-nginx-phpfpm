FROM learninghouse/nginx-phpfpm:7.1
LABEL Maintainer="Michael Bunch <mbunch@learninghouse.com>"

# Install Blackfire.io Probe
COPY scripts/install_blackfire.sh /root
RUN chmod 775 /root/install_blackfire.sh && \
    /root/install_blackfire.sh && \
    rm /root/install_blackfire.sh
