# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as rtorrent with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

rTorrent user account is present:
  user.present:
{%- for param, val in rtorrent.lookup.user.items() %}
{%-   if val is not none and param not in ["groups", "gid"] %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - usergroup: true
    - createhome: true
    - groups: {{ rtorrent.lookup.user.groups | json }}
    # (on Debian 11) subuid/subgid are only added automatically for non-system users
    - system: false
{%- if not rtorrent.lookup.media_group.gid %}]
    - gid: {{ rtorrent.lookup.user.gid or "null" }}
{%- else %}
    - gid: {{ rtorrent.lookup.media_group.gid }}
    - require:
      - group: {{ rtorrent.lookup.media_group.name }}
  group.present:
    - name: {{ rtorrent.lookup.media_group.name }}
    - gid: {{ rtorrent.lookup.media_group.gid }}
{%- endif %}
  file.append:
    - names:
      - {{ rtorrent.lookup.user.home | path_join(".bashrc") }}:
        - text:
          - export XDG_RUNTIME_DIR=/run/user/$(id -u)
          - export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus

      - {{ rtorrent.lookup.user.home | path_join(".bash_profile") }}:
        - text: |
            if [ -f ~/.bashrc ]; then
              . ~/.bashrc
            fi

    - require:
      - user: {{ rtorrent.lookup.user.name }}

rTorrent user session is initialized at boot:
  compose.lingering_managed:
    - name: {{ rtorrent.lookup.user.name }}
    - enable: {{ rtorrent.install.rootless }}
    - require:
      - user: {{ rtorrent.lookup.user.name }}

rTorrent paths are present:
  file.directory:
    - names:
      - {{ rtorrent.lookup.paths.base }}
      - {{ rtorrent.lookup.paths.data }}
      - {{ rtorrent.lookup.paths.downloads if rtorrent.lookup.paths.downloads is not mapping else rtorrent.lookup.paths.downloads | first }}:
        # Owner is not important for this formula since it relies on group
        # privileges. Forcing it might interfere with network mounts.
        - user: null
    - user: {{ rtorrent.lookup.user.name }}
    - group: __slot__:salt:user.primary_group({{ rtorrent.lookup.user.name }})
    - makedirs: true
    - require:
      - user: {{ rtorrent.lookup.user.name }}

{%- if rtorrent.install.podman_api %}

rTorrent podman API is enabled:
  compose.systemd_service_enabled:
    - name: podman.socket
    - user: {{ rtorrent.lookup.user.name }}
    - require:
      - rTorrent user session is initialized at boot

rTorrent podman API is available:
  compose.systemd_service_running:
    - name: podman.socket
    - user: {{ rtorrent.lookup.user.name }}
    - require:
      - rTorrent user session is initialized at boot
{%- endif %}

rTorrent compose file is managed:
  file.managed:
    - name: {{ rtorrent.lookup.paths.compose }}
    - source: {{ files_switch(
                    ["docker-compose.yml", "docker-compose.yml.j2"],
                    config=rtorrent,
                    lookup="rTorrent compose file is present",
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ rtorrent.lookup.rootgroup }}
    - makedirs: true
    - template: jinja
    - makedirs: true
    - context:
        rtorrent: {{ rtorrent | json }}

rTorrent is installed:
  compose.installed:
    - name: {{ rtorrent.lookup.paths.compose }}
{%- for param, val in rtorrent.lookup.compose.items() %}
{%-   if val is not none and param != "service" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
{%- if rtorrent.container.userns_keep_id and rtorrent.install.rootless and rtorrent.lookup.compose.create_pod is false %}
    - podman_create_args:
{#-     post-map.jinja ensures this is in pod_args if pods are in use #}
        # this maps the host uid/gid to the same ones inside the container
        # important for network share access
        # https://github.com/containers/podman/issues/5239#issuecomment-587175806
      - userns: keep-id
{%- endif %}
{%- for param, val in rtorrent.lookup.compose.service.items() %}
{%-   if val is not none %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - watch:
      - file: {{ rtorrent.lookup.paths.compose }}
{%- if rtorrent.install.rootless %}
    - user: {{ rtorrent.lookup.user.name }}
    - require:
      - user: {{ rtorrent.lookup.user.name }}
{%- endif %}

{%- if rtorrent.install.autoupdate_service is not none %}

Podman autoupdate service is managed for rTorrent:
{%-   if rtorrent.install.rootless %}
  compose.systemd_service_{{ "enabled" if rtorrent.install.autoupdate_service else "disabled" }}:
    - user: {{ rtorrent.lookup.user.name }}
{%-   else %}
  service.{{ "enabled" if rtorrent.install.autoupdate_service else "disabled" }}:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}
