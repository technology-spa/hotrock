FROM fluent/fluentd:v1.5-debian-1

# Use root account to use apt
USER root

RUN buildDeps="sudo make gcc g++ libc-dev ruby-dev" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $buildDeps \
 && sudo gem install \
    fluent-plugin-elasticsearch:3.5.2 --no-document \
    fluent-plugin-beats:1.1.0 --no-document \
    fluent-plugin-remote_syslog:1.0.0 --no-document \
    fluent-plugin-multi-format-parser:1.0.0 --no-document \
    fluent-plugin-rewrite-tag-filter:2.2.0 --no-document \
 && sudo gem sources --clear-all \
 && SUDO_FORCE_REMOVE=yes \
    apt-get purge -y --auto-remove \
      -o APT::AutoRemove::RecommendsImportant=false \
      $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
           /home/fluent/.gem/ruby/2.3.0/cache/*.gem

USER fluent
