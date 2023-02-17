Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``rtorrent``
^^^^^^^^^^^^
*Meta-state*.

This installs the rtorrent, flood containers,
manages their configuration and starts their services.


``rtorrent.package``
^^^^^^^^^^^^^^^^^^^^
Installs the rtorrent, flood containers only.
This includes creating systemd service units.


``rtorrent.config``
^^^^^^^^^^^^^^^^^^^
Manages the configuration of the rtorrent, flood containers.
Has a dependency on `rtorrent.package`_.


``rtorrent.service``
^^^^^^^^^^^^^^^^^^^^
Starts the rtorrent, flood container services
and enables them at boot time.
Has a dependency on `rtorrent.config`_.


``rtorrent.clean``
^^^^^^^^^^^^^^^^^^
*Meta-state*.

Undoes everything performed in the ``rtorrent`` meta-state
in reverse order, i.e. stops the rtorrent, flood services,
removes their configuration and then removes their containers.


``rtorrent.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the rtorrent, flood containers
and the corresponding user account and service units.
Has a depency on `rtorrent.config.clean`_.
If ``remove_all_data_for_sure`` was set, also removes all data.


``rtorrent.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the configuration of the rtorrent, flood containers
and has a dependency on `rtorrent.service.clean`_.

This does not lead to the containers/services being rebuilt
and thus differs from the usual behavior.


``rtorrent.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^
Stops the rtorrent, flood container services
and disables them at boot time.


