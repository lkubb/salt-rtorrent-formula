# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_file = tplroot ~ ".config.file" %}
{%- from tplroot ~ "/map.jinja" import mapdata as rtorrent with context %}

include:
  - {{ sls_config_file }}

rTorrent service is enabled:
  compose.enabled:
    - name: {{ rtorrent.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if rtorrent.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ rtorrent.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
    - require:
      - rTorrent is installed
{%- if rtorrent.install.rootless %}
    - user: {{ rtorrent.lookup.user.name }}
{%- endif %}

rTorrent service is running:
  compose.running:
    - name: {{ rtorrent.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if rtorrent.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ rtorrent.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if rtorrent.install.rootless %}
    - user: {{ rtorrent.lookup.user.name }}
{%- endif %}
    - watch:
      - rTorrent is installed
      - sls: {{ sls_config_file }}
