using Gtk;

[GtkTemplate (ui = "/org/gnome/Fragments/ui/window.ui")]
public class Fragments.Window : Gtk.ApplicationWindow {

	private TorrentManager manager;
	[GtkChild] private Gtk.Box torrent_group_box;

	[GtkChild] private Stack notification_stack;
	[GtkChild] private Label magnet_notification_label;
	[GtkChild] private Revealer notification_revealer;

	public Window (App app, ref TorrentManager manager) {
		GLib.Object(application: app);

		this.manager = manager;
		this.show_all();

		var provider = new CssProvider ();
		provider.load_from_resource ("/org/gnome/Fragments/interface/adwaita.css");
		StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);

		var icon_theme  = Gtk.IconTheme.get_default ();
		icon_theme.add_resource_path ("/org/gnome/Fragments/data/icons/");

		TorrentGroup downloading_group = new TorrentGroup(_("Downloading"));
		TorrentGroup seeding_group = new TorrentGroup(_("Seeding"));
		TorrentGroup queued_group = new TorrentGroup(_("Queued"));

		torrent_group_box.pack_start(downloading_group, false, false, 0);
		torrent_group_box.pack_start(queued_group, false, false, 0);
		torrent_group_box.pack_start(seeding_group, false, false, 0);

		queued_group.add_subgroup(manager.download_wait_torrents, true);
		queued_group.add_subgroup(manager.stopped_torrents, false);
		queued_group.add_subgroup(manager.check_wait_torrents, false);
		queued_group.add_subgroup(manager.check_torrents, false);

		downloading_group.add_subgroup(manager.download_torrents, false);
		seeding_group.add_subgroup(manager.seed_torrents, false);

		update_gtk_theme();
		connect_signals();
	}

	private void connect_signals(){
		App.settings.notify["enable-dark-theme"].connect(update_gtk_theme);
		this.focus_in_event.connect(check_for_magnet_link);
	}

	private void update_gtk_theme(){
		var gtk_settings = Gtk.Settings.get_default ();
		gtk_settings.gtk_application_prefer_dark_theme = App.settings.enable_dark_theme;
	}

	[GtkCallback]
	private void open_torrent_button_clicked(){
		var filech = new Gtk.FileChooserDialog (_("Open torrents"), this, Gtk.FileChooserAction.OPEN);
		filech.set_select_multiple (true);
		filech.add_button (_("Cancel"), Gtk.ResponseType.CANCEL);
		filech.add_button (_("Open"), Gtk.ResponseType.ACCEPT);
		filech.set_default_response (Gtk.ResponseType.ACCEPT);
		filech.set_current_folder_uri (GLib.Environment.get_home_dir ());

		var all_files_filter = new Gtk.FileFilter ();
		all_files_filter.set_filter_name (_("All files"));
		all_files_filter.add_pattern ("*");
		var torrent_files_filter = new Gtk.FileFilter ();
		torrent_files_filter.set_filter_name (_("Torrent files"));
		torrent_files_filter.add_mime_type ("application/x-bittorrent");
		filech.add_filter (torrent_files_filter);
		filech.add_filter (all_files_filter);

		if (filech.run () == Gtk.ResponseType.ACCEPT) {
			foreach (string filename in filech.get_filenames()) {
				manager.add_torrent_by_path(filename);
			}
		}

		filech.close ();
	}

	private bool check_for_magnet_link(){
		message("Check for magnet link in clipboard...");
		string torrent_name = manager.get_magnet_name(Utils.get_clipboard_text(this));

		if(torrent_name != null && torrent_name != ""){
			message("Detected torrent: " + torrent_name);
			show_magnet_notification(torrent_name);
		}

		return false;
	}

	private void show_magnet_notification(string torrent_name){
		notification_stack.set_visible_child_name("add-magnet");
		magnet_notification_label.set_markup(_("Add magnet link <b>\"%s\"</b> from clipboard?").printf(torrent_name));
		notification_revealer.set_reveal_child(true);
	}

	[GtkCallback]
	private void add_magnet_button_clicked(){
		manager.add_torrent_by_magnet(Utils.get_clipboard_text(this));
		Utils.clear_clipboard(this);
		notification_revealer.set_reveal_child(false);
	}

	[GtkCallback]
	private void close_magnet_notification_button_clicked(){
		Utils.clear_clipboard(this);
		notification_revealer.set_reveal_child(false);
	}
}