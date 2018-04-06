public class Fragments.TorrentManager : Object{

	private Transmission.variant_dict settings;
	private Transmission.Session session;
	private static string CONFIG_DIR = GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S, Environment.get_user_config_dir(), "fragments");

	public TorrentModel stopped_torrents;
	public TorrentModel check_wait_torrents;
	public TorrentModel check_torrents;
	public TorrentModel download_wait_torrents;
	public TorrentModel download_torrents;
	public TorrentModel seed_torrents;
	public TorrentModel seed_wait_torrents;

	public uint torrent_count {get; set;}

	public TorrentManager(){
		Transmission.String.Units.mem_init(1024, _("KB"), _("MB"), _("GB"), _("TB"));
		Transmission.String.Units.speed_init(1024, _("KB/s"), _("MB/s"), _("GB/s"), _("TB/s"));

		settings = Transmission.variant_dict(0);
		Transmission.load_default_settings(ref settings, CONFIG_DIR, "fragments");

		session = new Transmission.Session(CONFIG_DIR, false, settings);
		if(App.settings.download_folder == "") App.settings.download_folder = Environment.get_user_special_dir(GLib.UserDirectory.DOWNLOAD);
		if(App.settings.incomplete_folder == "") App.settings.incomplete_folder = Path.build_path (Path.DIR_SEPARATOR_S, Environment.get_user_cache_dir(), "fragments", "incomplete_torrents").to_string();

		stopped_torrents = new TorrentModel();
		check_wait_torrents = new TorrentModel();
		check_torrents = new TorrentModel();
		download_wait_torrents = new TorrentModel();
		download_torrents = new TorrentModel();
		seed_torrents = new TorrentModel();
		seed_wait_torrents = new TorrentModel();

		update_transmission_settings();
		restore_torrents();

		connect_signals();
	}

	public void close_session(){
		message("Close transmission session...");
		update_transmission_settings();
		session = null;
	}

	private void connect_signals(){
		stopped_torrents.items_changed.connect(update_torrent_count);
		check_wait_torrents.items_changed.connect(update_torrent_count);
		check_torrents.items_changed.connect(update_torrent_count);
		download_wait_torrents.items_changed.connect(update_torrent_count);
		download_torrents.items_changed.connect(update_torrent_count);
		seed_torrents.items_changed.connect(update_torrent_count);
		seed_wait_torrents.items_changed.connect(update_torrent_count);

		App.settings.notify["max-downloads"].connect(update_transmission_settings);
		download_wait_torrents.items_changed.connect(update_torrent_queue);
	}

	private void update_transmission_settings(){
		message("Apply session settings...");
		settings.add_int (Transmission.Prefs.download_queue_size, App.settings.max_downloads);
		settings.add_str(Transmission.Prefs.download_dir, App.settings.download_folder);
		settings.add_str(Transmission.Prefs.incomplete_dir, App.settings.incomplete_folder);
		settings.add_bool(Transmission.Prefs.rpc_enabled, true);

		message("Save session settings...");
		session.save_settings(CONFIG_DIR, settings);
		session.update_settings (settings);
	}

	private void restore_torrents(){
		message("Restore old torrents...");
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
		stopped_torrents.remove_torrent(torrent);
		check_wait_torrents.remove_torrent(torrent);
		check_torrents.remove_torrent(torrent);
		download_wait_torrents.remove_torrent(torrent);
		download_torrents.remove_torrent(torrent);
		seed_wait_torrents.remove_torrent(torrent);
		seed_torrents.remove_torrent(torrent);

		if(torrent.removed){
			return;
		}

		switch(torrent.activity){
			case Transmission.Activity.STOPPED: stopped_torrents.add_torrent(torrent); break;
			case Transmission.Activity.CHECK_WAIT: check_wait_torrents.add_torrent(torrent); break;
			case Transmission.Activity.CHECK: check_torrents.add_torrent(torrent); break;
			case Transmission.Activity.DOWNLOAD_WAIT: download_wait_torrents.add_torrent(torrent); break;
			case Transmission.Activity.DOWNLOAD: download_torrents.add_torrent(torrent); break;
			case Transmission.Activity.SEED_WAIT: seed_wait_torrents.add_torrent(torrent); break;
			case Transmission.Activity.SEED: seed_torrents.add_torrent(torrent); break;
		}
	}

	private void update_torrent_count(){
		torrent_count = stopped_torrents.get_n_items()
			+ check_wait_torrents.get_n_items()
			+ check_torrents.get_n_items()
			+ download_wait_torrents.get_n_items()
			+ download_torrents.get_n_items()
			+ seed_wait_torrents.get_n_items()
			+ seed_torrents.get_n_items();
	}

	private void update_torrent_queue(){
		message("Update torrent queue...");
		for(int i = 0; i < download_wait_torrents.get_n_items(); i++){
			Torrent torrent = (Torrent)download_wait_torrents.get_item(i);
			torrent.queue_position = i;
		}
	}
}