#!/usr/bin/python3
"""Music notification card with the album art as a blurred background.

Usage:
  music-toast.py            preview the current MixMusic track once
  music-toast.py --watch    show a card for every MixMusic track change
  music-toast.py --hold MS  hold time for the preview (default 6500)

The card is a GTK3 layer-shell surface on the focused output.  It listens on
D-Bus for MixMusic's own notifications and falls back to MPRIS track changes,
so it works whether or not the app emits notifications.
"""
import io
import json
import os
import subprocess
import sys
import threading

import cairo
import gi

gi.require_version('Gtk', '3.0')
gi.require_version('GtkLayerShell', '0.1')
gi.require_version('Pango', '1.0')
gi.require_version('PangoCairo', '1.0')

from gi.repository import Gtk, Gdk, GdkPixbuf, GLib, GtkLayerShell, Pango, PangoCairo
from PIL import Image, ImageEnhance, ImageFilter, ImageOps

W, H = 360, 78
RADIUS, PAD, ICON, ICON_R = 16, 14, 48, 10
FONT = "JetBrainsMono Nerd Font Mono"
TOP_GAP = 10  # below the waybar


# ---------------------------------------------------------------- metadata
def playerctl(*args):
    try:
        return subprocess.run(
            ("playerctl", "-p", "mixmusic", *args),
            capture_output=True, text=True, timeout=3,
        ).stdout.strip()
    except Exception:
        return ""


def track():
    t = playerctl("metadata", "--format",
                  "{{title}}\n{{artist}}\n{{album}}\n{{mpris:artUrl}}").split("\n")
    t += [""] * (4 - len(t))
    return {"title": t[0], "artist": t[1], "album": t[2], "art": t[3]}


def art_path(uri):
    if not uri:
        return None
    if uri.startswith("file://"):
        uri = uri[7:]
    return uri if os.path.isfile(uri) else None


def notifications_enabled():
    try:
        with open(os.path.expanduser("~/.config/MixMusic/settings.json")) as f:
            return json.load(f).get("notifications", True)
    except Exception:
        return True


# ------------------------------------------------------------- image prep
def _pixbuf(image):
    buf = io.BytesIO()
    image.save(buf, "PNG")
    loader = GdkPixbuf.PixbufLoader()
    loader.write(buf.getvalue())
    loader.close()
    return loader.get_pixbuf()


def backdrop(path):
    """Cover fitted to the card, blurred hard, darkened, darker on the text side."""
    im = Image.open(path).convert("RGB")
    im = ImageOps.fit(im, (W * 2, H * 2), method=Image.LANCZOS)
    im = im.filter(ImageFilter.GaussianBlur(20))
    im = ImageEnhance.Brightness(im).enhance(0.55)
    im = ImageEnhance.Color(im).enhance(1.2)

    grad = Image.linear_gradient("L").rotate(90, expand=True).resize((W * 2, H * 2))
    grad = grad.point(lambda v: 76 + (198 - 76) * v / 255)  # 30% -> 78% black
    im = Image.composite(Image.new("RGB", im.size, (0, 0, 0)), im, grad)
    return _pixbuf(im)


def icon_pixbuf(path):
    im = Image.open(path).convert("RGB")
    im = ImageOps.fit(im, (ICON * 2, ICON * 2), method=Image.LANCZOS)
    return _pixbuf(im)


# ------------------------------------------------------------------ drawing
def rounded(cr, x, y, w, h, r):
    cr.new_sub_path()
    cr.arc(x + w - r, y + r, r, -1.570796, 0)
    cr.arc(x + w - r, y + h - r, r, 0, 1.570796)
    cr.arc(x + r, y + h - r, r, 1.570796, 3.141593)
    cr.arc(x + r, y + r, r, 3.141593, 4.712389)
    cr.close_path()


def focused_output_monitor(display):
    """Monitor of sway's focused output, matched by screen geometry."""
    try:
        uid = os.getuid()
        sock = os.environ.get("SWAYSOCK") or next(
            (os.path.join(f"/run/user/{uid}", f)
             for f in os.listdir(f"/run/user/{uid}") if f.startswith("sway-ipc.")), None)
        if not sock:
            return None
        env = dict(os.environ, SWAYSOCK=sock)
        ws = subprocess.run(("swaymsg", "-r", "-t", "get_workspaces"),
                            capture_output=True, text=True, env=env, timeout=3).stdout
        focused = next(w for w in json.loads(ws) if w.get("focused"))
        outs = subprocess.run(("swaymsg", "-r", "-t", "get_outputs"),
                              capture_output=True, text=True, env=env, timeout=3).stdout
        out = next(o for o in json.loads(outs) if o["name"] == focused["output"])
        r = out["rect"]
        return display.get_monitor_at_point(r["x"] + r["width"] // 2, r["y"] + 20)
    except Exception:
        return None


class Toast:
    def __init__(self, quit_when_done=False):
        self.t = {}
        self.bg = None
        self.cover = None
        self.timer = None
        self.quit_when_done = quit_when_done

        self.win = Gtk.Window()
        self.win.set_decorated(False)
        self.win.set_resizable(False)
        self.win.set_skip_taskbar_hint(True)
        self.win.set_skip_pager_hint(True)
        self.win.set_app_paintable(True)
        self.win.set_visual(self.win.get_screen().get_rgba_visual())
        self.win.override_background_color(Gtk.StateFlags.NORMAL, Gdk.RGBA(0, 0, 0, 0))

        self.area = Gtk.DrawingArea()
        self.area.set_size_request(W, H)
        self.area.add_events(Gdk.EventMask.BUTTON_PRESS_MASK)
        self.area.connect("draw", self.draw)
        self.area.connect("button-press-event", lambda *a: self.hide())
        self.win.add(self.area)

        GtkLayerShell.init_for_window(self.win)
        GtkLayerShell.set_namespace(self.win, "music-toast")
        GtkLayerShell.set_layer(self.win, GtkLayerShell.Layer.TOP)
        for edge in (GtkLayerShell.Edge.TOP, GtkLayerShell.Edge.RIGHT):
            GtkLayerShell.set_anchor(self.win, edge, True)
        GtkLayerShell.set_margin(self.win, GtkLayerShell.Edge.TOP, 33 + TOP_GAP)
        GtkLayerShell.set_margin(self.win, GtkLayerShell.Edge.RIGHT, TOP_GAP)
        GtkLayerShell.set_exclusive_zone(self.win, -1)
        GtkLayerShell.set_keyboard_interactivity(self.win, GtkLayerShell.KeyboardMode.NONE)

    def draw(self, widget, cr):
        cr.set_operator(cairo.OPERATOR_SOURCE)
        cr.set_source_rgba(0, 0, 0, 0)
        cr.paint()
        cr.set_operator(cairo.OPERATOR_OVER)

        rounded(cr, 0, 0, W, H, RADIUS)
        cr.clip()

        if self.bg:
            Gdk.cairo_set_source_pixbuf(cr, self.bg, 0, 0)
            cr.paint()
        if self.cover:
            cr.save()
            rounded(cr, PAD, (H - ICON) / 2, ICON, ICON, ICON_R)
            cr.clip()
            Gdk.cairo_set_source_pixbuf(cr, self.cover, PAD, (H - ICON) / 2)
            cr.paint()
            cr.restore()

        x = PAD + ICON + 12
        tw = W - x - PAD

        def text(s, y, size, bold, color):
            layout = PangoCairo.create_layout(cr)
            fd = Pango.FontDescription(f"{FONT} {size}")
            fd.set_weight(Pango.Weight.BOLD if bold else Pango.Weight.NORMAL)
            layout.set_font_description(fd)
            layout.set_text(s, -1)
            layout.set_width(int(tw * Pango.SCALE))
            layout.set_ellipsize(Pango.EllipsizeMode.END)
            cr.set_source_rgba(*color)
            cr.move_to(x, y)
            PangoCairo.show_layout(cr, layout)

        text(self.t.get("title") or "Unknown title", 21, 10, True, (1, 1, 1, 1))
        sub = " · ".join([p for p in (self.t.get("artist"), self.t.get("album")) if p])
        text(sub, 41, 9, False, (0.86, 0.86, 0.86, 0.9))

        rounded(cr, 0.5, 0.5, W - 1, H - 1, RADIUS - 0.5)
        cr.set_source_rgba(1, 1, 1, 0.14)
        cr.set_line_width(1)
        cr.stroke()
        return False

    def fade(self, target, ms, done=None):
        start = self.win.get_opacity()
        steps = max(1, ms // 16)
        i = [0]

        def tick():
            i[0] += 1
            p = min(1.0, i[0] / steps)
            self.win.set_opacity(start + (target - start) * p)
            if p >= 1:
                if done:
                    done()
                return False
            return True

        GLib.timeout_add(16, tick)

    def show(self, t, cover, hold_ms):
        mon = focused_output_monitor(self.win.get_screen().get_display())
        if mon:
            GtkLayerShell.set_monitor(self.win, mon)

        same = (t.get("title"), t.get("artist")) == (self.t.get("title"), self.t.get("artist"))
        self.t = t
        if not same and cover:
            self.bg = backdrop(cover)
            self.cover = icon_pixbuf(cover)
            self.area.queue_draw()

        if self.timer:
            GLib.source_remove(self.timer)
        self.timer = GLib.timeout_add(hold_ms, self._expire)
        self.win.show_all()
        self.fade(1.0, 140)

    def _expire(self):
        self.timer = None
        self.fade(0.0, 220, self._done)
        return False

    def _done(self):
        self.win.hide()
        if self.quit_when_done:
            Gtk.main_quit()

    def hide(self):
        if self.timer:
            GLib.source_remove(self.timer)
            self.timer = None
        self.fade(0.0, 180, self._done)


# ---------------------------------------------------------------- triggers
def trigger(toast, hold_ms=6500):
    if not notifications_enabled():
        return False
    t = track()
    cover = art_path(t.get("art"))
    if t.get("title") and cover:
        toast.show(t, cover, hold_ms)
    return False


def watch_dbus(toast):
    """MixMusic's own notification (if it sends one)."""
    def reader():
        try:
            proc = subprocess.Popen(
                ("dbus-monitor", "--session",
                 "interface='org.freedesktop.Notifications',member='Notify'"),
                stdout=subprocess.PIPE, text=True, bufsize=1)
        except Exception:
            return
        in_call, app = False, None
        for line in proc.stdout:
            line = line.strip()
            if line.startswith("method call"):
                in_call, app = True, None
            elif in_call and line.startswith('string "'):
                if app is None:
                    app = line[8:-1]
                    if app.lower() == "mixmusic":
                        in_call = False
                        GLib.idle_add(trigger, toast)
    threading.Thread(target=reader, daemon=True).start()


def watch_mpris(toast):
    """Fallback: track changes, for when the app does not emit notifications."""
    def reader():
        try:
            proc = subprocess.Popen(
                ("playerctl", "-p", "mixmusic", "--follow", "metadata",
                 "--format", "{{title}}\t{{artist}}"),
                stdout=subprocess.PIPE, text=True, bufsize=1)
        except Exception:
            return
        first = True
        for line in proc.stdout:
            line = line.rstrip("\n")
            if first:  # playerctl prints the current value on start
                first = False
                continue
            GLib.idle_add(trigger, toast)
    threading.Thread(target=reader, daemon=True).start()


def main():
    watch = "--watch" in sys.argv
    hold = int(sys.argv[sys.argv.index("--hold") + 1]) if "--hold" in sys.argv else 6500

    toast = Toast(quit_when_done=not watch)
    if watch:
        watch_dbus(toast)
        watch_mpris(toast)
    else:
        t = track()
        cover = art_path(t.get("art"))
        if not cover:
            print("no cover for the current track", file=sys.stderr)
            return 1
        GLib.timeout_add(50, lambda: (toast.show(t, cover, hold), False)[1])
    Gtk.main()
    return 0


if __name__ == "__main__":
    sys.exit(main())
