using Gtk;

[GtkTemplate (ui = "/org/gnome/Fragments/ui/torrent-row.ui")]
public class Fragments.TorrentRow : Gtk.ListBoxRow{

	private Torrent torrent;

	[GtkChild] private Label name_label;
	[GtkChild] private Label primary_label;
	[GtkChild] private Label secondary_label;
	[GtkChild] private ProgressBar progress_bar;
	[GtkChild] private Label seeders_label;
	[GtkChild] private Label leechers_label;
	[GtkChild] private Label downloaded_label;
	[GtkChild] private Label uploaded_label;
	[GtkChild] private Label download_speed_label;
	[GtkChild] private Label upload_speed_label;
	[GtkChild] private Button manual_update_button;

	[GtkChild] private Box title_box;
	[GtkChild] private Image mime_type_image;
	[GtkChild] private Revealer revealer;
	[GtkChild] private Stack primary_action_stack;
	[GtkChild] private Stack secondary_action_stack;
	[GtkChild] private Button remove_button;
	[GtkChild] private Button remove2_button;
	[GtkChild] private Button pause_button;
	[GtkChild] private Button pause2_button;
	[GtkChild] private Button continue_button;
	[GtkChild] public EventBox eventbox;
	[GtkChild] public Stack index_stack;
	[GtkChild] public Label index_label;

	// Update interval
	private const int search_delay = 1;
	private uint delayed_changed_id;
	public bool pause_torrent_update = false; // Don't update torrent information. Useful for dnd

	public TorrentRow(Torrent torrent){
		this.torrent = torrent;
		connect_signals();
		reset_timeout();
		set_mime_type_image();
		update_activity();
	}

	private void connect_signals(){
		torrent.notify["name"].connect(() => { name_label.set_text(torrent.name); });
		torrent.notify["progress"].connect(() => { progress_bar.set_fraction(torrent.progress); });
		torrent.notify["seeders_active"].connect(() => { seeders_label.set_text(_("%i (%i active)").printf(torrent.seeders, torrent.seeders_active)); });
		torrent.notify["seeders"].connect(() => { seeders_label.set_text(_("%i (%i active)").printf(torrent.seeders, torrent.seeders_active)); });
		torrent.notify["leechers"].connect(() => { leechers_label.set_text(torrent.leechers.to_string()); });
		torrent.notify["downloaded"].connect(() => { downloaded_label.set_text(format_size(torrent.downloaded)); });
		torrent.notify["uploaded"].connect(() => { uploaded_label.set_text(format_size(torrent.uploaded)); });
		torrent.notify["download-speed"].connect(() => { download_speed_label.set_text(torrent.download_speed); });
		torrent.notify["upload-speed"].connect(() => { upload_speed_label.set_text(torrent.upload_speed); });

		torrent.information_updated.connect(() => {
			primary_label.set_text(Utils.generate_primary_text(torrent));
			secondary_label.set_text(Utils.generate_secondary_text(torrent));
		});


		torrent.notify["activity"].connect(update_activity);

		eventbox.drag_begin.connect(() => {
			Timeout.add(1, () =>{ this.set_visible(false); return false; });
			pause_torrent_update = true;
		});

		eventbox.drag_end.connect(() => {
			this.set_visible(true);
			pause_torrent_update = false;
		});

		pause_button.clicked.connect(() => { torrent.pause(); });
		pause2_button.clicked.connect(() => { torrent.pause(); });

		remove_button.clicked.connect(remove_torrent);
		remove2_button.clicked.connect(remove_torrent);

		continue_button.clicked.connect(() => { torrent.unpause(); });

		manual_update_button.clicked.connect(() => {
			if(torrent.can_manual_update()) torrent.manual_update();
			else manual_update_button.set_sensitive(false);
		});
	}

	private void reset_timeout(){
		if(delayed_changed_id > 0) Source.remove(delayed_changed_id);
		delayed_changed_id = Timeout.add_seconds(search_delay, () => { torrent.update_information(); reset_timeout(); return false; });
	}

	public void toggle_revealer (){
		revealer.set_reveal_child(!revealer.get_reveal_child());
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
				torrent.remove(checkbutton.active);
				torrent = null;
				notify_property("activity");
			}
			msg.destroy();
		});
		msg.show ();
	}

	public void set_mime_type_image(){
		// determine mime type
		string mime_type = "application/x-bittorrent";
		Transmission.info info = torrent.get_info();

		//if(info == null) mime_type = "application/x-bittorrent";
		if (info.files.length > 1) mime_type = "inode/directory";

		var files = info.files;
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

	private void update_activity(){
		this.get_style_context().remove_class("queued-torrent");
		title_box.get_style_context().remove_class("dim-label");

		switch(torrent.activity){
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

				this.get_style_context().add_class("queued-torrent");
				break;
			}
			case Transmission.Activity.CHECK: {
				index_stack.set_visible_child_name("check");
				primary_action_stack.set_visible_child_name("pause");
				secondary_action_stack.set_visible_child_name("remove");

				this.get_style_context().add_class("queued-torrent");
				title_box.get_style_context().add_class("dim-label");
				break;
			}
			case Transmission.Activity.CHECK_WAIT: {
				index_stack.set_visible_child_name("check");
				primary_action_stack.set_visible_child_name("pause");
				secondary_action_stack.set_visible_child_name("remove");

				this.get_style_context().add_class("queued-torrent");
				title_box.get_style_context().add_class("dim-label");
				break;
			}
			case Transmission.Activity.STOPPED: {
				index_stack.set_visible_child_name("stopped");
				primary_action_stack.set_visible_child_name("continue");
				secondary_action_stack.set_visible_child_name("remove");

				this.get_style_context().add_class("queued-torrent");
				title_box.get_style_context().add_class("dim-label");
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
	}
}