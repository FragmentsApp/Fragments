public class Fragments.TorrentManager{

	private Transmission.variant_dict settings;
	private Transmission.Session session;

	private static string CONFIG_DIR = GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S, Environment.get_user_config_dir(), "fragments");

	public GLib.ListStore stopped_torrents;
	public GLib.ListStore check_wait_torrents;
	public GLib.ListStore check_torrents;
	public GLib.ListStore download_wait_torrents;
	public GLib.ListStore download_torrents;
	public GLib.ListStore seed_torrents;
	public GLib.ListStore seed_wait_torrents;

	public TorrentManager(){
		Transmission.String.Units.mem_init(1024, _("KB"), _("MB"), _("GB"), _("TB"));
		Transmission.String.Units.speed_init(1024, _("KB/s"), _("MB/s"), _("GB/s"), _("TB/s"));

		settings = Transmission.variant_dict(0);
		Transmission.load_default_settings(ref settings, CONFIG_DIR, "fragments");

		session = new Transmission.Session(CONFIG_DIR, false, settings);
		if(App.settings.download_folder == "") App.settings.download_folder = Environment.get_user_special_dir(GLib.UserDirectory.DOWNLOAD);
		if(App.settings.incomplete_folder == "") App.settings.incomplete_folder = Environment.get_user_cache_dir();

		stopped_torrents = new GLib.ListStore(typeof (Torrent));
		check_wait_torrents = new GLib.ListStore(typeof (Torrent));
		check_torrents = new GLib.ListStore(typeof (Torrent));
		download_wait_torrents = new GLib.ListStore(typeof (Torrent));
		download_torrents = new GLib.ListStore(typeof (Torrent));
		seed_torrents = new GLib.ListStore(typeof (Torrent));
		seed_wait_torrents = new GLib.ListStore(typeof (Torrent));

		update_transmission_settings();
		connect_signals();
	}

	public void close_session(){
		message("Close transmission session...");
		update_transmission_settings();
		session = null;
	}

	private void connect_signals(){
		App.settings.notify["max-downloads"].connect(update_transmission_settings);
	}

	private void update_transmission_settings(){
		message("Apply session settings...");
		settings.add_int (Transmission.Prefs.download_queue_size, App.settings.max_downloads);
		settings.add_str(Transmission.Prefs.download_dir, App.settings.download_folder);
		settings.add_str(Transmission.Prefs.incomplete_dir, App.settings.incomplete_folder);

		message("Save session settings...");
		session.save_settings(CONFIG_DIR, settings);
		session.update_settings (settings);
	}

	public void restore_torrents(){
		var torrent_constructor = new Transmission.TorrentConstructor (session);
		unowned Transmission.Torrent[] transmission_torrents = session.load_torrents (torrent_constructor);
		for (int i = 0; i < transmission_torrents.length; i++) {
			var torrent = new Torrent(transmission_torrents[i]);
			torrent.notify["activity"].connect(() => { update_torrent(torrent); });
			update_torrent(torrent);
		}
	}

	public void add_torrent_by_path(string path){
		message("Adding torrent by file \"%s\"...", path);

		var torrent_constructor = new Transmission.TorrentConstructor (session);
		torrent_constructor.set_metainfo_from_file (path);
		add_torrent(ref torrent_constructor);
	}

	public void add_torrent_by_magnet(string magnet){
		message("Adding torrent by magnet link \"%s\"...", magnet);

		var torrent_constructor = new Transmission.TorrentConstructor (session);
		torrent_constructor.set_metainfo_from_magnet_link (magnet);
		add_torrent(ref torrent_constructor);
	}

	public string get_magnet_name(string magnet){
		var torrent_constructor = new Transmission.TorrentConstructor (null);
		torrent_constructor.set_metainfo_from_magnet_link (magnet);

		string torrent_name = "";

		Transmission.info info;
		Transmission.ParseResult result = torrent_constructor.parse (out info);

		if (result == Transmission.ParseResult.OK) torrent_name = info.name;
		return torrent_name;
	}

	private void add_torrent(ref Transmission.TorrentConstructor torrent_constructor){
		Transmission.ParseResult result;
		int duplicate_id;
		unowned Transmission.Torrent torrent = torrent_constructor.instantiate (out result, out duplicate_id);

		if (result == Transmission.ParseResult.OK) {
			var ftorrent = new Fragments.Torrent(torrent);
			ftorrent.notify["activity"].connect(() => { update_torrent(ftorrent); });
			update_torrent(ftorrent);
		}else{
			warning("Could not add torrent: " + result.to_string());
		}
	}

	private void update_torrent(Torrent torrent){
		Utils.remove_torrent_from_liststore(stopped_torrents, torrent);
		Utils.remove_torrent_from_liststore(check_wait_torrents, torrent);
		Utils.remove_torrent_from_liststore(check_torrents, torrent);
		Utils.remove_torrent_from_liststore(download_wait_torrents, torrent);
		Utils.remove_torrent_from_liststore(download_torrents, torrent);
		Utils.remove_torrent_from_liststore(seed_wait_torrents, torrent);
		Utils.remove_torrent_from_liststore(seed_torrents, torrent);

		if(torrent.removed == true){
			torrent.destroy();
			return;
		}

		switch(torrent.activity){
			case Transmission.Activity.STOPPED: stopped_torrents.append(torrent); break;
			case Transmission.Activity.CHECK_WAIT: check_wait_torrents.append(torrent); break;
			case Transmission.Activity.CHECK: check_torrents.append(torrent); break;
			case Transmission.Activity.DOWNLOAD_WAIT: download_wait_torrents.append(torrent); break;
			case Transmission.Activity.DOWNLOAD: download_torrents.append(torrent); break;
			case Transmission.Activity.SEED_WAIT: seed_wait_torrents.append(torrent); break;
			case Transmission.Activity.SEED: seed_torrents.append(torrent); break;
		}

		torrent.show_all();
	}
}