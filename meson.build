project(
  'fragments', ['vala', 'c'],
  version: '1.1',
  license: 'GPL3',
  meson_version: '>= 0.40.0'
)

message('Build libtransmission. Please wait, this will take a moment…')
build = run_command('sh', 'build-aux/build_libtransmission.sh')
if build.returncode() != 0
  message('Build failed. Please create new issue with complete build log at: https://github.com/haecker-felix/Fragments/issues/new')
  error(build.stderr())
else
  message(build.stdout())
  message('Build libtransmission - OK!')
endif

gnome = import('gnome')
i18n = import('i18n')

cc = meson.get_compiler('c')
valac = meson.get_compiler('vala')

vapi_dir = join_paths (meson.source_root (), 'src', 'vapis')
po_dir = join_paths(meson.source_root(), 'po')

# Fragments dependencies
glib_dep = dependency('glib-2.0', version : '>=2.38')
gobject_dep = dependency('gobject-2.0')
gio_dep = dependency('gio-2.0')
gio_unix_dep = dependency('gio-unix-2.0')
gtk_dep = dependency('gtk+-3.0', version : '>=3.20.10')

subdir('submodules')
subdir('data')
subdir('po')
subdir('src')

meson.add_install_script('build-aux/postinstall.py')
