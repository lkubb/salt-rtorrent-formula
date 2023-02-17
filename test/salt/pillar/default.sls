# vim: ft=yaml
---
rtorrent:
  lookup:
    master: template-master
    # Just for testing purposes
    winner: lookup
    added_in_lookup: lookup_value
    compose:
      create_pod: null
      pod_args: null
      project_name: rtorrent
      remove_orphans: true
      build: false
      build_args: null
      pull: false
      service:
        container_prefix: null
        ephemeral: true
        pod_prefix: null
        restart_policy: on-failure
        restart_sec: 2
        separator: null
        stop_timeout: null
    paths:
      base: /opt/containers/rtorrent
      compose: docker-compose.yml
      config_rtorrent: rtorrent.env
      config_flood: flood.env
      data: data
      downloads: downloads
      watch: watch
    user:
      groups: []
      home: null
      name: rtorrent
      shell: /usr/sbin/nologin
      uid: null
      gid: null
    containers:
      flood:
        image: docker.io/jesec/flood:latest
      rtorrent:
        image: docker.io/jesec/rtorrent:latest
    media_group:
      gid: 3414
      name: mediarr
  install:
    rootless: true
    autoupdate: true
    autoupdate_service: false
    remove_all_data_for_sure: false
    podman_api: true
  config:
    dht_mode: auto
    dht_port: 49999
    max_dl_slots: 20
    max_dl_slots_gl: 100
    max_peers_dl: 100
    max_peers_seed: 50
    max_ul_slots: 20
    max_ul_slots_gl: 100
    max_xmlrpc: 10M
    min_peers_dl: 1
    min_peers_seed: 1
    peer_exchange: true
    port: 49999
    trackers_udp: true
    umask: '0002'
    unix_socket: true
  container:
    pgid: null
    puid: null
    userns_keep_id: true
  flood:
    allowedpath: null
    assets: null
    auth: null
    baseuri: null
    clientpoll: null
    clientpollidle: null
    dbclean: null
    host: null
    maxhistorystates: null
    port: 7004
    rthost: null
    rtport: null
    rtsocket: /config/.local/share/rtorrent/rtorrent.sock
    rundir: null
    secret: null
    ssl: null
    sslcert: null
    sslkey: null

  tofs:
    # The files_switch key serves as a selector for alternative
    # directories under the formula files directory. See TOFS pattern
    # doc for more info.
    # Note: Any value not evaluated by `config.get` will be used literally.
    # This can be used to set custom paths, as many levels deep as required.
    files_switch:
      - any/path/can/be/used/here
      - id
      - roles
      - osfinger
      - os
      - os_family
    # All aspects of path/file resolution are customisable using the options below.
    # This is unnecessary in most cases; there are sensible defaults.
    # Default path: salt://< path_prefix >/< dirs.files >/< dirs.default >
    #         I.e.: salt://rtorrent/files/default
    # path_prefix: template_alt
    # dirs:
    #   files: files_alt
    #   default: default_alt
    # The entries under `source_files` are prepended to the default source files
    # given for the state
    # source_files:
    #   rtorrent-config-file-file-managed:
    #     - 'example_alt.tmpl'
    #     - 'example_alt.tmpl.jinja'

    # For testing purposes
    source_files:
      rTorrent environment file is managed:
      - rtorrent.env.j2

  # Just for testing purposes
  winner: pillar
  added_in_pillar: pillar_value
