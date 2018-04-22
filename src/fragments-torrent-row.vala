using Gtk;

[GtkTemplate (ui = "/de/haeckerfelix/Fragments/ui/torrent-row.ui")]
public class Fragments.TorrentRow : Gtk.ListBoxRow{

	private unowned Torrent torrent;

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

	public TorrentRow(Torrent torrent){
		this.torrent = torrent;
		connect_signals();
		set_mime_type_image();
		update_activity();
	}

	private void connect_signals(){
		torrent.notify["activity"].connect(update_activity);

		torrent.bind_property ("name", name_label, "label", BindingFlags.SYNC_CREATE);
		torrent.bind_property("progress", progress_bar, "fraction", BindingFlags.SYNC_CREATE);
		torrent.bind_property("leechers", leechers_label, "label", BindingFlags.SYNC_CREATE);
		torrent.bind_property("downloaded", downloaded_label, "label", BindingFlags.SYNC_CREATE);
		torrent.bind_property("uploaded", uploaded_label, "label", BindingFlags.SYNC_CREATE);
		torrent.bind_property("download-speed", download_speed_label, "label", BindingFlags.SYNC_CREATE);
		torrent.bind_property("upload-speed", upload_speed_label, "label", BindingFlags.SYNC_CREATE);
		torrent.bind_property("primary-text",  primary_label, "label", BindingFlags.SYNC_CREATE);
		torrent.bind_property("secondary-text",  secondary_label, "label", BindingFlags.SYNC_CREATE);
		torrent.bind_property("seeders-text",  seeders_label, "label", BindingFlags.SYNC_CREATE);

		continue_button.clicked.connect(() => { torrent.unpause(); });
		pause_button.clicked.connect(() => { torrent.pause(); });
		pause2_button.clicked.connect(() => { torrent.pause(); });
		remove_button.clicked.connect(remove_torrent);
		remove2_button.clicked.connect(remove_torrent);

		manual_update_button.clicked.connect(() => {
			if(torrent.can_manual_update()) torrent.manual_update();
			else manual_update_button.set_sensitive(false);
		});
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