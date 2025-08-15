FROM onlyoffice/documentserver:9.0.4 AS documentserver

RUN apt-get -y update && apt-get -y install git nodejs npm

RUN full_ver=$(dpkg -s onlyoffice-documentserver | awk -F': ' '/^Version:/ {print $2}') && ver=$(echo "$full_ver" | cut -d'-' -f1) && number=$(echo "$full_ver" | cut -d'-' -f2) && \
    git clone https://github.com/ONLYOFFICE/server.git /tmp/server && cd /tmp/server && \
    sed -i \
      -e "s/const buildVersion = '.*';/const buildVersion = '$ver';/" \
      -e "s/const buildNumber = .*/const buildNumber = $number;/" \
      Common/sources/commondefines.js && \
    sed -i "s|const buildDate = '.*';|const buildDate = '$(date +"%m/%d/%Y")';|" Common/sources/license.js && \
    sed -i 's/exports\.LICENSE_CONNECTIONS = 20;/exports.LICENSE_CONNECTIONS = 9999;/; s/exports\.LICENSE_USERS = 20;/exports.LICENSE_USERS = 9999;/' Common/sources/constants.js && \
    npm i -g @yao-pkg/pkg && \ 
    npm i && \
    cd Common && npm i && npm i axios --save && \
    cd ../DocService && npm i && \
    pkg . -t node20-linux --options max_old_space_size=4096 -o docservice && \
    cp docservice /var/www/onlyoffice/documentserver/server/DocService/docservice && \
    rm -rf /tmp/server

RUN sed -i 's/isSupportEditFeature=()=>!1/isSupportEditFeature=()=>!0/g' /var/www/onlyoffice/documentserver/web-apps/apps/*/mobile/dist/js/app.js;

RUN rm -rf /var/www/onlyoffice/documentserver-example \
    && rm -rf /etc/onlyoffice/documentserver-example \
    && rm -f /etc/nginx/includes/ds-example.conf \
