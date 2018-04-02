using Gtk;

[GtkTemplate (ui = "/org/gnome/Fragments/ui/torrent-group.ui")]
public class Fragments.TorrentGroup : Gtk.Box{

	[GtkChild] private Label title_label;
	List<GLib.ListStore> model_list = new List<GLib.ListStore> ();

	public TorrentGroup(string title){
		title_label.set_text(title);
	}

	public void add_subgroup(GLib.ListStore torrents, bool rearrangeable){
		model_list.append(torrents);

		var torrent_listbox = new TorrentListBox(rearrangeable);
		torrent_listbox.bind_model(torrents, (torrent) => {
			TorrentRow row = new TorrentRow((Torrent)torrent);
			if(rearrangeable){
				drag_source_set (row.eventbox, Gdk.ModifierType.BUTTON1_MASK, TorrentListBox.entries, Gdk.DragAction.MOVE);
				row.eventbox.drag_begin.connect (torrent_listbox.row_drag_begin);
				row.eventbox.drag_data_get.connect (torrent_listbox.row_drag_data_get);
				row.eventbox.drag_end.connect(torrent_listbox.row_drag_end);
			}
			return row;
		});

		torrent_listbox.row_activated.connect((row) => {
			((TorrentRow)row).toggle_revealer();
		});

		torrents.items_changed.connect(() => {
			torrent_listbox.update_index_number();
			update_visibility();
		});

		this.pack_start(torrent_listbox, false, true, 0);
		torrent_listbox.show_all();
		update_visibility();
	}

	private void update_visibility(){
		bool empty = true;
		message("update visibiley");

		foreach(GLib.ListStore model in model_list){
			if(model.get_n_items() != 0) empty = false;
		}

		this.set_visible(!empty);
	}
}
