public class Fragments.Settings : GLib.Object{

	private GLib.Settings settings;

	private bool _enable_dark_theme;
	private string _download_folder;
	private string _incomplete_folder;
	private int _max_downloads;

	public Settings(){
		settings = new GLib.Settings ("org.gnome.Fragments");

		_enable_dark_theme = settings.get_boolean("enable-dark-theme");
		_download_folder = settings.get_string("download-folder");
		_incomplete_folder = settings.get_string("incomplete-folder");
		_max_downloads = settings.get_int("max-downloads");
	}

	public bool enable_dark_theme{
		get{ return _enable_dark_theme;	}
		set{
			_enable_dark_theme = value;
			settings.set_boolean ("enable-dark-theme", value);
		}
	}

	public string download_folder{
		get{ return _download_folder;	}
		set{
			_download_folder = value;
			settings.set_string ("download-folder", value);
		}
	}

	public string incomplete_folder{
		get{ return _incomplete_folder;	}
		set{
			_incomplete_folder = value;
			settings.set_string ("incomplete-folder", value);
		}
	}

	public int max_downloads{
		get{ return _max_downloads;	}
		set{
			_max_downloads = value;
			settings.set_int ("max-downloads", value);
		}
	}

	public void apply () {
		settings.apply();
	}
}

