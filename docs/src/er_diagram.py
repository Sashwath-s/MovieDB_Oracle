"""ER/EER diagram (Chen notation) for the MovieDB project, drawn with reportlab graphics."""
import math
from reportlab.graphics.shapes import Drawing, Rect, Polygon, Line, String, Circle, Group
from reportlab.lib import colors

W, H = 580, 440
EW, EH = 84, 30          # entity box
DW, DH = 36, 16          # diamond half-width / half-height
B, WH = colors.black, colors.white

ENT = {  # name: (x, y, weak, key label)
    "GENRE": (50, 400, False, "genre_id"), "MOVIE": (265, 400, False, "movie_id"),
    "ACTOR": (500, 400, False, "actor_id"), "APP_USER": (50, 220, False, "user_id"),
    "MOVIE_SHOW": (265, 220, False, "show_id"), "THEATRE": (500, 310, False, "theatre_id"),
    "SCREEN": (500, 220, True, "partial key: screen_no"), "BOOKING": (265, 130, False, "booking_id"),
    "SEAT": (500, 130, True, "partial key: row+number"), "PAYMENT": (265, 40, False, "payment_id"),
    "REGULAR_SEAT": (445, 32, False, ""), "PREMIUM_SEAT": (545, 32, False, ""),
}
REL = {  # name: (x, y, identifying, attribute note, note offset)
    "BELONGS_TO": (157, 400, False, "", 0), "ACTS_IN": (382, 400, False, "(character_name)", -24),
    "REVIEWS": (96, 312, False, "(rating, review_text)", 24), "WATCHLISTS": (178, 312, False, "(added_on)", 24),
    "SCREENS": (265, 310, False, "", 0), "HAS_SCREEN": (500, 265, True, "", 0),
    "HOSTS": (382, 220, False, "", 0), "MAKES": (150, 175, False, "", 0),
    "FOR_SHOW": (265, 175, False, "", 0), "HAS_SEAT": (500, 175, True, "", 0),
    "RESERVES": (382, 130, False, "(price_paid)", -24), "PAID_BY": (265, 85, False, "", 0),
}
# (relationship, entity, cardinality, total participation?)
EDGES = [
    ("BELONGS_TO", "GENRE", "N", False), ("BELONGS_TO", "MOVIE", "M", True),
    ("ACTS_IN", "MOVIE", "M", False), ("ACTS_IN", "ACTOR", "N", False),
    ("REVIEWS", "APP_USER", "M", False), ("REVIEWS", "MOVIE", "N", False),
    ("WATCHLISTS", "APP_USER", "M", False), ("WATCHLISTS", "MOVIE", "N", False),
    ("SCREENS", "MOVIE", "1", False), ("SCREENS", "MOVIE_SHOW", "N", True),
    ("HAS_SCREEN", "THEATRE", "1", True), ("HAS_SCREEN", "SCREEN", "N", True),
    ("HOSTS", "SCREEN", "1", False), ("HOSTS", "MOVIE_SHOW", "N", True),
    ("MAKES", "APP_USER", "1", False), ("MAKES", "BOOKING", "N", True),
    ("FOR_SHOW", "MOVIE_SHOW", "1", False), ("FOR_SHOW", "BOOKING", "N", True),
    ("HAS_SEAT", "SCREEN", "1", True), ("HAS_SEAT", "SEAT", "N", True),
    ("RESERVES", "BOOKING", "M", False), ("RESERVES", "SEAT", "N", False),
    ("PAID_BY", "BOOKING", "1", False), ("PAID_BY", "PAYMENT", "1", True),
]


def _line(g, x1, y1, x2, y2, double=False):
    if not double:
        g.add(Line(x1, y1, x2, y2, strokeColor=B, strokeWidth=0.8))
        return
    dx, dy = x2 - x1, y2 - y1
    L = math.hypot(dx, dy) or 1
    ox, oy = -dy / L * 1.6, dx / L * 1.6
    for s in (1, -1):
        g.add(Line(x1 + s * ox, y1 + s * oy, x2 + s * ox, y2 + s * oy, strokeColor=B, strokeWidth=0.7))


def _entity(g, x, y, name, weak, key, w=EW):
    g.add(Rect(x - w / 2, y - EH / 2, w, EH, fillColor=WH, strokeColor=B, strokeWidth=0.9))
    if weak:
        g.add(Rect(x - w / 2 + 2.5, y - EH / 2 + 2.5, w - 5, EH - 5, fillColor=None, strokeColor=B, strokeWidth=0.6))
    ty = y + (1 if key else -3)
    g.add(String(x, ty, name, fontName="Cal-Bold", fontSize=8, textAnchor="middle"))
    if key:
        g.add(String(x, y - 9, key, fontName="Cal-Italic", fontSize=6, textAnchor="middle"))
        tw = len(key) * 2.55
        if not key.startswith("partial"):
            g.add(Line(x - tw / 2, y - 10.3, x + tw / 2, y - 10.3, strokeColor=B, strokeWidth=0.5))


def _diamond(g, x, y, name, identifying):
    pts = [x - DW, y, x, y + DH, x + DW, y, x, y - DH]
    g.add(Polygon(pts, fillColor=WH, strokeColor=B, strokeWidth=0.9))
    if identifying:
        k = 0.8
        g.add(Polygon([x - DW * k, y, x, y + DH * k, x + DW * k, y, x, y - DH * k],
                      fillColor=None, strokeColor=B, strokeWidth=0.6))
    g.add(String(x, y - 2.3, name, fontName="Cal", fontSize=6.4, textAnchor="middle"))


def build(scale=1.0):
    d = Drawing(W * scale, H * scale)
    g = Group()
    # relationship lines first, shapes drawn on top hide the line ends
    for rel, ent, card, total in EDGES:
        rx, ry = REL[rel][:2]
        ex, ey = ENT[ent][:2]
        _line(g, rx, ry, ex, ey, total)
        t = 0.62
        lx, ly = rx + (ex - rx) * t, ry + (ey - ry) * t
        dx, dy = ex - rx, ey - ry
        L = math.hypot(dx, dy) or 1
        lx, ly = lx + (-dy / L) * 7.5, ly + (dx / L) * 7.5
        g.add(String(lx, ly - 2.5, card, fontName="Cal-Bold", fontSize=7, textAnchor="middle"))
    # specialization of SEAT (disjoint, total)
    cx, cy = 500, 82
    _line(g, 500, 130, cx, cy, double=True)
    for sub in ("REGULAR_SEAT", "PREMIUM_SEAT"):
        sx, sy = ENT[sub][:2]
        _line(g, cx, cy, sx, sy)
    for name, (x, y, weak, key) in ENT.items():
        _entity(g, x, y, name, weak, key, w=78 if name.endswith("_SEAT") and name != "SEAT" else EW)
    for name, (x, y, ident, note, off) in REL.items():
        _diamond(g, x, y, name, ident)
        if note:
            g.add(String(x, y + off - 2, note, fontName="Cal-Italic", fontSize=6, textAnchor="middle"))
    g.add(Circle(cx, cy, 8, fillColor=WH, strokeColor=B, strokeWidth=0.9))
    g.add(String(cx, cy - 2.6, "d", fontName="Cal-Bold", fontSize=8, textAnchor="middle"))
    g.add(String(cx + 13, cy + 2, "seat_type", fontName="Cal-Italic", fontSize=6))
    # legend
    lx, ly = 8, 8
    g.add(Rect(lx, ly, 196, 70, fillColor=WH, strokeColor=B, strokeWidth=0.5))
    g.add(String(lx + 6, ly + 60, "Legend", fontName="Cal-Bold", fontSize=7))
    g.add(Rect(lx + 10, ly + 33, 30, 14, fillColor=WH, strokeColor=B, strokeWidth=0.9))
    g.add(String(lx + 46, ly + 37.5, "entity", fontName="Cal", fontSize=6.5))
    g.add(Rect(lx + 10, ly + 7, 30, 14, fillColor=WH, strokeColor=B, strokeWidth=0.9))
    g.add(Rect(lx + 12, ly + 9, 26, 10, fillColor=None, strokeColor=B, strokeWidth=0.6))
    g.add(String(lx + 46, ly + 11.5, "weak entity", fontName="Cal", fontSize=6.5))
    for (px, py, ident, label) in [(lx + 112, ly + 44, False, "relationship"), (lx + 112, ly + 25, True, "identifying rel.")]:
        g.add(Polygon([px - 12, py, px, py + 7, px + 12, py, px, py - 7], fillColor=WH, strokeColor=B, strokeWidth=0.8))
        if ident:
            g.add(Polygon([px - 8, py, px, py + 4.6, px + 8, py, px, py - 4.6], fillColor=None, strokeColor=B, strokeWidth=0.5))
        g.add(String(px + 16, py - 2.3, label, fontName="Cal", fontSize=6.5))
    _line(g, lx + 100, ly + 8, lx + 124, ly + 8, double=True)
    g.add(String(lx + 128, ly + 5.7, "total participation", fontName="Cal", fontSize=6.5))
    g.scale(scale, scale)
    d.add(g)
    return d


if __name__ == "__main__":
    import style  # noqa: F401  (registers fonts)
    from reportlab.graphics import renderPDF
    renderPDF.drawToFile(build(), "er_test.pdf")
