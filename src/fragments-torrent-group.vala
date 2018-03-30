using Gtk;

[GtkTemplate (ui = "/org/gnome/Fragments/ui/torrent-group.ui")]
public class Fragments.TorrentGroup : Gtk.Box{

	[GtkChild] private Label title_label;
	List<GLib.ListStore> model_list = new List<GLib.ListStore> ();

	public TorrentGroup(string title){
		title_label.set_text(title);
	}

	public void add_subgroup(GLib.ListStore torrents, bool rearrangeable){
		var torrent_listbox = new TorrentListBox(rearrangeable);
		torrent_listbox.show_all();
		model_list.append(torrents);

		torrents.items_changed.connect((pos,removed,added) => {
			if(removed == 1) torrent_listbox.remove_torrent((Torrent)torrent_listbox.get_row_at_index((int)pos));
			if(added == 1) torrent_listbox.insert_torrent((Torrent)torrents.get_item(pos), (int)pos);
			update_visibility();
		});

		torrent_listbox.row_activated.connect((row) => {
			((Torrent)row).toggle_revealer();
		});

		this.pack_start(torrent_listbox, false, true, 0);
		update_visibility();
	}

	private void update_visibility(){
		bool empty = true;

		foreach(GLib.ListStore model in model_list){
			if(model.get_n_items() != 0) empty = false;
		}

		this.set_visible(!empty);
	}
}
