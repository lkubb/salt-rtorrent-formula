# vim: ft=sls

{#-
    Starts the rtorrent, flood container services
    and enables them at boot time.
    Has a dependency on `rtorrent.config`_.
#}

include:
  - .running
