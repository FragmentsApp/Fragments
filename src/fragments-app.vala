using Gtk;
using GLib;

public class Fragments.App : Gtk.Application {

	public static Fragments.Window window;
	public static Settings settings;

	private TorrentManager manager;

	public App(){
		application_id = "de.haeckerfelix.Fragments"; flags = ApplicationFlags.HANDLES_OPEN;
	}

	protected override void startup () {
		base.startup ();

		settings = new Settings();
		setup_actions();
		manager = new TorrentManager();
	}

	protected override void activate (){
		ensure_window();
		window.present();
	}

	public override void open (File[] files, string hint) {
		activate();

		if (files[0].has_uri_scheme ("magnet")) {
			var magnet = files[0].get_uri ();
			magnet = magnet.replace ("magnet:///?", "magnet:?");
			manager.add_torrent_by_magnet(magnet);
		}else{
			foreach (var file in files) {
				manager.add_torrent_by_path (file.get_path());
			}
		}
	}

	private void ensure_window(){
		if (get_windows () != null) return;

		window = new Fragments.Window(this, ref manager);
		this.add_window(window);
	}

	private void setup_actions () {
		var action = new GLib.SimpleAction ("preferences", null);
		action.activate.connect (() => {
			var settings_window = new SettingsWindow();
			settings_window.set_transient_for(App.window);
			settings_window.set_modal(true);
			settings_window.set_visible(true);
		});
		this.add_action (action);

		action = new GLib.SimpleAction ("about", null);
		action.activate.connect (() => { this.show_about_dialog (); });
		this.add_action (action);

		action = new GLib.SimpleAction ("quit", null);
		action.activate.connect (this.quit);
		this.add_action (action);

		// Setup Appmenu
		var builder = new Gtk.Builder.from_resource ("/de/haeckerfelix/Fragments/interface/app-menu.ui");
		var app_menu = builder.get_object ("app-menu") as GLib.MenuModel;
		set_app_menu (app_menu);
	}

	private void show_about_dialog(){
		string[] authors = {
			"Felix Häcker <haecker.felix1207@gmail.com>"
		};

		string[] artists = {
			"Tobias Bernard <tbernard@gnome.org>"
		};

		Gtk.show_about_dialog (window,
			logo_icon_name: "de.haeckerfelix.Fragments",
			program_name: "Fragments",
			comments: _("A BitTorrent Client"),
			authors: authors,
			artists: artists,
			website: "https://github.com/FragmentsApp/Fragments",
			website_label: _("GitHub Homepage"),
			version: Config.VERSION,
			license_type: License.GPL_3_0);
	}

	public static int main (string[] args){
		Gtk.init(ref args);

		var app = new App ();
		return app.run(args);
	}
}
