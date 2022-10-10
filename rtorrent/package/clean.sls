# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as rtorrent with context %}

include:
  - {{ sls_config_clean }}

{%- if rtorrent.install.autoupdate_service %}

Podman autoupdate service is disabled for rTorrent:
{%-   if rtorrent.install.rootless %}
  compose.systemd_service_disabled:
    - user: {{ rtorrent.lookup.user.name }}
{%-   else %}
  service.disabled:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}

rTorrent is absent:
  compose.removed:
    - name: {{ rtorrent.lookup.paths.compose }}
    - volumes: {{ rtorrent.install.remove_all_data_for_sure }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if rtorrent.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ rtorrent.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if rtorrent.install.rootless %}
    - user: {{ rtorrent.lookup.user.name }}
{%- endif %}
    - require:
      - sls: {{ sls_config_clean }}

rTorrent compose file is absent:
  file.absent:
    - name: {{ rtorrent.lookup.paths.compose }}
    - require:
      - rTorrent is absent

rTorrent user session is not initialized at boot:
  compose.lingering_managed:
    - name: {{ rtorrent.lookup.user.name }}
    - enable: false
    - onlyif:
      - fun: user.info
        name: {{ rtorrent.lookup.user.name }}

rTorrent user account is absent:
  user.absent:
    - name: {{ rtorrent.lookup.user.name }}
    - purge: {{ rtorrent.install.remove_all_data_for_sure }}
    - require:
      - rTorrent is absent
    - retry:
        attempts: 5
        interval: 2

{%- if rtorrent.install.remove_all_data_for_sure %}

rTorrent paths are absent:
  file.absent:
    - names:
      - {{ rtorrent.lookup.paths.base }}
    - require:
      - rTorrent is absent
{%- endif %}
