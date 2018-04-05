using Gtk;

public class Fragments.Torrent : Object{

	private unowned Transmission.Torrent torrent;
	public bool removed = false;

	public int id { get{ return torrent.id; } }
	public string name { get; set; }
	public Transmission.Activity activity { get; set; }
	public uint eta { get; set; }
	public double progress { get; set; }
	public int seeders_active { get; set; }
	public int seeders { get; set; }
	public int leechers { get; set; }
	public string downloaded { get; set; }
	public string uploaded { get; set; }
	public string download_speed { get; set; }
	public string upload_speed { get; set; }
	public string size { get; set; }
	public int queue_position {	set{ torrent.queue_position = value; } }

	public string primary_text { get; set; }
	public string secondary_text { get; set; }
	public string seeders_text { get; set; }

	// Update interval
	public bool pause_torrent_update = false; // Don't update torrent information. Useful for dnd

	public Torrent(Transmission.Torrent torrent){
		this.torrent = torrent;

		update_torrent_activity();
		update_torrent_information();
	}

	private void reset_activity_timeout(){
		Timeout.add(100, () => { update_torrent_activity(); return false; });
	}

	private void reset_information_timeout(){
		Timeout.add_seconds(2, () => { update_torrent_information(); return false; });
	}

	public void pause(){
		torrent.stop();
	}

	public void unpause(){
		torrent.start();
	}

	public void remove(bool remove_downloaded_data){
		removed = true;
		notify_property("activity");
		torrent.remove(remove_downloaded_data, null);
		torrent = null;
	}

	public bool can_manual_update(){
		return torrent.can_manual_update;
	}

	public void manual_update(){
		torrent.manual_update();
	}

	public Transmission.info get_info(){
		return torrent.info;
	}

	public void update_torrent_activity(){
		if(torrent == null || torrent.stat == null){
			warning("Torrent %s: torrent or stat is NULL", name);
			return;
		}

		activity = torrent.stat_cached.activity;
		progress = torrent.stat_cached.percentDone;
		secondary_text = Utils.generate_secondary_text(this);

		reset_activity_timeout();
	}

	public void update_torrent_information(){
		if(torrent == null || torrent.stat == null){
			warning("Torrent %s: torrent or stat is NULL", name);
			return;
		}

		name = torrent.name;
		eta = torrent.stat_cached.eta;
		seeders_active = torrent.stat_cached.peersSendingToUs;
		seeders = torrent.stat_cached.peersConnected;
		leechers = torrent.stat_cached.peersGettingFromUs;
		downloaded = format_size(torrent.stat_cached.haveValid);
		uploaded = format_size(torrent.stat_cached.uploadedEver);
		size = format_size(torrent.stat_cached.sizeWhenDone);

		primary_text = Utils.generate_primary_text(this);
		seeders_text = _("%i (%i active)").printf(seeders, seeders_active);

		char[40] buf = new char[40];
		download_speed = Transmission.String.Units.speed_KBps (buf, torrent.stat_cached.pieceDownloadSpeed_KBps); notify_property("download-speed");
		upload_speed = Transmission.String.Units.speed_KBps (buf, torrent.stat_cached.pieceUploadSpeed_KBps); notify_property("upload-speed");

		reset_information_timeout();
	}
}