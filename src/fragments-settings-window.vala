using Gtk;

[GtkTemplate (ui = "/de/haeckerfelix/Fragments/ui/settings-window.ui")]
public class Fragments.SettingsWindow : Gtk.Window {

	[GtkChild] private Switch dark_theme_switch;
	[GtkChild] private SpinButton max_downloads_spinbutton;
	[GtkChild] private Button download_folder_button;
	[GtkChild] private Label download_folder_label;

	public SettingsWindow () {
		this.show_all();

		dark_theme_switch.active = App.settings.enable_dark_theme;
		max_downloads_spinbutton.value = App.settings.max_downloads;
		download_folder_label.set_text(App.settings.download_folder);

		connect_signals();
	}

	private void connect_signals(){
		dark_theme_switch.state_set.connect(() => {
			App.settings.enable_dark_theme = dark_theme_switch.active;
			return false;
		});

		max_downloads_spinbutton.value_changed.connect(() => {
			App.settings.max_downloads = (int)max_downloads_spinbutton.value;
		});

		download_folder_button.clicked.connect(() => {
			Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog (_("Select download folder"), this, Gtk.FileChooserAction.SELECT_FOLDER);
			chooser.add_button (_("Cancel"), Gtk.ResponseType.CANCEL);
			chooser.add_button (_("Open"), Gtk.ResponseType.ACCEPT);
			chooser.set_default_response (Gtk.ResponseType.ACCEPT);
		    	chooser.set_current_folder(App.settings.download_folder);

			if (chooser.run () == Gtk.ResponseType.ACCEPT) {
				App.settings.download_folder = chooser.get_current_folder();
				download_folder_label.set_text(chooser.get_current_folder());
			}

			chooser.close ();
			chooser.destroy();
		});
	}
}

