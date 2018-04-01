using Gtk;

[GtkTemplate (ui = "/org/gnome/Fragments/ui/torrent.ui")]
public class Fragments.Torrent : Gtk.ListBoxRow{

	private unowned Transmission.Torrent torrent;
	public bool removed = false;

	// Torrent name
	[GtkChild] private Label name_label;
	public string name { get; set; }

	// Status
	public Transmission.Activity activity { get; set; }
	public uint eta { get{ return torrent.stat.eta; } }
	[GtkChild] private Label primary_label;
	[GtkChild] private Label secondary_label;

	// Progress
	[GtkChild] private ProgressBar progress_bar;
	public double progress { get{ return torrent.stat.percentDone; } }

	// Seeders
	[GtkChild] private Label seeders_label;
	public int seeders_active { get{ return torrent.stat.peersSendingToUs; } }
	public int seeders { get{ return torrent.stat.peersConnected; } }

	// Leechers
	[GtkChild] private Label leechers_label;
	public int leechers { get{ return torrent.stat.peersGettingFromUs; } }

	// Downloaded bytes
	[GtkChild] private Label downloaded_label;
	public uint64 downloaded { get{ return torrent.stat.haveValid; } }

	// Uploaded bytes
	[GtkChild] private Label uploaded_label;
	public uint64 uploaded { get{ return torrent.stat.uploadedEver; } }

	// Download speed
	[GtkChild] private Label download_speed_label;
	private string _download_speed;
	public string download_speed {
		get{
			char[40] buf = new char[40];
			_download_speed = Transmission.String.Units.speed_KBps (buf, torrent.stat.pieceDownloadSpeed_KBps);
			return _download_speed;
		}
	}

	// Upload speed
	[GtkChild] private Label upload_speed_label;
	private string _upload_speed;
	public string upload_speed {
		get{
			char[40] buf = new char[40];
			_upload_speed = Transmission.String.Units.speed_KBps (buf, torrent.stat.pieceUploadSpeed_KBps);
			return _upload_speed;
		}
	}

	// Torrent size
	public uint64 size { get{ return torrent.stat.sizeWhenDone; } }

	// Manual update
	[GtkChild] private Button manual_update_button;

	// Update interval
	private const int search_delay = 1;
	private uint delayed_changed_id;

	// Don't update torrent information. Useful for dnd.
	public bool pause_torrent_update = false;

	// Other
	[GtkChild] private Image mime_type_image;
	[GtkChild] private Image turboboost_image;
	[GtkChild] private Revealer revealer;
	[GtkChild] private Stack primary_action_stack;
	[GtkChild] private Stack secondary_action_stack;
	[GtkChild] private Button open_button;
	[GtkChild] private Button remove_button;
	[GtkChild] public EventBox eventbox;
	[GtkChild] public Stack index_stack;
	[GtkChild] public Label index_label;

	public Torrent(Transmission.Torrent torrent){
		this.torrent = torrent;
		name = torrent.name;
		name_label.set_text(name);

		set_mime_type_image();

		// default activity is STOPPED, so it wouldn't trigger the activity notify for stopped torrents
		activity = Transmission.Activity.CHECK;

		connect_signals();
		update_information();
	}

	private void reset_timeout(){
		if(delayed_changed_id > 0) Source.remove(delayed_changed_id);
		delayed_changed_id = Timeout.add_seconds(search_delay, update_information);
	}

	private void connect_signals(){
		this.notify["activity"].connect(() => {
			switch(activity){
				case Transmission.Activity.STOPPED: {
					index_stack.set_visible_child_name("stopped");
					primary_action_stack.set_visible_child_name("continue");
					secondary_action_stack.set_visible_child_name("remove");
					break;
				}
				case Transmission.Activity.DOWNLOAD: {
					index_stack.set_visible_child_name("download");
					primary_action_stack.set_visible_child_name("pause");
					secondary_action_stack.set_visible_child_name("remove");
					break;
				}
				case Transmission.Activity.DOWNLOAD_WAIT: {
					index_stack.set_visible_child_name("indexnumber");
					primary_action_stack.set_visible_child_name("pause");
					secondary_action_stack.set_visible_child_name("remove");
					break;
				}
				case Transmission.Activity.CHECK: {
					index_stack.set_visible_child_name("check");
					primary_action_stack.set_visible_child_name("pause");
					secondary_action_stack.set_visible_child_name("remove");
					break;
				}
				case Transmission.Activity.CHECK_WAIT: {
					index_stack.set_visible_child_name("check");
					primary_action_stack.set_visible_child_name("pause");
					secondary_action_stack.set_visible_child_name("remove");
					break;
				}
				case Transmission.Activity.SEED: {
					index_stack.set_visible_child_name("upload");
					primary_action_stack.set_visible_child_name("remove");
					secondary_action_stack.set_visible_child_name("pause");
					break;
				}
				case Transmission.Activity.SEED_WAIT: {
					index_stack.set_visible_child_name("upload");
					primary_action_stack.set_visible_child_name("remove");
					secondary_action_stack.set_visible_child_name("pause");
					break;
				}
			}
		});

		eventbox.drag_begin.connect(() => {
			Timeout.add(1, () =>{ this.set_visible(false); return false; });
			pause_torrent_update = true;
		});

		eventbox.drag_end.connect(() => {
			this.set_visible(true);
			pause_torrent_update = false;
		});
	}

	public void toggle_revealer (){
		revealer.set_reveal_child(!revealer.get_reveal_child());
	}

	[GtkCallback]
	private void remove_button_clicked(){
		remove_torrent();
	}

	[GtkCallback]
	private void pause_button_clicked(){
		torrent.stop();
	}

	[GtkCallback]
	private void continue_button_clicked(){
		torrent.start();
	}

	private void remove_torrent(){
		Gtk.MessageDialog msg = new Gtk.MessageDialog (App.window, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE, "");

		msg.secondary_text = _("Once removed, continuing the transfer will require the torrent file or magnet link.");
		msg.text = _("Remove Torrent?");

		msg.add_button(_("Cancel"), 0);
		msg.add_button(_("Remove"), 1);

		Box message_area = (Box)msg.get_message_area();
		CheckButton checkbutton = new CheckButton.with_label(_("Remove downloaded data as well"));
		checkbutton.set_visible(true);
		message_area.add(checkbutton);

		msg.response.connect ((response_id) => {
			if(response_id == 1){
				torrent.remove(checkbutton.active, null);
				torrent = null;
				removed = true;
				notify_property("activity");
			}
			msg.destroy();
		});
		msg.show ();
	}

	[GtkCallback]
	private void manual_update_button_clicked(){
		if(torrent.can_manual_update)
			torrent.manual_update();
		else
			manual_update_button.set_sensitive(false);
	}

	[GtkCallback]
	private void open_button_clicked(){
		//TODO: Implement open button
	}

	[GtkCallback]
	private bool turboboost_switch_state_set(){
		return false;
	}

	public void set_mime_type_image(){
		// determine mime type
		string mime_type = "application/x-bittorrent";
		if(torrent.info == null) mime_type = "application/x-bittorrent";
		if (torrent.info.files.length > 1) mime_type = "inode/directory";

		var files = torrent.info.files;
		if (files != null && files.length > 0) {
			bool certain = false;
			mime_type = ContentType.guess (files[0].name, null, out certain);
		}

		// check if icon is available, and set the correct icon
		IconTheme icontheme = new IconTheme();
		if(icontheme.has_icon(ContentType.get_generic_icon_name(mime_type)))
			mime_type_image.set_from_gicon(ContentType.get_symbolic_icon(mime_type), Gtk.IconSize.MENU);
		else
			mime_type_image.set_from_gicon(ContentType.get_symbolic_icon("text-x-generic"), Gtk.IconSize.MENU);
	}

	private string get_primary_text(){
		if(downloaded == 0)
			return format_size(size);
		else if (downloaded == size)
			return _("%s uploaded · %s").printf(format_size(uploaded), upload_speed);
		else if (activity == Transmission.Activity.STOPPED || activity == Transmission.Activity.DOWNLOAD_WAIT)
			return _("%s of %s downloaded").printf(format_size(downloaded), format_size(size));
		else
			return _("%s of %s downloaded · %s").printf(format_size(downloaded), format_size(size), download_speed);
	}

	private string get_secondary_text(){
		string st = "";
		switch(torrent.stat.activity){
			case Transmission.Activity.STOPPED: { st = _("Paused"); break;}
			case Transmission.Activity.DOWNLOAD: { if(eta != uint.MAX || eta == 0) st = _("%s left".printf(Utils.time_to_string(eta))); break;}
			case Transmission.Activity.DOWNLOAD_WAIT: { st = _("Queued"); break;}
			case Transmission.Activity.CHECK: { st = _("Checking…"); break;}
			case Transmission.Activity.CHECK_WAIT: { st = _("Queued"); break;}
		}
		return st;
	}

	private bool update_information(){
		if(torrent == null) return false;

		reset_timeout();
		if(pause_torrent_update || torrent.stat == null) return false;

		if(this.activity != torrent.stat.activity){
			this.activity = torrent.stat.activity;
			notify_property("activity");
		}

		primary_label.set_text(get_primary_text());
		secondary_label.set_text(get_secondary_text());
		progress_bar.set_fraction(progress);

		download_speed_label.set_text(download_speed);
		upload_speed_label.set_text(upload_speed);

		downloaded_label.set_text(format_size(downloaded));
		uploaded_label.set_text(format_size(uploaded));

		leechers_label.set_text(leechers.to_string());
		seeders_label.set_text(_("%i (%i active)").printf(seeders, seeders_active));

		return false;
	}
}