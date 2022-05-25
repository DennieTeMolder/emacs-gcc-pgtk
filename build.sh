#!/usr/bin/env sh
docker build --no-cache -t dennietm/emacs-gcc-pgtk:latest .
id=$(docker create dennietm/emacs-gcc-pgtk)
docker cp $id:/opt/deploy .
