# Deprecated

This document is no longer relevant for latest builds. If you see it, update
your images.

# INSTALL WIZARD

## TL;DR

Once all wine/silverlight download/installation windows close (by themselves),
close this browser window. A new and better one will be opened.

## Long story

Pipelight runs Silverlight installation in the background. Only once it's
finished, the plugin can be used. Moreover, it might require running ``sudo
pipelight-plugin --create-mozilla-plugins`` first. To achieve all this, a
Silverlight-enabled page is opened along with the installation wizard. All the
installation should be finished before you end reading this text (depending on
networkd speed and such). Then, you should close this window, allowing firefox
process to exit so that it discovers the now-ready-to-use Pipelight-provided
Silverlight plugin.
