"""Builds docs/Application_Design.pdf - proposed workflows, tech stack and architecture."""
import pathlib
from reportlab.graphics.shapes import Drawing, Rect, String, Line, Polygon, Group
from reportlab.lib import colors
from reportlab.lib.units import mm
from reportlab.platypus import SimpleDocTemplate, Spacer, KeepTogether
from style import members_table, P, bullets, table, page_number, PAGE, MARGIN, WIDTH

OUT = pathlib.Path(__file__).resolve().parents[1] / "Application_Design.pdf"
B, WH, FILL = colors.black, colors.white, colors.HexColor("#d9e2f3")


def box(g, x, y, w, h, title, lines=(), fill=WH):
    g.add(Rect(x, y, w, h, fillColor=fill, strokeColor=B, strokeWidth=0.9))
    g.add(String(x + w / 2, y + h - 13, title, fontName="Cal-Bold", fontSize=9, textAnchor="middle"))
    for i, t in enumerate(lines):
        g.add(String(x + w / 2, y + h - 26 - i * 10.5, t, fontName="Cal", fontSize=7.4, textAnchor="middle"))


def arrow(g, x1, y1, x2, y2, label="", both=False, label_dy=4):
    g.add(Line(x1, y1, x2, y2, strokeColor=B, strokeWidth=0.9))
    def head(xa, ya, xb, yb):
        import math
        a = math.atan2(yb - ya, xb - xa)
        p1 = (xb - 6 * math.cos(a - 0.4), yb - 6 * math.sin(a - 0.4))
        p2 = (xb - 6 * math.cos(a + 0.4), yb - 6 * math.sin(a + 0.4))
        g.add(Polygon([xb, yb, *p1, *p2], fillColor=B, strokeColor=B, strokeWidth=0.5))
    head(x1, y1, x2, y2)
    if both:
        head(x2, y2, x1, y1)
    if label:
        g.add(String((x1 + x2) / 2, (y1 + y2) / 2 + label_dy, label, fontName="Cal-Italic", fontSize=7, textAnchor="middle"))


def architecture():
    w, h = 480, 175
    d, g = Drawing(w, h), Group()
    box(g, 5, 40, 120, 110, "Frontend (browser)", ["React + Vite", "pages: Movies, Movie page,", "Shows, Seat map,",
                                                  "My bookings, Watchlist,", "Admin (Tailwind CSS)"])
    box(g, 180, 40, 120, 110, "Backend API", ["Node.js + Express", "REST routes (JSON)", "input validation",
                                              "turns ORA- errors into", "friendly messages"])
    box(g, 350, 20, 128, 150, "Oracle 21c XE", ["15 tables + constraints", "5 views", "trigger (seat in right screen)",
                                                "PL/SQL procedures (planned):", "book_seats, cancel_booking", "sequences for new IDs",
                                                "indexes on FK columns"], fill=FILL)
    arrow(g, 125, 95, 180, 95, "HTTP / JSON", both=True, label_dy=6)
    arrow(g, 300, 95, 350, 95, "node-oracledb", both=True, label_dy=6)
    g.add(String(325, 82, "(pool)", fontName="Cal-Italic", fontSize=7, textAnchor="middle"))
    for x, t in ((65, "localhost:5173"), (240, "localhost:4000"), (414, "localhost:1521 / XEPDB1")):
        g.add(String(x, 28 if x < 300 else 8, t, fontName="Cal-Italic", fontSize=7, textAnchor="middle"))
    d.add(g)
    return d


def booking_flow():
    w, h = 480, 150
    d, g = Drawing(w, h), Group()
    steps = [("1. Pick a show", ["city + date filter", "THEATRE_SHOW_SCHEDULE"]),
             ("2. Load seat map", ["SHOW_SEAT_STATUS view", "AVAILABLE / BOOKED"]),
             ("3. Select seats", ["max 10 seats", "price shown live"]),
             ("4. POST /bookings", ["calls book_seats(...)", "one transaction"])]
    bw, gap = 100, 26.5
    for i, (t, ls) in enumerate(steps):
        x = 5 + i * (bw + gap)
        box(g, x, 92, bw, 50, t, ls)
        if i < 3:
            arrow(g, x + bw, 117, x + bw + gap, 117)
    # outcomes
    box(g, 250, 8, 105, 50, "Success", ["COMMIT, booking PENDING", "go to payment page"], fill=FILL)
    box(g, 370, 8, 105, 50, "ORA-00001", ["someone took a seat first", "ROLLBACK, refresh map"])
    arrow(g, 435, 92, 302, 58)
    arrow(g, 435, 92, 422, 58)
    g.add(Rect(5, 8, 225, 50, fillColor=WH, strokeColor=B, strokeWidth=0.6, strokeDashArray=[3, 2]))
    g.add(String(117, 42, "Why this is safe:", fontName="Cal-Bold", fontSize=7.6, textAnchor="middle"))
    g.add(String(117, 30, "UNIQUE (show_id, seat_id) means two people", fontName="Cal", fontSize=7.2, textAnchor="middle"))
    g.add(String(117, 20, "can never get the same seat, even at the same time.", fontName="Cal", fontSize=7.2, textAnchor="middle"))
    d.add(g)
    return d


story = [P("Movie Discovery, Review &amp; Cinema Booking Database", "title"), Spacer(1, 3),
         P("Application Design (proposed)", "subtitle"), Spacer(1, 4), members_table(), Spacer(1, 8)]

story += [P("1. Overview", "h1"),
          P("Phase 1 was all about the database. For the final project we're building a small web app on top of it, "
            "basically a mix of Letterboxd and BookMyShow. Users can browse movies, rate and review them, keep a watchlist, "
            "and then find a show near them and book seats. This document covers how we're planning to build it. It's a "
            "proposal, so some details might change once we start coding."),
          P("One idea we're sticking to: <b>the important rules stay in the database</b>, not in the app code. "
            "So even if the frontend or backend has a bug, Oracle still won't let a seat be sold twice, a rating go above 5, "
            "or a payment be marked SUCCESS without a time.")]

story += [P("2. Technology Stack", "h1")]
stack = [["Layer", "What we're using", "Why"],
         ["Database", "Oracle Database 21c XE, SQL + PL/SQL", "required for the course; we already have the schema, constraints, views and trigger working"],
         ["DB tools", "SQL Developer, SQL*Plus", "running scripts, testing queries, demoing in the viva"],
         ["Backend", "Node.js + Express", "simple to write REST APIs; we know JavaScript already"],
         ["DB driver", "node-oracledb (thin mode)", "official Oracle driver, no Instant Client install needed, has connection pooling"],
         ["Frontend", "React (Vite) + Tailwind CSS", "component-based, fast dev server; good for the seat map UI"],
         ["Other", "Git + GitHub, Postman, dotenv", "version control, testing the API, keeping DB passwords out of the code"]]
story += [table(stack, [24 * mm, 55 * mm, WIDTH - 79 * mm])]

story += [P("3. High-level Architecture", "h1"),
          P("It's a normal 3-tier setup. The React frontend only ever talks to our Express API. The API is the only thing "
            "that connects to Oracle, using a connection pool. All queries use bind variables, never string concatenation, "
            "so SQL injection isn't possible."),
          architecture(),
          P("Figure 1: high-level architecture", "caption")]
story += bullets([
    "<b>Frontend:</b> pages and components only, no business rules. It shows whatever the API returns.",
    "<b>Backend:</b> routes → small service functions → SQL. Reads mostly go through our views (e.g. SHOW_SEAT_STATUS, "
    "MOVIE_RATING_SUMMARY), so the SQL in the app stays short. Writes for bookings go through PL/SQL procedures.",
    "<b>Database:</b> constraints + trigger are the final safety net. The backend turns Oracle errors into readable messages, "
    "e.g. ORA-00001 on UQ_BSEAT_SHOW_SEAT becomes \"Sorry, one of those seats was just booked\".",
])

story += [P("4. Main Application Workflows", "h1")]
wf = [["#", "Workflow", "What the user does", "What happens in the DB"],
      ["W1", "Browse / search movies", "filter by genre, language, title; sort by rating", "SELECT on MOVIE_DETAILS + MOVIE_RATING_SUMMARY views"],
      ["W2", "Movie page", "see details, cast, genres, average rating and reviews", "views + REVIEW joined with APP_USER"],
      ["W3", "Rate / review a movie", "give 0.5-5 stars, optional text; edit later", "MERGE into REVIEW (PK stops duplicates, CHECK stops bad ratings)"],
      ["W4", "Watchlist", "add/remove movies; get a hint when one is in theatres", "INSERT/DELETE on WATCHLIST; INTERSECT with MOVIE_SHOW (like Q37)"],
      ["W5", "Find shows", "pick city and date, see what's playing where", "THEATRE_SHOW_SCHEDULE view"],
      ["W6", "Book seats", "open seat map, pick seats, confirm", "book_seats procedure: BOOKING + BOOKING_SEAT in one transaction"],
      ["W7", "Pay (simulated)", "choose UPI / card / etc., get confirmation", "INSERT PAYMENT (SUCCESS + paid_at), booking → CONFIRMED"],
      ["W8", "My bookings / cancel", "see tickets, cancel an upcoming one", "BOOKING_SUMMARY view; cancel_booking frees seats, status CANCELLED"],
      ["W9", "Admin", "add movies, theatres, screens and shows", "plain INSERTs; UNIQUE (screen_id, show_start) blocks clashes"]]
story += [table(wf, [9 * mm, 33 * mm, 58 * mm, WIDTH - 100 * mm])]

story += [KeepTogether([P("Booking workflow in detail (W6)", "h2"),
          P("This is the part we were most careful about, because it's where two users can clash:"),
          booking_flow(), P("Figure 2: seat booking flow", "caption")])]

story += [P("5. API Endpoints (planned)", "h1")]
api = [["Method", "Endpoint", "Used for"],
       ["GET", "/api/movies?genre=&amp;lang=&amp;q=", "W1 list / search movies"],
       ["GET", "/api/movies/:id", "W2 movie page (details, cast, rating, reviews)"],
       ["PUT", "/api/movies/:id/review", "W3 add or update my review"],
       ["GET / POST / DELETE", "/api/watchlist", "W4 my watchlist"],
       ["GET", "/api/shows?city=&amp;date=", "W5 shows by city and date"],
       ["GET", "/api/shows/:id/seats", "W6 seat map for a show"],
       ["POST", "/api/bookings", "W6 book selected seats"],
       ["POST", "/api/bookings/:id/pay", "W7 simulated payment"],
       ["GET / POST", "/api/bookings/mine, /api/bookings/:id/cancel", "W8 my bookings, cancel"],
       ["POST", "/api/admin/movies, /api/admin/shows", "W9 admin"]]
story += [table(api, [30 * mm, 70 * mm, WIDTH - 100 * mm], mono_cols=(1,), raw=True)]
story += [Spacer(1, 2), P("For the demo we'll have a simple \"pick a user\" dropdown instead of real login, since "
                          "authentication is out of scope for us.")]

story += [P("6. What we still need to add to the database", "h1")]
story += bullets([
    "<b>PL/SQL procedures:</b> book_seats (checks that the seats are free, inserts the booking and its seats, computes "
    "the premium price) and cancel_booking (deletes the BOOKING_SEAT rows and sets status CANCELLED).",
    "<b>A function</b> like get_seat_price(show_id, seat_id), so the price rule (premium = base + 100) is defined in one place.",
    "<b>Indexes</b> on foreign key columns that the app filters on a lot: BOOKING(user_id), MOVIE_SHOW(movie_id), REVIEW(movie_id).",
    "<b>More sample data</b> so the app has more to show (more shows and dates).",
])

story += [P("7. Current progress", "h1")]
prog = [["Part", "Status"],
        ["ER/EER design, relational schema, normalization", "done"],
        ["Tables, constraints, sequences, sample data (02, 03)", "done, tested on Oracle 21c XE"],
        ["37 SQL queries, 5 views, seat/screen trigger (04-06)", "done, all results checked (see test report)"],
        ["PL/SQL procedures, function, indexes", "next"],
        ["Backend API (Express) and frontend (React)", "next, after mid-sem"]]
story += [table(prog, [100 * mm, WIDTH - 100 * mm])]

doc = SimpleDocTemplate(str(OUT), pagesize=PAGE, leftMargin=MARGIN, rightMargin=MARGIN, topMargin=16 * mm,
                        bottomMargin=17 * mm, title="Application Design", author="Sashwath Swaminathan, Srujana N S, Anushka Sahoo, Vinny Polamarasetty")
doc.build(story, onFirstPage=page_number, onLaterPages=page_number)
from pypdf import PdfReader
print(OUT.name, "pages:", len(PdfReader(OUT).pages))
