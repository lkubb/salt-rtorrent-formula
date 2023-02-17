# vim: ft=sls


{#-
    Stops the rtorrent, flood container services
    and disables them at boot time.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as rtorrent with context %}

rtorrent service is dead:
  compose.dead:
    - name: {{ rtorrent.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if rtorrent.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ rtorrent.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if rtorrent.install.rootless %}
    - user: {{ rtorrent.lookup.user.name }}
{%- endif %}

rtorrent service is disabled:
  compose.disabled:
    - name: {{ rtorrent.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if rtorrent.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ rtorrent.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if rtorrent.install.rootless %}
    - user: {{ rtorrent.lookup.user.name }}
{%- endif %}
