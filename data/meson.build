# Resources
resources = gnome.compile_resources(
  'org.gnome.Fragments',
  'org.gnome.Fragments.gresource.xml',
  c_name: 'resources'
)

# Settings schema
install_data('org.gnome.Fragments.gschema.xml', install_dir : get_option('datadir') + '/glib-2.0/schemas/')

# Desktop file
i18n.merge_file(
  'org.gnome.Fragments.desktop',
  type: 'desktop',
  input: 'org.gnome.Fragments.desktop.in',
  output: 'org.gnome.Fragments.desktop',
  po_dir: po_dir,
  install: true,
  install_dir: join_paths(get_option('datadir'), 'applications')
)

# Appdata
i18n.merge_file(
  'org.gnome.Fragments.appdata.xml',
  input: 'org.gnome.Fragments.appdata.xml.in',
  output: 'org.gnome.Fragments.appdata.xml',
  po_dir: po_dir,
  install: true,
  install_dir: join_paths(get_option('datadir'), 'metainfo')
)

# Icons
install_subdir('icons/hicolor/', install_dir: join_paths (get_option('datadir'), 'icons'))