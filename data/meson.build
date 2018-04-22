# Resources
resources = gnome.compile_resources(
  'de.haeckerfelix.Fragments',
  'de.haeckerfelix.Fragments.gresource.xml',
  c_name: 'resources'
)

# Settings schema
install_data('de.haeckerfelix.Fragments.gschema.xml', install_dir : get_option('datadir') + '/glib-2.0/schemas/')

# Desktop file
i18n.merge_file(
  'de.haeckerfelix.Fragments.desktop',
  type: 'desktop',
  input: 'de.haeckerfelix.Fragments.desktop.in',
  output: 'de.haeckerfelix.Fragments.desktop',
  po_dir: po_dir,
  install: true,
  install_dir: join_paths(get_option('datadir'), 'applications')
)

# Appdata
i18n.merge_file(
  'de.haeckerfelix.Fragments.appdata.xml',
  input: 'de.haeckerfelix.Fragments.appdata.xml.in',
  output: 'de.haeckerfelix.Fragments.appdata.xml',
  po_dir: po_dir,
  install: true,
  install_dir: join_paths(get_option('datadir'), 'metainfo')
)

# Icons
install_subdir('icons/hicolor/', install_dir: join_paths (get_option('datadir'), 'icons'))