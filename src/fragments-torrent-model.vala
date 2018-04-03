public class Fragments.TorrentModel : Object, ListModel{
	private Queue<Torrent> torrents;

	public TorrentModel(){
		torrents = new Queue<Torrent>();
	}

	public void add_torrent(Torrent torrent){
		torrents.push_tail(torrent);
		items_changed(torrents.get_length() - 1, 0, 1);
	}

	public void remove_torrent(Torrent torrent){
		if(torrents.index(torrent) == -1) return;
		items_changed(torrents.index(torrent), 1, 0);
		torrents.remove(torrent);
	}

	public Type get_item_type () {
        return typeof(Torrent);
    }

	public Object? get_item(uint position){
		var torrent = torrents.peek_nth(position);
		return torrent;
	}

	public uint get_n_items(){
		return torrents.length;
	}

	public void move_item(uint old_position, uint new_position){
		if (old_position == new_position) return;
		torrents.push_nth(torrents.pop_nth(old_position), (int)new_position);
		items_changed(old_position, 1, 0);
		items_changed(new_position, 0, 1);
	}
}