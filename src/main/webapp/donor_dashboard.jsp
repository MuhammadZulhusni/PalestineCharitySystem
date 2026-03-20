<%@ page import="com.charity.dao.CampaignDAO, com.charity.model.Campaign, com.charity.model.User, com.charity.util.DBConnection, java.util.List, java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    CampaignDAO dao = new CampaignDAO();
    List<Campaign> campaigns = dao.getActiveCampaigns();

    double totalDonated = 0;
    int donationCount = 0;
    String topCampaign = "—";

    String sqlStats = "SELECT SUM(d.amount) as total, COUNT(*) as cnt, " +
                      "(SELECT c2.title FROM donations d2 JOIN campaigns c2 ON d2.campaign_id=c2.id " +
                      " WHERE d2.user_id=? GROUP BY d2.campaign_id ORDER BY SUM(d2.amount) DESC LIMIT 1) as top_campaign " +
                      "FROM donations d WHERE d.user_id=?";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sqlStats)) {
        ps.setInt(1, user.getId());
        ps.setInt(2, user.getId());
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            totalDonated  = rs.getDouble("total");
            donationCount = rs.getInt("cnt");
            if (rs.getString("top_campaign") != null) topCampaign = rs.getString("top_campaign");
        }
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Donor Dashboard | Palestine Charity</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400;0,600;1,400&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        [data-theme="dark"] {
            --bg:       #0b0e14;
            --surface:  #13171f;
            --surface2: #1a1f2b;
            --border:   rgba(255,255,255,0.06);
            --text:     #e6e8f0;
            --text2:    #9ba3b8;
            --muted:    #5a6278;
            --shadow:   rgba(0,0,0,0.5);
        }
        [data-theme="light"] {
            --bg:       #f2f4f8;
            --surface:  #ffffff;
            --surface2: #f7f8fc;
            --border:   rgba(0,0,0,0.07);
            --text:     #181c2a;
            --text2:    #4a5068;
            --muted:    #9ba3b8;
            --shadow:   rgba(0,0,0,0.07);
        }
        :root {
            --green:     #1db954;
            --green-dim: rgba(29,185,84,0.12);
            --red:       #e63946;
            --gold:      #f4a261;
            --blue:      #457b9d;
            --radius:    12px;
        }

        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            transition: background .25s, color .25s;
        }

        /* ── NAV ─────────────────────────────── */
        nav {
            position: sticky; top: 0; z-index: 200;
            background: var(--surface);
            border-bottom: 1px solid var(--border);
            padding: 0 40px;
            display: flex; align-items: center; justify-content: space-between;
            height: 62px;
            backdrop-filter: blur(12px);
            transition: background .25s, border-color .25s;
        }
        .nav-brand { display: flex; align-items: center; gap: 10px; }
        .nav-brand-icon {
            width: 32px; height: 32px; border-radius: 8px;
            background: var(--green); display: flex; align-items: center;
            justify-content: center; font-size: 16px;
        }
        .nav-brand-text { font-family: 'Lora', serif; font-size: 17px; font-weight: 600; }
        .nav-brand-text span { color: var(--green); }
        .nav-right { display: flex; align-items: center; gap: 16px; }
        .nav-user { font-size: 13px; color: var(--text2); }
        .nav-user strong { color: var(--text); font-weight: 600; }
        .theme-btn {
            width: 34px; height: 34px; border-radius: 8px;
            background: var(--surface2); border: 1px solid var(--border);
            cursor: pointer; display: flex; align-items: center;
            justify-content: center; font-size: 15px; transition: border-color .2s;
        }
        .theme-btn:hover { border-color: var(--green); }
        .nav-logout {
            font-size: 12.5px; font-weight: 500; color: var(--muted);
            text-decoration: none; padding: 7px 14px;
            border: 1px solid var(--border); border-radius: 7px;
            transition: all .18s;
        }
        .nav-logout:hover { color: var(--red); border-color: rgba(230,57,70,0.3); background: rgba(230,57,70,0.06); }

        /* ── LAYOUT ──────────────────────────── */
        .page { max-width: 1180px; margin: 0 auto; padding: 36px 40px 60px; }

        /* ── HERO ────────────────────────────── */
        .hero {
            border-radius: var(--radius);
            background: linear-gradient(135deg, #0d2b1a 0%, #0b1d2e 60%, #1a0d0d 100%);
            border: 1px solid rgba(29,185,84,0.15);
            padding: 36px 40px;
            margin-bottom: 28px;
            position: relative;
            overflow: hidden;
        }
        .hero::before {
            content: '🇵🇸';
            position: absolute; right: -10px; top: -20px;
            font-size: 140px; opacity: .06; pointer-events: none;
            transform: rotate(-10deg);
        }
        .hero-label { font-size: 11px; letter-spacing: 1.2px; text-transform: uppercase; color: var(--green); font-weight: 600; margin-bottom: 8px; }
        .hero-title { font-family: 'Lora', serif; font-size: 28px; font-weight: 600; color: #e6e8f0; margin-bottom: 6px; }
        .hero-sub { font-size: 13.5px; color: #6b7a94; max-width: 520px; line-height: 1.6; }

        /* ── STAT CARDS ──────────────────────── */
        .stats-row { display: grid; grid-template-columns: repeat(3,1fr); gap: 16px; margin-bottom: 32px; }
        .stat-card {
            background: var(--surface); border: 1px solid var(--border);
            border-radius: var(--radius); padding: 20px 22px;
            box-shadow: 0 1px 4px var(--shadow);
            transition: border-color .2s, background .25s;
            animation: fadeUp .4s ease both;
        }
        .stat-card:hover { border-color: rgba(128,128,128,0.18); }
        .stat-card:nth-child(1){animation-delay:.05s;}
        .stat-card:nth-child(2){animation-delay:.10s;}
        .stat-card:nth-child(3){animation-delay:.15s;}
        .stat-icon { font-size: 22px; margin-bottom: 12px; }
        .stat-label { font-size: 11px; color: var(--muted); text-transform: uppercase; letter-spacing: .8px; margin-bottom: 6px; }
        .stat-value { font-size: 24px; font-weight: 600; }
        .stat-value.green { color: var(--green); }
        .stat-note { font-size: 11.5px; color: var(--muted); margin-top: 6px; }

        /* ── SECTION TITLE ───────────────────── */
        .section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; }
        .section-title { font-family: 'Lora', serif; font-size: 19px; font-weight: 600; }
        .section-badge {
            font-size: 11.5px; font-weight: 500; color: var(--green);
            background: var(--green-dim); padding: 4px 10px; border-radius: 20px;
        }

        /* ── CAMPAIGN CARDS ──────────────────── */
        .campaigns-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px,1fr)); gap: 18px; margin-bottom: 40px; }
        .camp-card {
            background: var(--surface); border: 1px solid var(--border);
            border-radius: var(--radius); overflow: hidden;
            box-shadow: 0 1px 4px var(--shadow);
            transition: border-color .2s, transform .2s, background .25s;
            animation: fadeUp .4s ease both;
        }
        .camp-card:hover { border-color: rgba(29,185,84,0.25); transform: translateY(-2px); }
        .camp-card-top { padding: 20px 20px 16px; }
        .camp-status { display: inline-flex; align-items: center; gap: 5px; font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: .7px; margin-bottom: 10px; }
        .camp-status.active { color: var(--green); }
        .camp-status.active::before { content:''; width:6px; height:6px; border-radius:50%; background:var(--green); animation: pulse 1.8s infinite; }
        .camp-status.complete { color: var(--blue); }
        .camp-title { font-family: 'Lora', serif; font-size: 16px; font-weight: 600; margin-bottom: 7px; line-height: 1.4; }
        .camp-desc { font-size: 13px; color: var(--text2); line-height: 1.6; margin-bottom: 14px; }
        .camp-meta { display: flex; justify-content: space-between; font-size: 12.5px; color: var(--muted); margin-bottom: 10px; }
        .camp-meta strong { color: var(--text); font-weight: 600; }
        .prog-track { background: var(--surface2); border-radius: 99px; height: 5px; overflow: hidden; margin-bottom: 16px; }
        .prog-fill { height: 5px; border-radius: 99px; background: linear-gradient(90deg, var(--green), #56efb0); transition: width .7s cubic-bezier(.4,0,.2,1); }
        .prog-fill.warn { background: linear-gradient(90deg, var(--gold), #ffd580); }
        .camp-card-bottom { padding: 14px 20px; border-top: 1px solid var(--border); background: var(--surface2); display: flex; gap: 8px; align-items: center; transition: background .25s; }
        .donate-input {
            flex: 1; background: var(--surface); border: 1px solid var(--border);
            color: var(--text); padding: 9px 12px; border-radius: 7px;
            font-size: 13.5px; font-family: inherit; outline: none;
            transition: border-color .18s, box-shadow .18s, background .25s;
        }
        .donate-input:focus { border-color: var(--green); box-shadow: 0 0 0 3px rgba(29,185,84,0.1); }
        .btn-donate {
            background: var(--green); color: #051a0d; border: none;
            padding: 9px 18px; border-radius: 7px; font-size: 13px;
            font-weight: 700; cursor: pointer; white-space: nowrap;
            font-family: inherit; transition: opacity .18s, transform .1s;
        }
        .btn-donate:hover { opacity: .88; transform: translateY(-1px); }
        .btn-donate:active { transform: translateY(0); }
        .btn-donate:disabled { opacity: .45; cursor: not-allowed; transform: none; }

        /* ── HISTORY TABLE ───────────────────── */
        .history-wrap { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius); overflow: hidden; box-shadow: 0 1px 4px var(--shadow); transition: background .25s, border-color .25s; }
        .table-toolbar { padding: 16px 20px; border-bottom: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center; }
        .search-input {
            background: var(--surface2); border: 1px solid var(--border);
            color: var(--text); padding: 8px 12px 8px 32px; border-radius: 7px;
            font-size: 13px; font-family: inherit; outline: none;
            transition: border-color .18s, background .25s; width: 200px;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='%235a6278' stroke-width='2'%3E%3Ccircle cx='11' cy='11' r='8'/%3E%3Cpath d='m21 21-4.35-4.35'/%3E%3C/svg%3E");
            background-repeat: no-repeat; background-position: 10px center;
        }
        .search-input:focus { border-color: var(--green); }
        table { width: 100%; border-collapse: collapse; }
        thead th {
            padding: 11px 18px; text-align: left; font-size: 11px;
            font-weight: 600; color: var(--muted); text-transform: uppercase;
            letter-spacing: .8px; border-bottom: 1px solid var(--border);
            background: var(--surface2); transition: background .25s;
        }
        tbody tr { border-bottom: 1px solid var(--border); transition: background .15s; }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: rgba(128,128,128,0.04); }
        td { padding: 13px 18px; font-size: 13.5px; vertical-align: middle; }
        .amount-green { color: var(--green); font-weight: 600; }
        .empty-state { text-align: center; padding: 48px 24px; color: var(--muted); font-size: 13px; }

        /* ── QUOTE BANNER ────────────────────── */
        .quote-banner {
            border-radius: var(--radius); border: 1px solid rgba(244,162,97,0.2);
            background: linear-gradient(135deg, rgba(244,162,97,0.06), rgba(230,57,70,0.04));
            padding: 20px 24px; margin-bottom: 32px;
            display: flex; gap: 16px; align-items: flex-start;
        }
        .quote-icon { font-size: 28px; flex-shrink: 0; margin-top: 2px; }
        .quote-text { font-family: 'Lora', serif; font-size: 14.5px; font-style: italic; color: var(--text2); line-height: 1.7; }
        .quote-text strong { color: var(--gold); font-style: normal; font-size: 12px; display: block; margin-top: 6px; font-family: 'DM Sans', sans-serif; letter-spacing: .5px; }

        /* ── UTILS ───────────────────────────── */
        .swal2-popup { font-family: 'DM Sans', sans-serif !important; border-radius: 14px !important; }
        .swal2-title { font-family: 'Lora', serif !important; font-size: 20px !important; }
        .swal2-confirm, .swal2-cancel { font-family: 'DM Sans', sans-serif !important; border-radius: 8px !important; font-weight: 600 !important; }

        @keyframes pulse { 0%,100%{opacity:1;}50%{opacity:.3;} }
        @keyframes fadeUp { from{opacity:0;transform:translateY(14px);}to{opacity:1;transform:none;} }

        ::-webkit-scrollbar { width: 5px; height: 5px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: var(--border); border-radius: 9px; }
    </style>
</head>
<body>

<!-- NAV -->
<nav>
    <div class="nav-brand">
        <div class="nav-brand-text">Palestine <span>Relief</span></div>
    </div>
    <div class="nav-right">
        <div class="nav-user">Signed in as <strong><%= user.getUsername() %></strong></div>
        <button class="theme-btn" onclick="toggleTheme()" id="themeBtn" title="Toggle theme">🌙</button>
        <a href="logout" class="nav-logout">Sign Out</a>
    </div>
</nav>

<div class="page">

    <!-- HERO -->
    <div class="hero">
        <div class="hero-label">Donor Portal</div>
        <div class="hero-title">Every Donation Saves Lives</div>
        <div class="hero-sub">Your contributions directly support humanitarian aid, medical relief, and essential supplies for families in Palestine. Thank you for standing with them.</div>
    </div>

    <!-- QUOTE -->
    <div class="quote-banner">
        <div class="quote-icon">📖</div>
        <div class="quote-text">
            "Whoever saves one life, it is as if he has saved all of mankind."
            <strong>— Al-Qur'an, Surah Al-Ma'idah 5:32</strong>
        </div>
    </div>

    <!-- STATS -->
    <div class="stats-row">
        <div class="stat-card">
            <div class="stat-icon">💚</div>
            <div class="stat-label">Total Donated</div>
            <div class="stat-value green">RM <%= String.format("%,.2f", totalDonated) %></div>
            <div class="stat-note">Your lifetime contributions</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon">🤲</div>
            <div class="stat-label">Donations Made</div>
            <div class="stat-value"><%= donationCount %></div>
            <div class="stat-note">Times you've given</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon">🏆</div>
            <div class="stat-label">Top Campaign</div>
            <div class="stat-value" style="font-size:15px;font-family:'Lora',serif;margin-top:4px;"><%= topCampaign %></div>
            <div class="stat-note">Your most supported cause</div>
        </div>
    </div>

    <!-- CAMPAIGNS -->
    <div class="section-header">
        <div class="section-title">Active Relief Campaigns</div>
        <div class="section-badge"><%= campaigns.size() %> campaigns</div>
    </div>

    <div class="campaigns-grid">
        <% for(Campaign c : campaigns) {
            double pct = c.getTargetAmount() > 0 ? Math.min((c.getCurrentAmount() / c.getTargetAmount()) * 100, 100) : 0;
            boolean complete = c.getCurrentAmount() >= c.getTargetAmount();
        %>
        <div class="camp-card">
            <div class="camp-card-top">
                <div class="camp-status <%= complete ? "complete" : "active" %>">
                    <%= complete ? "✓ Funded" : "Active" %>
                </div>
                <div class="camp-title"><%= c.getTitle() %></div>
                <div class="camp-desc"><%= c.getDescription() %></div>
                <div class="camp-meta">
                    <span>Goal: <strong>RM <%= String.format("%,.0f", c.getTargetAmount()) %></strong></span>
                    <span>Raised: <strong style="color:var(--green);">RM <%= String.format("%,.0f", c.getCurrentAmount()) %></strong></span>
                </div>
                <div class="prog-track">
                    <div class="prog-fill <%= pct >= 100 ? "warn" : "" %>" style="width:<%= pct %>%;"></div>
                </div>
            </div>
            <% if (!complete && !"INACTIVE".equals(c.getStatus())) { %>
            <div class="camp-card-bottom">
                <form action="donate" method="post" style="display:flex;gap:8px;width:100%;" onsubmit="return validateDonate(this)">
                    <input type="hidden" name="campaignId" value="<%= c.getId() %>">
                    <input type="number" name="amount" placeholder="Amount (RM)" min="1" step="0.01"
                           class="donate-input" required>
                    <button type="submit" class="btn-donate">Donate</button>
                </form>
            </div>
            <% } else { %>
            <div class="camp-card-bottom" style="justify-content:center;">
                <% if ("INACTIVE".equals(c.getStatus())) { %>
                    <span style="font-size:12.5px;color:var(--red);font-weight:500;">Donations Paused</span>
                <% } else { %>
                    <span style="font-size:12.5px;color:var(--blue);font-weight:500;">Fully Funded, Thank you!</span>
                <% } %>
            </div>
            <% } %>
        </div>
        <% } %>
        <% if (campaigns.isEmpty()) { %>
        <div style="grid-column:1/-1;text-align:center;padding:48px;color:var(--muted);font-size:13px;">No campaigns available at the moment.</div>
        <% } %>
    </div>

    <!-- HISTORY -->
    <div class="section-header">
        <div class="section-title">My Donation History</div>
    </div>
    <div class="history-wrap">
        <div class="table-toolbar">
            <span style="font-size:13px;color:var(--muted);">All your past contributions</span>
            <input type="text" class="search-input" placeholder="Search..." oninput="filterHistory(this.value)">
        </div>
        <table>
            <thead>
                <tr>
                    <th>Campaign</th>
                    <th>Amount</th>
                    <th>Date &amp; Time</th>
                </tr>
            </thead>
            <tbody id="historyBody">
                <%
                    String sql = "SELECT c.title, d.amount, d.donation_date FROM donations d " +
                                 "JOIN campaigns c ON d.campaign_id = c.id " +
                                 "WHERE d.user_id = ? ORDER BY d.donation_date DESC";
                    boolean hasHistory = false;
                    try (Connection conn = DBConnection.getConnection();
                         PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setInt(1, user.getId());
                        ResultSet rs = ps.executeQuery();
                        while (rs.next()) {
                            hasHistory = true;
                %>
                <tr>
                    <td><strong><%= rs.getString("title") %></strong></td>
                    <td class="amount-green">RM <%= String.format("%,.2f", rs.getDouble("amount")) %></td>
                    <td style="color:var(--muted);font-size:12.5px;"><%= rs.getTimestamp("donation_date") %></td>
                </tr>
                <%      }
                    } catch (Exception e) { e.printStackTrace(); }
                    if (!hasHistory) {
                %>
                <tr><td colspan="3"><div class="empty-state">You haven't made any donations yet. Start giving today! 🤲</div></td></tr>
                <% } %>
            </tbody>
        </table>
    </div>

</div><!-- /page -->

<script>
    /* ── THEME ───────────────────────────── */
    var html = document.documentElement;
    var themeBtn = document.getElementById('themeBtn');

    (function() {
        var saved = localStorage.getItem('donorTheme') || 'dark';
        applyTheme(saved);
    })();

    function applyTheme(theme) {
        html.setAttribute('data-theme', theme);
        themeBtn.textContent = theme === 'dark' ? '☀️' : '🌙';
        localStorage.setItem('donorTheme', theme);
    }

    function toggleTheme() {
        applyTheme(html.getAttribute('data-theme') === 'dark' ? 'light' : 'dark');
    }

    function getSwalBase() {
        var isDark = html.getAttribute('data-theme') === 'dark';
        return {
            background: isDark ? '#13171f' : '#ffffff',
            color:      isDark ? '#e6e8f0' : '#181c2a',
            confirmButtonColor: '#1db954',
        };
    }

    /* ── DONATE VALIDATION ───────────────── */
    function validateDonate(form) {
        var amt = parseFloat(form.amount.value);
        if (!amt || amt < 1) {
            Swal.fire(Object.assign({}, getSwalBase(), {
                title: 'Invalid Amount',
                text: 'Please enter a minimum donation of RM 1.00.',
                icon: 'warning', iconColor: '#f4a261',
            }));
            return false;
        }
        return true;
    }

    /* ── HISTORY FILTER ──────────────────── */
    function filterHistory(q) {
        document.querySelectorAll('#historyBody tr').forEach(function(r) {
            r.style.display = r.textContent.toLowerCase().includes(q.toLowerCase()) ? '' : 'none';
        });
    }

    /* ── URL MESSAGES ────────────────────── */
    var params = new URLSearchParams(window.location.search);
    if (params.get('status') === 'success') {
        Swal.fire(Object.assign({}, getSwalBase(), {
            title: 'Donation Received! 💚',
            html: '<p style="font-size:14px;line-height:1.6;">JazakAllah Khayran for your generosity.<br>Your contribution makes a real difference.</p>',
            icon: 'success', iconColor: '#1db954',
            confirmButtonText: 'Continue',
        }));
        window.history.replaceState({}, document.title, window.location.pathname);
    }
    if (params.get('status') === 'error') {
        Swal.fire(Object.assign({}, getSwalBase(), {
            title: 'Something went wrong',
            text: 'Your donation could not be processed. Please try again.',
            icon: 'error', iconColor: '#e63946',
        }));
        window.history.replaceState({}, document.title, window.location.pathname);
    }
</script>
</body>
</html>
