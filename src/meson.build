vala_sources = [
  'fragments-app.vala',
  'fragments-utils.vala',
  'fragments-torrent.vala',
  'fragments-torrent-group.vala',
  'fragments-torrent-manager.vala',
  'fragments-torrent-listbox.vala',
  'fragments-settings-window.vala',
  'fragments-torrent-row.vala',
  'fragments-settings.vala',
  'fragments-window.vala'
]

deps = [
  gtk_dep,
  gio_unix_dep,
  transmission_dep,
  valac.find_library('config', dirs: vapi_dir),
]

c_args = [
  '-DVERSION="' + meson.project_version() + '"',
  '-DGETTEXT_PACKAGE="gradio"',
  '-DGNOMELOCALEDIR="' + get_option('prefix') + '/' + get_option('localedir') + '"'
]

vala_args = [
  '--target-glib=2.38'
]

executable(
  meson.project_name(),
  vala_sources + resources,
  dependencies: deps,
  vala_args: vala_args,
  c_args: c_args,
  install: true
)

