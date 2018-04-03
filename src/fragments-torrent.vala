using Gtk;

public class Fragments.Torrent : Object{

	private unowned Transmission.Torrent torrent;

	public string name { get; set; }
	public Transmission.Activity activity { get; set; }
	public uint eta { get; set; }
	public double progress { get; set; }
	public int seeders_active { get; set; }
	public int seeders { get; set; }
	public int leechers { get; set; }
	public uint64 downloaded { get; set; }
	public uint64 uploaded { get; set; }
	public string download_speed { get; set; }
	public string upload_speed { get; set; }
	public uint64 size { get; set; }

	public signal void information_updated();

	public Torrent(Transmission.Torrent torrent){
		this.torrent = torrent;
		update_information();
		notify_property("activity");
	}

	public void pause(){
		torrent.stop();
	}

	public void unpause(){
		torrent.start();
	}

	public void remove(bool remove_downloaded_data){
		torrent.remove(remove_downloaded_data, null);
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

		if(activity != torrent.stat.activity){
			activity = torrent.stat.activity;
			notify_property("activity"); //TODO: why?
		}

		name = torrent.name; notify_property("name");
		eta = torrent.stat.eta; notify_property("eta");
		progress = torrent.stat.percentDone; notify_property("progress");
		seeders_active = torrent.stat.peersSendingToUs; notify_property("seeders-active");
		seeders = torrent.stat.peersConnected; notify_property("seeders");
		leechers = torrent.stat.peersGettingFromUs; notify_property("leechers");
		downloaded = torrent.stat.haveValid; notify_property("downloaded");
		uploaded = torrent.stat.uploadedEver; notify_property("uploaded");
		size = torrent.stat.sizeWhenDone; notify_property("size");

		char[40] buf = new char[40];
		download_speed = Transmission.String.Units.speed_KBps (buf, torrent.stat.pieceDownloadSpeed_KBps); notify_property("download-speed");
		upload_speed = Transmission.String.Units.speed_KBps (buf, torrent.stat.pieceUploadSpeed_KBps); notify_property("upload-speed");

		information_updated();
	}
}