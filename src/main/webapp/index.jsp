<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Palestine Relief | Humanitarian Aid System</title>

    <%-- Google Fonts: Lora (headings/quotes) + DM Sans (body text) --%>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400;0,600;1,400&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">

    <style>
        /* ── CSS RESET ──────────────────────────────────────────── */
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        /* ── THEME VARIABLES ────────────────────────────────────
           Two themes: dark and light.
           Switching data-theme on <html> swaps all colors.
           Theme saved to localStorage key 'donorTheme'. */
        [data-theme="dark"] {
            --bg:      #0b0e14;
            --surface: #13171f;
            --surface2:#1a1f2b;
            --border:  rgba(255,255,255,0.07);
            --text:    #e6e8f0;
            --text2:   #9ba3b8;
            --muted:   #5a6278;
            --shadow:  rgba(0,0,0,0.5);
        }
        [data-theme="light"] {
            --bg:      #f2f4f8;
            --surface: #ffffff;
            --surface2:#f7f8fc;
            --border:  rgba(0,0,0,0.08);
            --text:    #181c2a;
            --text2:   #4a5068;
            --muted:   #9ba3b8;
            --shadow:  rgba(0,0,0,0.08);
        }

        /* ── GLOBAL COLOR TOKENS ────────────────────────────────
           Palestine-themed accent colors */
        :root {
            --green:     #1db954;
            --green-dim: rgba(29,185,84,0.12);
            --red:       #e63946;
            --gold:      #f4a261;
        }

        /* ── BODY ───────────────────────────────────────────────
           Full-height flex column layout.
           ::before = decorative radial gradient glow in background
           (green top-left, red bottom-right, gold top-center) */
        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--bg); color: var(--text);
            min-height: 100vh;
            display: flex; flex-direction: column;
            transition: background .25s, color .25s;
            position: relative; overflow-x: hidden;
        }
        body::before {
            content: '';
            position: fixed; inset: 0;
            background-image:
                radial-gradient(circle at 15% 40%, rgba(29,185,84,0.07) 0%, transparent 55%),
                radial-gradient(circle at 85% 60%, rgba(230,57,70,0.05) 0%, transparent 55%),
                radial-gradient(circle at 50% 10%, rgba(244,162,97,0.04) 0%, transparent 50%);
            pointer-events: none; z-index: 0;
        }

        /* ── PALESTINE FLAG WATERMARK ───────────────────────────
           Large flag emoji fixed bottom-right at 2.5% opacity.
           Purely decorative — not interactive. */
        .flag-watermark {
            position: fixed; bottom: -60px; right: -30px;
            font-size: 280px; opacity: .025;
            pointer-events: none; z-index: 0;
            transform: rotate(-12deg);
            user-select: none;
        }

        /* ── NAVIGATION BAR ─────────────────────────────────────
           Top nav showing brand name, theme toggle, and Sign In link.
           Not sticky — scrolls with page on index. */
        nav {
            position: relative; z-index: 10;
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 48px; height: 64px;
            border-bottom: 1px solid var(--border);
            background: var(--surface);
            transition: background .25s, border-color .25s;
        }
        .nav-brand { display: flex; align-items: center; gap: 10px; }
        .nav-brand-icon {
            width: 34px; height: 34px; border-radius: 8px;
            background: var(--green-dim); border: 1px solid rgba(29,185,84,0.2);
            display: flex; align-items: center; justify-content: center; font-size: 17px;
        }
        .nav-brand-name { font-family: 'Lora', serif; font-size: 17px; font-weight: 600; }
        .nav-brand-name span { color: var(--green); }
        .nav-actions { display: flex; align-items: center; gap: 10px; }

        /* Theme toggle button — moon/sun emoji, calls toggleTheme() */
        .theme-btn {
            width: 34px; height: 34px; border-radius: 8px;
            background: var(--surface2); border: 1px solid var(--border);
            cursor: pointer; font-size: 15px;
            display: flex; align-items: center; justify-content: center;
            transition: border-color .2s, background .25s;
        }
        .theme-btn:hover { border-color: var(--green); }

        /* Sign In link → login.jsp */
        .nav-login {
            font-size: 13px; font-weight: 500; color: var(--text2);
            text-decoration: none; padding: 8px 16px;
            border: 1px solid var(--border); border-radius: 8px;
            transition: all .18s;
        }
        .nav-login:hover { color: var(--text); border-color: rgba(255,255,255,0.15); }

        /* ── HERO SECTION ───────────────────────────────────────
           Full-height centered section with:
           - Animated eyebrow badge with pulsing green dot
           - Large responsive heading
           - Subtext
           - Two CTA buttons (Donate Now → register.jsp | Sign In → login.jsp)
           - Quranic quote
           - Stats strip (100% Transparent | 🔒 Secure | 24/7 Open)
           All elements animate in with staggered fadeUp delay. */
        .hero {
            position: relative; z-index: 1;
            flex: 1; display: flex; flex-direction: column;
            align-items: center; justify-content: center;
            text-align: center; padding: 80px 24px 60px;
        }

        /* Green pill badge above heading — "Humanitarian Aid Platform" */
        .hero-eyebrow {
            display: inline-flex; align-items: center; gap: 7px;
            font-size: 12px; font-weight: 600; letter-spacing: 1px;
            text-transform: uppercase; color: var(--green);
            background: var(--green-dim); border: 1px solid rgba(29,185,84,0.2);
            padding: 5px 14px; border-radius: 20px;
            margin-bottom: 24px;
            animation: fadeUp .5s ease both;
        }
        /* Animated pulsing green dot inside eyebrow badge */
        .hero-eyebrow::before {
            content: ''; width: 6px; height: 6px; border-radius: 50%;
            background: var(--green); animation: pulse 1.8s infinite;
        }

        /* Main heading — responsive font size via clamp() */
        .hero-title {
            font-family: 'Lora', serif;
            font-size: clamp(36px, 6vw, 62px);
            font-weight: 600; line-height: 1.15;
            max-width: 720px; margin-bottom: 20px;
            animation: fadeUp .5s .1s ease both;
        }
        /* "Palestine." in green italic */
        .hero-title em { font-style: italic; color: var(--green); }

        .hero-sub {
            font-size: 16px; color: var(--text2);
            max-width: 500px; line-height: 1.7;
            margin-bottom: 40px;
            animation: fadeUp .5s .2s ease both;
        }

        /* CTA buttons row */
        .hero-actions {
            display: flex; gap: 12px; flex-wrap: wrap;
            justify-content: center; margin-bottom: 56px;
            animation: fadeUp .5s .3s ease both;
        }

        /* Primary CTA: "Donate Now" → register.jsp (green filled) */
        .btn-primary {
            background: var(--green); color: #051a0d;
            text-decoration: none; padding: 14px 32px;
            border-radius: 10px; font-size: 15px; font-weight: 700;
            font-family: inherit; transition: opacity .18s, transform .15s;
            display: inline-flex; align-items: center; gap: 8px;
        }
        .btn-primary:hover { opacity: .88; transform: translateY(-2px); }
        .btn-primary:active { transform: translateY(0); }

        /* Secondary CTA: "Sign In" → login.jsp (outlined) */
        .btn-secondary {
            background: var(--surface); color: var(--text);
            text-decoration: none; padding: 14px 32px;
            border-radius: 10px; font-size: 15px; font-weight: 600;
            border: 1px solid var(--border); font-family: inherit;
            transition: all .18s;
            display: inline-flex; align-items: center; gap: 8px;
        }
        .btn-secondary:hover { border-color: rgba(255,255,255,0.18); transform: translateY(-2px); }

        /* ── QURANIC QUOTE ──────────────────────────────────────
           Left gold border, italic Lora font.
           Displayed between CTA buttons and stats strip. */
        .quote {
            max-width: 560px; margin: 0 auto 56px;
            padding: 20px 28px;
            border-left: 3px solid rgba(244,162,97,0.4);
            text-align: left;
            animation: fadeUp .5s .35s ease both;
        }
        .quote-text { font-family: 'Lora', serif; font-style: italic; font-size: 15px; color: var(--text2); line-height: 1.75; }
        .quote-src  { font-size: 11.5px; color: var(--muted); margin-top: 8px; letter-spacing: .4px; text-transform: uppercase; font-weight: 600; }

        /* ── STATS STRIP ────────────────────────────────────────
           3-column horizontal bar showing:
           100% Transparent | 🔒 Secure Donations | 24/7 Always Open
           Static display values — not calculated from DB. */
        .stats-strip {
            display: flex; gap: 0;
            border: 1px solid var(--border);
            border-radius: 14px; overflow: hidden;
            background: var(--surface);
            max-width: 640px; width: 100%;
            transition: background .25s, border-color .25s;
            animation: fadeUp .5s .4s ease both;
        }
        .strip-stat {
            flex: 1; padding: 20px 24px; text-align: center;
            border-right: 1px solid var(--border);
            transition: border-color .25s;
        }
        .strip-stat:last-child { border-right: none; }
        .strip-val { font-size: 22px; font-weight: 700; color: var(--green); margin-bottom: 4px; }
        .strip-lbl { font-size: 11.5px; color: var(--muted); letter-spacing: .4px; }

        /* ── FEATURE CARDS ──────────────────────────────────────
           3-column grid below hero showing system highlights:
           Targeted Campaigns | Live Progress Tracking | Full Donation History
           Each card has icon, title, and description. */
        .features {
            position: relative; z-index: 1;
            display: grid; grid-template-columns: repeat(3,1fr);
            gap: 16px; max-width: 900px; margin: 0 auto;
            padding: 0 24px 80px;
        }
        .feat-card {
            background: var(--surface); border: 1px solid var(--border);
            border-radius: 12px; padding: 24px;
            transition: border-color .2s, transform .2s, background .25s;
            animation: fadeUp .5s ease both;
        }
        /* Staggered animation delay per feature card */
        .feat-card:nth-child(1){animation-delay:.1s;}
        .feat-card:nth-child(2){animation-delay:.2s;}
        .feat-card:nth-child(3){animation-delay:.3s;}
        .feat-card:hover { border-color: rgba(29,185,84,0.2); transform: translateY(-3px); }
        .feat-icon  { font-size: 26px; margin-bottom: 12px; }
        .feat-title { font-family: 'Lora', serif; font-size: 15px; font-weight: 600; margin-bottom: 7px; }
        .feat-desc  { font-size: 13px; color: var(--text2); line-height: 1.65; }

        /* ── FOOTER ─────────────────────────────────────────────
           Simple centered copyright text at bottom of page */
        footer {
            position: relative; z-index: 1;
            text-align: center; padding: 20px;
            font-size: 12px; color: var(--muted);
            border-top: 1px solid var(--border);
            transition: border-color .25s;
        }

        /* ── ANIMATIONS ─────────────────────────────────────────
           fadeUp: used on all sections with staggered delays
           pulse: used on the green dot in hero eyebrow badge */
        @keyframes fadeUp { from{opacity:0;transform:translateY(18px);}to{opacity:1;transform:none;} }
        @keyframes pulse  { 0%,100%{opacity:1;}50%{opacity:.3;} }

        /* ── RESPONSIVE (mobile < 640px) ────────────────────────
           Stack features to single column.
           Stack stats strip vertically.
           Reduce nav padding. */
        @media (max-width: 640px) {
            nav { padding: 0 20px; }
            .features { grid-template-columns: 1fr; padding: 0 20px 60px; }
            .stats-strip { flex-direction: column; }
            .strip-stat { border-right: none; border-bottom: 1px solid var(--border); }
            .strip-stat:last-child { border-bottom: none; }
        }
    </style>
</head>
<body>

<%-- Palestine flag watermark — large emoji fixed bottom-right --%>
<div class="flag-watermark">🇵🇸</div>

<%-- ── NAVIGATION BAR ──────────────────────────────────────────
     Brand name | theme toggle | Sign In link --%>
<nav>
    <div class="nav-brand">
        <div class="nav-brand-name">Palestine <span>Relief</span></div>
    </div>
    <div class="nav-actions">
        <%-- Theme toggle: moon icon by default, calls toggleTheme() --%>
        <button class="theme-btn" onclick="toggleTheme()" id="themeBtn">🌙</button>
        <%-- Sign In → login.jsp --%>
        <a href="login.jsp" class="nav-login">Sign In</a>
    </div>
</nav>

<%-- ── HERO SECTION ────────────────────────────────────────────
     Main landing content: eyebrow badge, heading, subtext,
     CTA buttons, Quranic quote, and stats strip --%>
<section class="hero">

    <%-- Animated pulsing badge above heading --%>
    <div class="hero-eyebrow">Humanitarian Aid Platform</div>

    <%-- Main heading: "Palestine." in green italic --%>
    <h1 class="hero-title">
        Stand with <em>Palestine.</em><br>Every Donation Counts.
    </h1>

    <%-- Brief description of the system --%>
    <p class="hero-sub">
        A transparent, secure platform connecting generous donors with verified relief campaigns for families in Palestine.
    </p>

    <%-- CTA buttons:
         "Donate Now" → register.jsp (new users sign up first)
         "Sign In"    → login.jsp (existing users) --%>
    <div class="hero-actions">
        <a href="register.jsp" class="btn-primary">Donate Now</a>
        <a href="login.jsp"    class="btn-secondary">Sign In</a>
    </div>

    <%-- Quranic verse — left gold border --%>
    <div class="quote">
        <div class="quote-text">"Whoever saves one life, it is as if he has saved all of mankind."</div>
        <div class="quote-src">— Al-Qur'an, Surah Al-Ma'idah 5:32</div>
    </div>

    <%-- Stats strip: 3 static trust indicators --%>
    <div class="stats-strip">
        <div class="strip-stat">
            <div class="strip-val">100%</div>
            <div class="strip-lbl">Transparent</div>
        </div>
        <div class="strip-stat">
            <div class="strip-val">🔒</div>
            <div class="strip-lbl">Secure Donations</div>
        </div>
        <div class="strip-stat">
            <div class="strip-val">24/7</div>
            <div class="strip-lbl">Always Open</div>
        </div>
    </div>

</section>

<%-- ── FEATURE CARDS ───────────────────────────────────────────
     3 cards highlighting key system features.
     Static content — no server-side data needed. --%>
<div class="features">
    <div class="feat-card">
        <div class="feat-icon">🎯</div>
        <div class="feat-title">Targeted Campaigns</div>
        <div class="feat-desc">Every campaign is dedicated to a specific cause — medical aid, food relief, shelter, or education for Palestinian families.</div>
    </div>
    <div class="feat-card">
        <div class="feat-icon">📊</div>
        <div class="feat-title">Live Progress Tracking</div>
        <div class="feat-desc">Watch your impact in real time. See exactly how much has been raised and how close each campaign is to its goal.</div>
    </div>
    <div class="feat-card">
        <div class="feat-icon">📜</div>
        <div class="feat-title">Full Donation History</div>
        <div class="feat-desc">Every contribution is logged. Access your complete personal donation history from your donor dashboard anytime.</div>
    </div>
</div>

<%-- Footer --%>
<footer>
    © 2026 Palestine Relief System · Built with care for humanity
</footer>

<script>
    var html = document.documentElement;

    /* ── THEME ──────────────────────────────────────────────────
       On load: read saved theme from localStorage (default: dark).
       Shares 'donorTheme' key with donor_dashboard.jsp and
       forgot_password.jsp so theme stays consistent across all pages.
       applyTheme() sets data-theme on <html> and updates button icon. */
    (function() {
        var saved = localStorage.getItem('donorTheme') || 'dark';
        applyTheme(saved);
    })();

    function applyTheme(theme) {
        html.setAttribute('data-theme', theme);
        // Sun = currently dark (click to go light)
        // Moon = currently light (click to go dark)
        document.getElementById('themeBtn').textContent = theme === 'dark' ? '☀️' : '🌙';
        localStorage.setItem('donorTheme', theme);
    }

    function toggleTheme() {
        applyTheme(html.getAttribute('data-theme') === 'dark' ? 'light' : 'dark');
    }
</script>
</body>
</html>