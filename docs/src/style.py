"""Plain 'Word document saved as PDF' look for the submission docs:
Calibri text, simple bold headings, black grid tables."""
from xml.sax.saxutils import escape
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import Paragraph, Table, TableStyle

F = r"C:\Windows\Fonts"
for name, file in [("Cal", "calibri.ttf"), ("Cal-Bold", "calibrib.ttf"), ("Cal-Italic", "calibrii.ttf"),
                   ("Cal-BoldItalic", "calibriz.ttf"), ("Mono", "consola.ttf"), ("Mono-Bold", "consolab.ttf")]:
    pdfmetrics.registerFont(TTFont(name, rf"{F}\{file}"))
pdfmetrics.registerFontFamily("Cal", normal="Cal", bold="Cal-Bold", italic="Cal-Italic", boldItalic="Cal-BoldItalic")
pdfmetrics.registerFontFamily("Mono", normal="Mono", bold="Mono-Bold", italic="Mono", boldItalic="Mono-Bold")

BLACK = colors.black
HEADER_FILL = colors.HexColor("#d9e2f3")   # Word's default light-blue table header

PAGE = A4
MARGIN = 20 * mm
WIDTH = PAGE[0] - 2 * MARGIN

S = {
    "title": ParagraphStyle("title", fontName="Cal-Bold", fontSize=18, leading=22, alignment=TA_CENTER),
    "subtitle": ParagraphStyle("subtitle", fontName="Cal", fontSize=11.5, leading=15, alignment=TA_CENTER),
    "meta": ParagraphStyle("meta", fontName="Cal", fontSize=10, leading=13, alignment=TA_CENTER),
    "h1": ParagraphStyle("h1", fontName="Cal-Bold", fontSize=13, leading=16, spaceBefore=8, spaceAfter=3, keepWithNext=1),
    "h2": ParagraphStyle("h2", fontName="Cal-Bold", fontSize=10.5, leading=13, spaceBefore=5, spaceAfter=2, keepWithNext=1),
    "body": ParagraphStyle("body", fontName="Cal", fontSize=10, leading=12.6, alignment=TA_LEFT, spaceAfter=3),
    "bullet": ParagraphStyle("bullet", fontName="Cal", fontSize=10, leading=12.4, leftIndent=14, bulletIndent=4,
                             spaceAfter=1),
    "caption": ParagraphStyle("caption", fontName="Cal-Italic", fontSize=9, leading=11, alignment=TA_CENTER,
                              spaceBefore=2, spaceAfter=6),
    "cell": ParagraphStyle("cell", fontName="Cal", fontSize=8.6, leading=10.2),
    "cellmono": ParagraphStyle("cellmono", fontName="Mono", fontSize=7.6, leading=9.4),
    "head": ParagraphStyle("head", fontName="Cal-Bold", fontSize=8.8, leading=10.4),
    "code": ParagraphStyle("code", fontName="Mono", fontSize=8, leading=9.8),
}


def P(text, style="body", **kw):
    return Paragraph(text, S[style], **kw)


def bullets(items, style="bullet"):
    return [Paragraph(t, S[style], bulletText="\u2022") for t in items]


def table(rows, widths, mono_cols=(), raw=False):
    """Plain Word-style table: thin black grid, shaded bold header row."""
    data = []
    for i, r in enumerate(rows):
        line = []
        for j, v in enumerate(r):
            txt = str(v) if raw else escape(str(v))
            style = "head" if i == 0 else ("cellmono" if j in mono_cols else "cell")
            line.append(Paragraph(txt, S[style]))
        data.append(line)
    t = Table(data, colWidths=widths, repeatRows=1, hAlign="CENTER")
    t.setStyle(TableStyle([
        ("GRID", (0, 0), (-1, -1), 0.5, BLACK),
        ("BACKGROUND", (0, 0), (-1, 0), HEADER_FILL),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("TOPPADDING", (0, 0), (-1, -1), 2), ("BOTTOMPADDING", (0, 0), (-1, -1), 2.5),
        ("LEFTPADDING", (0, 0), (-1, -1), 3.5), ("RIGHTPADDING", (0, 0), (-1, -1), 3.5)]))
    return t


def page_number(c, d):
    c.saveState()
    c.setFont("Cal", 9)
    c.drawCentredString(PAGE[0] / 2, 10 * mm, f"Page {d.page}")
    c.restoreState()


MEMBERS = [("Sashwath Swaminathan", "2024A3PS0361H"), ("Srujana N S", "2024A1PS0874H"),
           ("Anushka Sahoo", "2024A1PS0937H"), ("Vinny Polamarasetty", "2024A1PS0930H")]


def members_table():
    """Small centred table of team members and ID numbers for the title block."""
    rows = [["Name", "ID No.", "Name", "ID No."]]
    for i in range(0, len(MEMBERS), 2):
        rows.append([*MEMBERS[i], *MEMBERS[i + 1]])
    return table(rows, [42 * mm, 30 * mm, 42 * mm, 30 * mm])
