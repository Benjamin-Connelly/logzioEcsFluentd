FROM fluent/fluentd:stable
RUN apk add --update --virtual .build-deps \
    sudo build-base ruby-dev \
    && sudo gem install \
    fluent-plugin-concat \
    fluent-plugin-logzio \
    fluent-plugin-record-reformer \
    fluent-plugin-record-modifier \
    fluent-plugin-ecs-metadata-filter \
    fluent-plugin-detect-exceptions \
    && sudo gem sources --clear-all \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/* \
    /home/fluent/.gem/ruby/2.3.0/cache/*.gem
COPY fluent.conf /fluentd/etc/fluent.conf
 
COPY entrypoint.sh /bin/entrypoint.sh
CMD fluentd -c /fluentd/etc/${FLUENTD_CONF} $FLUENTD_OPT
