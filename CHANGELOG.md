# Changelog

## 0.2.42 (2026-11-24)

First release of the Railway template.

- Doca 0.2.42, official image `smartdoca/doca:0.2.42@sha256:fa06a4aefadbaa05186b6e4497dbdf06f55ad192075cd2935e32528f9903d483`.
- SQLite, AI memory, plugins and files on a Railway volume at `/data`.
- Administrator created on the first boot from generated variables; default site language English, time zone UTC.
- `/health` answers Railway's health check; LibreOffice and WeasyPrint are disabled below 900 MB of RAM.
