public class Fragments.Utils{

        public static string time_to_string (uint total_seconds) {
                uint seconds = (total_seconds % 60);
                uint minutes = (total_seconds % 3600) / 60;
                uint hours = (total_seconds % 86400) / 3600;
                uint days = (total_seconds % (86400 * 30)) / 86400;

                var str_days = ngettext ("%u day", "%u days", days).printf (days);
                var str_hours = ngettext ("%u hour", "%u hours", hours).printf (hours);
                var str_minutes = ngettext ("%u minute", "%u minutes", minutes).printf (minutes);
                var str_seconds = ngettext ("%u second", "%u seconds", seconds).printf (seconds);

                if (days > 0) return "%s, %s".printf (str_days, str_hours);
                if (hours > 0) return "%s, %s".printf (str_hours, str_minutes);
                if (minutes > 0) return "%s".printf (str_minutes);
                if (seconds > 0) return str_seconds;
                return "";
	}

	public static string generate_primary_text(Torrent torrent){
		if(torrent.downloaded == 0)
			return format_size(torrent.size);
		else if (torrent.downloaded == torrent.size)
			return _("%s uploaded · %s").printf(format_size(torrent.uploaded), torrent.upload_speed);
		else if (torrent.activity == Transmission.Activity.STOPPED || torrent.activity == Transmission.Activity.DOWNLOAD_WAIT)
			return _("%s of %s downloaded").printf(format_size(torrent.downloaded), format_size(torrent.size));
		else
			return _("%s of %s downloaded · %s").printf(format_size(torrent.downloaded), format_size(torrent.size), torrent.download_speed);
	}

	public static string generate_secondary_text(Torrent torrent){
		string st = "";
		switch(torrent.activity){
			case Transmission.Activity.STOPPED: { st = _("Paused"); break;}
			case Transmission.Activity.DOWNLOAD: { if(torrent.eta != uint.MAX || torrent.eta == 0) st = _("%s left".printf(Utils.time_to_string(torrent.eta))); break;}
			case Transmission.Activity.DOWNLOAD_WAIT: { st = _("Queued"); break;}
			case Transmission.Activity.CHECK: { st = _("Checking…"); break;}
			case Transmission.Activity.CHECK_WAIT: { st = _("Queued"); break;}
		}
		return st;
	}

	public static void remove_torrent_from_liststore(ListStore store, Torrent torrent){
		for(int i = 0; i < store.get_n_items(); i++){
			if(store.get_object(i) == torrent) store.remove(i);
		}
	}

	public static string get_clipboard_text(Window window){
		Gdk.Display display = window.get_display ();
		Gtk.Clipboard clipboard = Gtk.Clipboard.get_for_display (display, Gdk.SELECTION_CLIPBOARD);

		return clipboard.wait_for_text ();
	}

	public static void clear_clipboard(Window window){
		Gdk.Display display = window.get_display ();
		Gtk.Clipboard clipboard = Gtk.Clipboard.get_for_display (display, Gdk.SELECTION_CLIPBOARD);
		clipboard.set_text("", 0);
	}
}