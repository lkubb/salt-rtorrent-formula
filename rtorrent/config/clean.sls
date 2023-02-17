# vim: ft=sls

{#-
    Removes the configuration of the rtorrent, flood containers
    and has a dependency on `rtorrent.service.clean`_.

    This does not lead to the containers/services being rebuilt
    and thus differs from the usual behavior.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_service_clean = tplroot ~ ".service.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as rtorrent with context %}

include:
  - {{ sls_service_clean }}

rTorrent environment files are absent:
  file.absent:
    - names:
      - {{ rtorrent.lookup.paths.config_rtorrent }}
      - {{ rtorrent.lookup.paths.config_flood }}
      - {{ rtorrent.lookup.paths.data | path_join(".rtorrent.rc") }}
    - require:
      - sls: {{ sls_service_clean }}
