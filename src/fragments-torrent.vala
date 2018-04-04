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
	private const int search_delay = 1;
	private uint delayed_changed_id;
	public bool pause_torrent_update = false; // Don't update torrent information. Useful for dnd

	public Torrent(Transmission.Torrent torrent){
		this.torrent = torrent;
		update_information();
	}

	private void reset_timeout(){
		if(delayed_changed_id > 0) Source.remove(delayed_changed_id);
		delayed_changed_id = Timeout.add_seconds(search_delay, () => { update_information(); return false; });
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

	public void update_information(){
		if(torrent == null || torrent.stat == null){
			warning("Torrent %s: torrent or stat is NULL", name);
			return;
		}

		activity = torrent.stat.activity;
		name = torrent.name;
		eta = torrent.stat.eta;
		progress = torrent.stat.percentDone;
		seeders_active = torrent.stat.peersSendingToUs;
		seeders = torrent.stat.peersConnected;
		leechers = torrent.stat.peersGettingFromUs;
		downloaded = format_size(torrent.stat.haveValid);
		uploaded = format_size(torrent.stat.uploadedEver);
		size = format_size(torrent.stat.sizeWhenDone);

		primary_text = Utils.generate_primary_text(this);
		secondary_text = Utils.generate_secondary_text(this);
		seeders_text = _("%i (%i active)").printf(seeders, seeders_active);

		char[40] buf = new char[40];
		download_speed = Transmission.String.Units.speed_KBps (buf, torrent.stat.pieceDownloadSpeed_KBps); notify_property("download-speed");
		upload_speed = Transmission.String.Units.speed_KBps (buf, torrent.stat.pieceUploadSpeed_KBps); notify_property("upload-speed");

		reset_timeout();
	}
}