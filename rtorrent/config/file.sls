# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as rtorrent with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

rTorrent environment files are managed:
  file.managed:
    - names:
      - {{ rtorrent.lookup.paths.config_rtorrent }}:
        - source: {{ files_switch(
                        ["rtorrent.env", "rtorrent.env.j2"],
                        config=rtorrent,
                        lookup="rtorrent environment file is managed",
                        indent_width=10,
                     )
                  }}
      - {{ rtorrent.lookup.paths.config_flood }}:
        - source: {{ files_switch(
                        ["flood.env", "flood.env.j2"],
                        config=rtorrent,
                        lookup="flood environment file is managed",
                        indent_width=10,
                     )
                  }}
    - mode: '0640'
    - user: root
    - group: __slot__:salt:user.primary_group({{ rtorrent.lookup.user.name }})
    - makedirs: true
    - template: jinja
    - require:
      - user: {{ rtorrent.lookup.user.name }}
    - require_in:
      - rTorrent is installed
    - context:
        rtorrent: {{ rtorrent | json }}

rTorrent config file is managed:
  file.managed:
    - name: {{ rtorrent.lookup.paths.data | path_join(".rtorrent.rc") }}
    - source: {{ files_switch(
                    ["rtorrent.rc", "rtorrent.rc.j2"],
                    config=rtorrent,
                    lookup="rTorrent config file is managed",
                 )
              }}
    - mode: '0640'
    - user: root
    - group: __slot__:salt:user.primary_group({{ rtorrent.lookup.user.name }})
    - makedirs: true
    - template: jinja
    - require:
      - user: {{ rtorrent.lookup.user.name }}
    - context:
        rtorrent: {{ rtorrent | json }}
