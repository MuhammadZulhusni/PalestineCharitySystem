<%@ page import="com.charity.dao.CampaignDAO, com.charity.model.Campaign, com.charity.model.User, com.charity.util.DBConnection, java.util.List, java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    // ── ACCESS CONTROL ──────────────────────────────────────────
    // Get the logged-in user from session
    // If no user in session OR user is not ADMIN → redirect to login
    User user = (User) session.getAttribute("user");
    if (user == null || !"ADMIN".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel | Charity System</title>

    <%-- Google Fonts: DM Sans (body text) & Playfair Display (headings) --%>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">

    <%-- SweetAlert2: used for all modals, confirmations, and notifications --%>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        /* ── CSS VARIABLES (THEME) ──────────────────────────────
           Two themes: dark and light.
           Switching data-theme attribute on <html> swaps all colors.
           Theme is saved to localStorage so it persists across visits. */
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        [data-theme="dark"] {
            --bg:      #0f1117;
            --surface: #171b26;
            --surface2:#1e2333;
            --border:  rgba(255,255,255,0.07);
            --text:    #e8eaf0;
            --text2:   #b0b8c8;
            --muted:   #6b7280;
            --shadow:  rgba(0,0,0,0.4);
        }
        [data-theme="light"] {
            --bg:      #f0f2f7;
            --surface: #ffffff;
            --surface2:#f5f6fa;
            --border:  rgba(0,0,0,0.08);
            --text:    #1a1d2e;
            --text2:   #4a5568;
            --muted:   #9ca3af;
            --shadow:  rgba(0,0,0,0.08);
        }

        /* ── GLOBAL COLOR TOKENS ────────────────────────────────
           Accent colors shared across both themes */
        :root {
            --green:    #00c96e;
            --green-dim:rgba(0,201,110,0.12);
            --red:      #ff4f5e;
            --amber:    #ffb347;
            --blue:     #4a9eff;
            --radius:   10px;
        }

        /* ── BASE BODY ──────────────────────────────────────────
           Smooth transition when switching dark/light theme */
        body { font-family:'DM Sans',sans-serif; background:var(--bg); color:var(--text); min-height:100vh; padding:0; transition:background .25s,color .25s; }

        /* ── SIDEBAR ────────────────────────────────────────────
           Fixed left sidebar 220px wide containing logo,
           navigation links, theme toggle, user info, logout */
        .sidebar { position:fixed; top:0; left:0; width:220px; height:100vh; background:var(--surface); border-right:1px solid var(--border); display:flex; flex-direction:column; padding:28px 0; z-index:100; transition:background .25s,border-color .25s; }
        .sidebar-logo { padding:0 24px 28px; border-bottom:1px solid var(--border); margin-bottom:16px; }
        .sidebar-logo span { font-family:'Playfair Display',serif; font-size:20px; color:var(--green); letter-spacing:.3px; }
        .sidebar-logo small { display:block; color:var(--muted); font-size:11px; margin-top:2px; letter-spacing:.5px; text-transform:uppercase; }

        /* Nav items = active state has green left border & green text */
        .nav-item { display:flex; align-items:center; gap:12px; padding:11px 24px; font-size:13.5px; font-weight:500; color:var(--muted); cursor:pointer; transition:all .18s; border-left:2px solid transparent; text-decoration:none; }
        .nav-item:hover { color:var(--text); background:rgba(128,128,128,0.06); }
        .nav-item.active { color:var(--green); border-left-color:var(--green); background:var(--green-dim); }
        .nav-item svg { flex-shrink:0; }

        /* Sidebar footer: theme toggle & user info & logout button */
        .sidebar-footer { margin-top:auto; padding:20px 24px; border-top:1px solid var(--border); }
        .user-pill { display:flex; align-items:center; gap:10px; }
        .avatar { width:32px; height:32px; border-radius:50%; background:var(--green-dim); border:1px solid var(--green); display:flex; align-items:center; justify-content:center; font-size:13px; font-weight:600; color:var(--green); }
        .user-name { font-size:13px; font-weight:500; }
        .user-role { font-size:11px; color:var(--muted); }
        .logout-btn { margin-top:12px; display:block; width:100%; background:rgba(255,79,94,0.1); border:1px solid rgba(255,79,94,0.25); color:var(--red); padding:9px; border-radius:var(--radius); font-size:12.5px; font-weight:500; cursor:pointer; text-align:center; text-decoration:none; transition:all .18s; }
        .logout-btn:hover { background:rgba(255,79,94,0.2); }

        /* ── THEME TOGGLE SWITCH ────────────────────────────────
           Clicking toggles dark/light mode via JS toggleTheme() */
        .theme-toggle { display:flex; align-items:center; justify-content:space-between; margin-bottom:12px; padding:8px 10px; background:var(--surface2); border-radius:8px; border:1px solid var(--border); cursor:pointer; transition:background .2s,border-color .2s; }
        .theme-toggle:hover { border-color:var(--green); }
        .theme-toggle-label { font-size:12px; color:var(--muted); font-weight:500; user-select:none; }
        .toggle-switch { width:36px; height:20px; border-radius:10px; background:var(--surface2); border:1px solid var(--border); position:relative; cursor:pointer; transition:background .2s; flex-shrink:0; }
        .toggle-switch.on { background:var(--green); border-color:var(--green); }
        .toggle-knob { position:absolute; top:2px; left:2px; width:14px; height:14px; border-radius:50%; background:var(--muted); transition:transform .2s,background .2s; }
        .toggle-switch.on .toggle-knob { transform:translateX(16px); background:#fff; }

        /* ── MAIN CONTENT AREA ──────────────────────────────────
           Offset left by 220px to clear the fixed sidebar */
        .main { margin-left:220px; padding:32px 36px; min-height:100vh; }
        .topbar { display:flex; justify-content:space-between; align-items:center; margin-bottom:32px; }
        .page-title { font-family:'Playfair Display',serif; font-size:26px; font-weight:600; }
        .page-sub { color:var(--muted); font-size:13px; margin-top:3px; }

        /* Animated green pulsing "System Live" badge in topbar */
        .badge-live { display:inline-flex; align-items:center; gap:6px; background:var(--green-dim); border:1px solid rgba(0,201,110,0.3); color:var(--green); padding:5px 12px; border-radius:20px; font-size:12px; font-weight:500; }
        .badge-live::before { content:''; width:6px; height:6px; border-radius:50%; background:var(--green); animation:pulse 1.8s infinite; }
        @keyframes pulse { 0%,100%{opacity:1;}50%{opacity:.3;} }

        /* ── STAT CARDS ─────────────────────────────────────────
           4-column grid showing: Total Campaigns, Total Raised,
           Funding Goal, Unique Donors */
        .stats-row { display:grid; grid-template-columns:repeat(4,1fr); gap:16px; margin-bottom:28px; }
        .stat-card { background:var(--surface); border:1px solid var(--border); border-radius:var(--radius); padding:20px 22px; transition:border-color .2s,background .25s; box-shadow:0 1px 4px var(--shadow); }
        .stat-card:hover { border-color:rgba(128,128,128,0.2); }
        .stat-label { font-size:11px; color:var(--muted); text-transform:uppercase; letter-spacing:.8px; margin-bottom:10px; }
        .stat-value { font-size:26px; font-weight:600; line-height:1; }
        .stat-value.green{color:var(--green);} .stat-value.blue{color:var(--blue);} .stat-value.amber{color:var(--amber);}
        .stat-note { font-size:11.5px; color:var(--muted); margin-top:8px; }

        /* ── SECTION CARDS ──────────────────────────────────────
           Each section (campaigns, donations, users, new campaign)
           is wrapped in a .card. Sections are shown/hidden via JS
           showSection() when a sidebar nav item is clicked. */
        .card { background:var(--surface); border:1px solid var(--border); border-radius:var(--radius); margin-bottom:24px; overflow:hidden; transition:background .25s,border-color .25s; box-shadow:0 1px 4px var(--shadow); }
        .card-header { display:flex; justify-content:space-between; align-items:center; padding:20px 24px; border-bottom:1px solid var(--border); }
        .card-title { font-size:14px; font-weight:600; letter-spacing:.2px; }
        .card-body { padding:24px; }

        /* ── NEW CAMPAIGN FORM ──────────────────────────────────
           4-column grid: Title, Target, Description, Button */
        .form-row { display:grid; grid-template-columns:1fr 1fr 2fr auto; gap:14px; align-items:end; }
        .field { display:flex; flex-direction:column; gap:6px; }
        .field label { font-size:11.5px; color:var(--muted); font-weight:500; text-transform:uppercase; letter-spacing:.6px; }
        .field input { background:var(--surface2); border:1px solid var(--border); color:var(--text); padding:10px 13px; border-radius:7px; font-size:13.5px; font-family:inherit; transition:border-color .18s,box-shadow .18s,background .25s; outline:none; }
        .field input:focus { border-color:var(--green); box-shadow:0 0 0 3px rgba(0,201,110,0.1); }
        .btn-primary { background:var(--green); color:#0a1a10; border:none; padding:10px 22px; border-radius:7px; font-size:13.5px; font-weight:600; cursor:pointer; white-space:nowrap; transition:opacity .18s,transform .1s; font-family:inherit; }
        .btn-primary:hover { opacity:.88; transform:translateY(-1px); }
        .btn-primary:active { transform:translateY(0); }

        /* ── DATA TABLES ────────────────────────────────────────
           Shared styles for campaigns table, donation log,
           and users table */
        table { width:100%; border-collapse:collapse; }
        thead th { padding:11px 16px; text-align:left; font-size:11px; font-weight:600; color:var(--muted); text-transform:uppercase; letter-spacing:.8px; border-bottom:1px solid var(--border); background:var(--surface2); transition:background .25s; }
        tbody tr { border-bottom:1px solid var(--border); transition:background .15s; }
        tbody tr:last-child { border-bottom:none; }
        tbody tr:hover { background:rgba(128,128,128,0.04); }
        td { padding:13px 16px; font-size:13.5px; vertical-align:middle; }

        /* ── PROGRESS BAR ───────────────────────────────────────
           Shows donation progress: currentAmount / targetAmount.
           Green by default, amber/yellow when fully funded. */
        .progress-wrap { min-width:130px; }
        .progress-track { background:var(--surface2); border-radius:99px; height:6px; margin-bottom:5px; overflow:hidden; }
        .progress-fill { height:6px; border-radius:99px; background:linear-gradient(90deg,var(--green),#00ffaa); transition:width .6s cubic-bezier(.4,0,.2,1); }
        .progress-fill.warn { background:linear-gradient(90deg,var(--amber),#ffd080); }
        .progress-pct { font-size:11.5px; color:var(--muted); }

        /* ── ACTION BUTTONS ─────────────────────────────────────
           Per-row buttons in campaign table:
           View (blue) | Edit (amber) | Deactivate/Activate (red/green) | Delete (red) */
        .actions { display:flex; gap:6px; flex-wrap:wrap; }
        .btn-action { padding:6px 12px; border:none; border-radius:6px; font-size:12px; font-weight:500; cursor:pointer; font-family:inherit; transition:opacity .15s,transform .1s; }
        .btn-action:hover { opacity:.8; transform:translateY(-1px); }
        .btn-view-a    { background:rgba(74,158,255,0.15);  color:var(--blue);  border:1px solid rgba(74,158,255,0.25); }
        .btn-edit-a    { background:rgba(255,179,71,0.15);  color:var(--amber); border:1px solid rgba(255,179,71,0.25); }
        .btn-delete-a  { background:rgba(255,79,94,0.12);   color:var(--red);   border:1px solid rgba(255,79,94,0.25); }
        .btn-toggle-off{ background:rgba(255,79,94,0.1);    color:var(--red);   border:1px solid rgba(255,79,94,0.25); }
        .btn-toggle-on { background:rgba(0,201,110,0.1);    color:var(--green); border:1px solid rgba(0,201,110,0.25); }

        /* ── STATUS PILLS ───────────────────────────────────────
           Small colored badges showing campaign status:
           Active (green) | Completed (blue) | Inactive (red) */
        .pill { display:inline-block; padding:3px 10px; border-radius:20px; font-size:11.5px; font-weight:500; }
        .pill-active    { background:var(--green-dim); color:var(--green); }
        .pill-complete  { background:rgba(74,158,255,0.12); color:var(--blue); }
        .pill-inactive  { background:rgba(255,79,94,0.1);   color:var(--red); }

        /* ── SEARCH BAR ─────────────────────────────────────────
           Filters table rows in real-time using JS filterTable() */
        .table-toolbar { display:flex; align-items:center; gap:12px; }
        .search-input { background:var(--surface2); border:1px solid var(--border); color:var(--text); padding:8px 12px 8px 34px; border-radius:7px; font-size:13px; font-family:inherit; outline:none; transition:border-color .18s,background .25s; width:220px; background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='%236b7280' stroke-width='2'%3E%3Ccircle cx='11' cy='11' r='8'/%3E%3Cpath d='m21 21-4.35-4.35'/%3E%3C/svg%3E"); background-repeat:no-repeat; background-position:10px center; }
        .search-input:focus { border-color:var(--green); }

        .amount-green { color:var(--green); font-weight:600; }
        .empty-state { text-align:center; padding:48px 24px; color:var(--muted); font-size:13px; }

        /* ── SWEETALERT2 OVERRIDES ──────────────────────────────
           Match SweetAlert2 popup font and shape to the dashboard */
        .swal2-popup { font-family:'DM Sans',sans-serif !important; border-radius:12px !important; }
        .swal2-title { font-family:'Playfair Display',serif !important; font-size:20px !important; }
        .swal2-confirm { font-family:'DM Sans',sans-serif !important; border-radius:7px !important; font-weight:600 !important; }
        .swal2-cancel  { font-family:'DM Sans',sans-serif !important; border-radius:7px !important; font-weight:500 !important; }

        /* ── EDIT MODAL FIELDS ──────────────────────────────────
           Styled input fields inside SweetAlert2 edit campaign modal */
        .edit-field { display:flex; flex-direction:column; gap:5px; margin-bottom:14px; text-align:left; }
        .edit-field label { font-size:11px; font-weight:600; text-transform:uppercase; letter-spacing:.6px; }
        .edit-field input { padding:9px 12px; border-radius:7px; font-size:13.5px; font-family:'DM Sans',sans-serif; outline:none; width:100%; transition:border-color .18s,box-shadow .18s; }
        .edit-field input:focus { box-shadow:0 0 0 3px rgba(0,201,110,0.15); border-color:#00c96e !important; }
        .edit-current { font-size:11.5px; margin-top:3px; }
        .edit-stat-bar { display:flex; border-radius:8px; overflow:hidden; margin-bottom:18px; }
        .edit-stat { flex:1; padding:10px 14px; }
        .edit-stat-lbl { font-size:10px; text-transform:uppercase; letter-spacing:.6px; margin-bottom:4px; }
        .edit-stat-val { font-size:15px; font-weight:600; }

        /* ── LOADING SPINNER ────────────────────────────────────
           Shown inside edit modal while AJAX fetches campaign data */
        .spinner { width:22px; height:22px; border:2px solid rgba(128,128,128,0.2); border-top-color:#00c96e; border-radius:50%; animation:spin .7s linear infinite; margin:20px auto; }
        @keyframes spin { to{transform:rotate(360deg);} }

        /* ── DONOR HISTORY TABLE ────────────────────────────────
           Compact table inside View Campaign modal showing
           who donated, how much, and when */
        .donor-table { width:100%; border-collapse:collapse; font-size:13px; }
        .donor-table th { padding:8px 10px; text-align:left; font-size:11px; text-transform:uppercase; letter-spacing:.6px; border-bottom:1px solid rgba(128,128,128,0.15); }
        .donor-table td { padding:9px 10px; border-bottom:1px solid rgba(128,128,128,0.08); }

        /* Custom scrollbar = thin and subtle */
        ::-webkit-scrollbar { width:5px; height:5px; }
        ::-webkit-scrollbar-track { background:transparent; }
        ::-webkit-scrollbar-thumb { background:var(--border); border-radius:9px; }

        /* ── FADE UP ANIMATION ──────────────────────────────────
           Cards and stat cards animate in with a subtle upward fade
           when the page loads. Each stat card has a staggered delay. */
        @keyframes fadeUp { from{opacity:0;transform:translateY(12px);}to{opacity:1;transform:none;} }
        .card,.stat-card { animation:fadeUp .35s ease both; }
        .stat-card:nth-child(1){animation-delay:.05s;} .stat-card:nth-child(2){animation-delay:.10s;}
        .stat-card:nth-child(3){animation-delay:.15s;} .stat-card:nth-child(4){animation-delay:.20s;}
    </style>
</head>
<body>

<%-- ── SIDEBAR ──────────────────────────────────────────────────
     Fixed left navigation with 4 sections:
     Campaigns | Donation Log | New Campaign | Users
     Active section is highlighted with green border & background. --%>
<aside class="sidebar">
    <div class="sidebar-logo">
        <span>CharityAdmin</span>
        <small>Management Console</small>
    </div>

    <%-- Each nav item calls showSection() to show/hide the correct card --%>
    <a href="#campaigns" class="nav-item active" onclick="showSection('campaigns')">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 3h7v7H3zM14 3h7v7h-7zM14 14h7v7h-7zM3 14h7v7H3z"/></svg>
        Campaigns
    </a>
    <a href="#donations" class="nav-item" onclick="showSection('donations')">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
        Donation Log
    </a>
    <a href="#new-campaign" class="nav-item" onclick="showSection('new-campaign')">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
        New Campaign
    </a>
    <a href="#users" class="nav-item" onclick="showSection('users')">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
        Users
    </a>

    <div class="sidebar-footer">
        <%-- Theme toggle: clicking calls toggleTheme() to swap dark/light --%>
        <div class="theme-toggle" onclick="toggleTheme()">
            <span class="theme-toggle-label" id="theme-label">Dark Mode</span>
            <div class="toggle-switch on" id="themeSwitch"><div class="toggle-knob"></div></div>
        </div>

        <%-- Show first letter of admin username as avatar initial --%>
        <div class="user-pill">
            <div class="avatar"><%= user.getUsername().substring(0,1).toUpperCase() %></div>
            <div>
                <div class="user-name"><%= user.getUsername() %></div>
                <div class="user-role">Administrator</div>
            </div>
        </div>

        <%-- Sign out = calls LogoutServlet which invalidates session --%>
        <a href="logout" class="logout-btn">Sign Out</a>
    </div>
</aside>

<main class="main">
    <%-- Page title and live badge --%>
    <div class="topbar">
        <div>
            <div class="page-title">Dashboard</div>
            <div class="page-sub">Monitor and manage all charity campaigns</div>
        </div>
        <div class="badge-live">System Live</div>
    </div>

    <%-- ── SERVER-SIDE DATA LOADING ────────────────────────────
         Runs Java on the server before sending HTML to browser.
         1. Load all campaigns via CampaignDAO
         2. Calculate totals: target, raised, active count
         3. Query DB for total unique donor count (inline SQL) --%>
    <%
        CampaignDAO dao = new CampaignDAO();
        List<Campaign> campaigns = dao.getAllCampaigns();

        // Calculate summary stats for the 4 stat cards
        double totalTarget = 0, totalRaised = 0; int active = 0;
        for(Campaign c : campaigns){
            totalTarget += c.getTargetAmount();
            totalRaised += c.getCurrentAmount();
            if(c.getCurrentAmount() < c.getTargetAmount()) active++;
        }

        // Count unique donors = inline SQL (no DonationDAO exists)
        int totalCampaigns = campaigns.size(), totalDonors = 0;
        try(Connection _c=DBConnection.getConnection();
            PreparedStatement _p=_c.prepareStatement("SELECT COUNT(DISTINCT user_id) FROM donations");
            ResultSet _r=_p.executeQuery()){
            if(_r.next()) totalDonors=_r.getInt(1);
        } catch(Exception _e){}
    %>

    <%-- ── STAT CARDS ──────────────────────────────────────────
         4 summary cards: Campaigns | Raised | Goal | Donors --%>
    <div class="stats-row">
        <div class="stat-card">
            <div class="stat-label">Total Campaigns</div>
            <div class="stat-value blue"><%= totalCampaigns %></div>
            <div class="stat-note"><%= active %> still in progress</div>
        </div>
        <div class="stat-card">
            <div class="stat-label">Total Raised</div>
            <div class="stat-value green">RM <%= String.format("%,.0f",totalRaised) %></div>
            <div class="stat-note">Across all projects</div>
        </div>
        <div class="stat-card">
            <div class="stat-label">Funding Goal</div>
            <div class="stat-value amber">RM <%= String.format("%,.0f",totalTarget) %></div>
            <%-- Overall % = totalRaised / totalTarget × 100 --%>
            <div class="stat-note"><%= totalTarget>0 ? String.format("%.0f",(totalRaised/totalTarget)*100) : "0" %>% overall completion</div>
        </div>
        <div class="stat-card">
            <div class="stat-label">Unique Donors</div>
            <div class="stat-value"><%= totalDonors %></div>
            <div class="stat-note">Individual contributors</div>
        </div>
    </div>

    <%-- ── SECTION: NEW CAMPAIGN ───────────────────────────────
         Hidden by default. Shown when admin clicks "New Campaign"
         or the "+ New" button. Submits POST to AddCampaignServlet. --%>
    <div class="card" id="section-new-campaign" style="display:none;">
        <div class="card-header"><span class="card-title">Launch New Campaign</span></div>
        <div class="card-body">
            <form action="addCampaign" method="post" class="form-row">
                <div class="field"><label>Campaign Title</label><input type="text" name="title" placeholder="e.g. Clean Water Initiative" required></div>
                <div class="field"><label>Funding Target (RM)</label><input type="number" name="target" step="0.01" placeholder="0.00" required></div>
                <div class="field"><label>Short Description</label><input type="text" name="description" placeholder="Brief summary of the campaign" required></div>
                <button type="submit" class="btn-primary">Create Campaign</button>
            </form>
        </div>
    </div>

    <%-- ── SECTION: ALL CAMPAIGNS TABLE ───────────────────────
         Shown by default. Lists all campaigns with:
         progress bar, status pill, and action buttons.
         Search bar filters rows in real-time via filterTable(). --%>
    <div class="card" id="section-campaigns">
        <div class="card-header">
            <span class="card-title">All Campaigns</span>
            <div class="table-toolbar">
                <input type="text" class="search-input" placeholder="Search campaigns..." oninput="filterTable('campaignBody',this.value)">
                <button class="btn-primary" style="padding:8px 16px;font-size:13px;" onclick="showSection('new-campaign')">+ New</button>
            </div>
        </div>
        <table>
            <thead>
                <tr>
                    <th>Campaign</th><th>Goal</th><th>Raised</th>
                    <th>Progress</th><th>Status</th><th>Actions</th>
                </tr>
            </thead>
            <tbody id="campaignBody">
                <%-- Loop through each campaign and render a table row --%>
                <% for(Campaign c : campaigns) {
                    // Calculate progress % — capped at 100%
                    double pct = (c.getTargetAmount()>0) ? Math.min((c.getCurrentAmount()/c.getTargetAmount())*100,100) : 0;
                    // Fully funded if current >= target
                    boolean complete = c.getCurrentAmount()>=c.getTargetAmount();
                    // Inactive if admin deactivated it
                    boolean inactive = "INACTIVE".equals(c.getStatus());
                %>
                <tr>
                    <%-- Campaign name + truncated description --%>
                    <td>
                        <strong style="font-size:13.5px;"><%= c.getTitle() %></strong><br>
                        <small style="color:var(--muted);font-size:11.5px;">
                            <%= c.getDescription().length()>55 ? c.getDescription().substring(0,55)+"..." : c.getDescription() %>
                        </small>
                    </td>
                    <td>RM <%= String.format("%,.2f",c.getTargetAmount()) %></td>
                    <td class="amount-green">RM <%= String.format("%,.2f",c.getCurrentAmount()) %></td>

                    <%-- Progress bar: amber if complete, green if active --%>
                    <td>
                        <div class="progress-wrap">
                            <div class="progress-track">
                                <div class="progress-fill <%= pct>=100?"warn":"" %>" style="width:<%= pct %>%;"></div>
                            </div>
                            <span class="progress-pct"><%= String.format("%.1f",pct) %>%</span>
                        </div>
                    </td>

                    <%-- Status pill: Inactive (red) | Completed (blue) | Active (green) --%>
                    <td>
                        <span class="pill <%= inactive ? "pill-inactive" : (complete ? "pill-complete" : "pill-active") %>">
                            <%= inactive ? "Inactive" : (complete ? "Completed" : "Active") %>
                        </span>
                    </td>

                    <%-- Action buttons: View | Edit | Activate/Deactivate | Delete
                         All open SweetAlert2 confirmation modals before executing --%>
                    <td>
                        <div class="actions">
                            <button class="btn-action btn-view-a"
                                onclick="viewDetails(<%= c.getId() %>,'<%= c.getTitle().replace("'","\\'") %>','<%= c.getDescription().replace("'","\\'") %>')">View</button>
                            <button class="btn-action btn-edit-a"
                                onclick="openEditModal(<%= c.getId() %>)">Edit</button>
                            <%-- Toggle button label and color flips based on current status --%>
                            <button class="btn-action <%= inactive ? "btn-toggle-on" : "btn-toggle-off" %>"
                                onclick="confirmToggle(<%= c.getId() %>,'<%= c.getTitle().replace("'","\\'") %>','<%= c.getStatus() %>')">
                                <%= inactive ? "Activate" : "Deactivate" %>
                            </button>
                            <button class="btn-action btn-delete-a"
                                onclick="confirmDelete(<%= c.getId() %>,'<%= c.getTitle().replace("'","\\'") %>')">Delete</button>
                        </div>
                    </td>
                </tr>
                <% } %>
                <% if(campaigns.isEmpty()){ %>
                <tr><td colspan="6"><div class="empty-state">No campaigns yet. Create your first one.</div></td></tr>
                <% } %>
                <tr id="campaignBody-no-results" style="display:none;">
                    <td colspan="6"><div class="empty-state">No campaigns match your search.</div></td>
                </tr>
            </tbody>
        </table>
    </div>

    <%-- ── SECTION: DONATION LOG ───────────────────────────────
         Hidden by default. Shows all donations across all campaigns.
         Uses inline SQL JOIN across donations + users + campaigns tables.
         Search bar filters rows in real-time. --%>
    <div class="card" id="section-donations" style="display:none;">
        <div class="card-header">
            <span class="card-title">Global Donation Log</span>
            <div class="table-toolbar">
                <input type="text" class="search-input" placeholder="Search donors or campaigns..." oninput="filterTable('donationBody',this.value)">
            </div>
        </div>
        <table>
            <thead><tr><th>Date &amp; Time</th><th>Donor</th><th>Campaign</th><th>Amount</th></tr></thead>
            <tbody id="donationBody">
                <%
                    // Inline SQL: JOIN donations + users + campaigns
                    // Sorted newest first
                    String sqlLog="SELECT d.donation_date,u.username,c.title,d.amount " +
                                  "FROM donations d " +
                                  "JOIN users u ON d.user_id=u.id " +
                                  "JOIN campaigns c ON d.campaign_id=c.id " +
                                  "ORDER BY d.donation_date DESC";
                    try(Connection conn=DBConnection.getConnection();
                        PreparedStatement ps=conn.prepareStatement(sqlLog);
                        ResultSet rs=ps.executeQuery()){
                        while(rs.next()){
                %>
                <tr>
                    <td style="color:var(--muted);font-size:12.5px;"><%= rs.getTimestamp("donation_date") %></td>
                    <td><strong><%= rs.getString("username") %></strong></td>
                    <td style="color:var(--muted);"><%= rs.getString("title") %></td>
                    <td class="amount-green">RM <%= String.format("%,.2f",rs.getDouble("amount")) %></td>
                </tr>
                <% } } catch(Exception e){} %>
               <tr id="donationBody-no-results" style="display:none;">
                   <td colspan="4"><div class="empty-state">No donations match your search.</div></td>
               </tr>
            </tbody>
        </table>
    </div>

    <%-- ── SECTION: USER MANAGEMENT ───────────────────────────
         Hidden by default. Lists all users with role badge.
         Admin can add new users (Donor or Admin role) or delete existing ones.
         Cannot delete own account, protected both in JS and server-side. --%>
    <div class="card" id="section-users" style="display:none;">
        <div class="card-header">
            <span class="card-title">User Management</span>
            <%-- Opens Add User modal via JS openAddUserModal() --%>
            <button class="btn-primary" style="padding:8px 16px;font-size:13px;" onclick="openAddUserModal()">+ Add User</button>
        </div>
        <table>
            <thead>
                <tr><th>Username</th><th>Role</th><th>Actions</th></tr>
            </thead>
            <tbody id="userBody">
                <%
                    // Inline SQL: fetch all users sorted by role then username
                    String sqlUsers = "SELECT id, username, role FROM users ORDER BY role, username";
                    try (Connection uc = DBConnection.getConnection();
                         PreparedStatement up = uc.prepareStatement(sqlUsers);
                         ResultSet ur = up.executeQuery()) {
                        while (ur.next()) {
                            int uid      = ur.getInt("id");
                            String uname = ur.getString("username");
                            String urole = ur.getString("role");
                %>
                <tr>
                    <td><strong><%= uname %></strong></td>
                    <%-- Role pill: Admin (blue) | Donor (green) --%>
                    <td>
                        <span class="pill <%= "ADMIN".equals(urole) ? "pill-complete" : "pill-active" %>">
                            <%= "ADMIN".equals(urole) ? "Admin" : "Donor" %>
                        </span>
                    </td>
                    <%-- Delete button: passes uid, username, and current admin username
                         JS checks if username === currentAdmin before proceeding --%>
                    <td>
                        <div class="actions">
                            <button class="btn-action btn-delete-a"
                                onclick="confirmDeleteUser(<%= uid %>,'<%= uname.replace("'","\\'") %>','<%= user.getUsername() %>')">
                                Delete
                            </button>
                        </div>
                    </td>
                </tr>
                <%
                        }
                    } catch (Exception e) { e.printStackTrace(); }
                %>
            </tbody>
        </table>
    </div>
</main>

<%-- NOTE: JS template literals avoided here, all ${} replaced with string
     concatenation to prevent JSP EL (Expression Language) from intercepting
     and throwing 500 errors. --%>
<script>
    const html = document.documentElement;

    /* ── THEME ──────────────────────────────────────────────────
       On page load: read saved theme from localStorage (default: dark)
       applyTheme() sets data-theme on <html>, updates toggle switch label,
       and saves the new preference back to localStorage */
    (function(){
        const saved = localStorage.getItem('adminTheme') || 'dark';
        applyTheme(saved);
    })();

    function applyTheme(theme) {
        const isDark = theme === 'dark';
        html.setAttribute('data-theme', theme);
        document.getElementById('themeSwitch').classList.toggle('on', isDark);
        document.getElementById('theme-label').textContent = isDark ? 'Dark Mode' : 'Light Mode';
        localStorage.setItem('adminTheme', theme);
    }

    function toggleTheme() {
        applyTheme(html.getAttribute('data-theme') === 'dark' ? 'light' : 'dark');
    }

    /* ── SWEETALERT2 BASE CONFIG ────────────────────────────────
       Returns theme-aware base config for all SweetAlert2 modals.
       Background and text color match the current dark/light theme. */
    function getSwalBase() {
        const isDark = html.getAttribute('data-theme') === 'dark';
        return {
            background: isDark ? '#171b26' : '#ffffff',
            color:      isDark ? '#e8eaf0' : '#1a1d2e',
            confirmButtonColor: '#00c96e',
            cancelButtonColor:  isDark ? '#1e2333' : '#f0f2f7',
        };
    }

    /* ── COLORS HELPER ──────────────────────────────────────────
       Returns current theme color values as a JS object.
       Used when building HTML strings inside SweetAlert2 modals. */
    function getColors() {
        const isDark = html.getAttribute('data-theme') === 'dark';
        return {
            isDark,
            surface2: isDark ? '#1e2333' : '#f5f6fa',
            border:   isDark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.1)',
            text:     isDark ? '#e8eaf0' : '#1a1d2e',
            text2:    isDark ? '#b0b8c8' : '#4a5568',
            muted:    isDark ? '#6b7280' : '#9ca3af',
        };
    }

    /* ── SECTION NAV ────────────────────────────────────────────
       showSection(id), hides all sections then shows only the target one.
       Also updates sidebar nav active highlight to match. */
    const sections = ['campaigns','donations','new-campaign','users'];
    function showSection(id) {
        sections.forEach(function(s){
            var el = document.getElementById('section-' + s);
            if(el) el.style.display = s === id ? 'block' : 'none';
        });
        document.querySelectorAll('.nav-item').forEach(function(n){ n.classList.remove('active'); });
        var navMap = {campaigns:0, donations:1, 'new-campaign':2, users:3};
        var items  = document.querySelectorAll('.nav-item');
        if(navMap[id] !== undefined) items[navMap[id]].classList.add('active');
    }

    /* ── TABLE SEARCH ───────────────────────────────────────────
       filterTable(id, q) — loops every <tr> in the target tbody
       and hides rows that don't contain the search term */
        function filterTable(id, q) {
            var rows = document.querySelectorAll('#' + id + ' tr');
            var visibleCount = 0;

            rows.forEach(function(r) {
                // Skip the no-results row itself when counting
                if (r.id === id + '-no-results') return;
                var match = r.textContent.toLowerCase().includes(q.toLowerCase());
                r.style.display = match ? '' : 'none';
                if (match) visibleCount++;
            });

            var noResults = document.getElementById(id + '-no-results');
            if (noResults) noResults.style.display = visibleCount === 0 ? '' : 'none';
        }

    /* ── VIEW CAMPAIGN DETAILS ──────────────────────────────────
       Opens a SweetAlert2 modal showing campaign description
       and donor history table. Donor list is fetched via AJAX
       from get_campaign_donors.jsp?id=X and injected into the modal. */
    function viewDetails(id, title, desc) {
        var c = getColors();
        Swal.fire(Object.assign({}, getSwalBase(), {
            title: title,
            html:
                '<p style="font-size:11px;color:' + c.muted + ';text-transform:uppercase;letter-spacing:.7px;text-align:left;margin-bottom:5px;">Description</p>' +
                '<p style="color:' + c.text2 + ';font-size:13px;text-align:left;margin-bottom:12px;">' + desc + '</p>' +
                '<p style="font-size:11px;color:' + c.muted + ';text-transform:uppercase;letter-spacing:.7px;text-align:left;margin-bottom:6px;">Donor History</p>' +
                '<div style="max-height:280px;overflow-y:auto;border-radius:8px;border:1px solid ' + c.border + ';">' +
                    '<table class="donor-table">' +
                        '<thead><tr>' +
                            '<th style="color:' + c.muted + ';background:' + c.surface2 + ';">Donor</th>' +
                            '<th style="color:' + c.muted + ';background:' + c.surface2 + ';">Amount</th>' +
                            '<th style="color:' + c.muted + ';background:' + c.surface2 + ';">Date</th>' +
                        '</tr></thead>' +
                        '<tbody id="donor-list-content"><tr><td colspan="3"><div class="spinner"></div></td></tr></tbody>' +
                    '</table>' +
                '</div>',
            width: '580px',
            showCloseButton: true,
            showConfirmButton: false,
            didOpen: function() {
                // AJAX fetch donor list from get_campaign_donors.jsp
                fetch('get_campaign_donors.jsp?id=' + id)
                    .then(function(r){ return r.text(); })
                    .then(function(data){ document.getElementById('donor-list-content').innerHTML = data; });
            }
        }));
    }

    /* ── EDIT CAMPAIGN MODAL ────────────────────────────────────
       Step 1: Show loading spinner inside SweetAlert2
       Step 2: Fetch campaign data via AJAX from GetCampaignServlet
               (returns JSON: id, title, description, targetAmount,
                currentAmount, progressPct, status, complete)
       Step 3: Replace spinner with edit form pre-filled with current values
       Step 4: On confirm, redirect to editCampaign?id=X&title=...&target=...
               which is handled by EditCampaignServlet */
    async function openEditModal(id) {
        var c = getColors();

        // Step 1: Show loading state
        Swal.fire(Object.assign({}, getSwalBase(), {
            title: 'Edit Campaign',
            html: '<div class="spinner"></div><p style="color:' + c.muted + ';font-size:13px;margin-top:6px;">Fetching current data...</p>',
            width: '500px',
            showConfirmButton: false,
            showCancelButton: false,
            allowOutsideClick: false,
        }));

        // Step 2: AJAX fetch from GetCampaignServlet
        var data;
        try {
            var res = await fetch('getCampaign?id=' + id);
            if(!res.ok) throw new Error('HTTP ' + res.status);
            data = await res.json();
        } catch(err) {
            Swal.update({
                html: '<p style="color:#ff4f5e;font-size:13px;padding:12px 0;">Could not load campaign data.<br><small style="color:' + c.muted + '">' + err.message + '</small></p>',
                showCancelButton: true,
                showConfirmButton: false,
            });
            return;
        }

        // Step 3: Calculate display values
        var pct        = data.targetAmount > 0 ? Math.min((data.currentAmount / data.targetAmount) * 100, 100).toFixed(1) : '0.0';
        var fmtRaise   = parseFloat(data.currentAmount).toLocaleString('en-MY', {minimumFractionDigits:2});
        var fmtGoal    = parseFloat(data.targetAmount).toLocaleString('en-MY',  {minimumFractionDigits:2});
        var isComplete = parseFloat(data.currentAmount) >= parseFloat(data.targetAmount);
        var safeTitle  = (data.title       || '').replace(/"/g, '&quot;');
        var safeDesc   = (data.description || '').replace(/"/g, '&quot;');

        // Stat bar: shows Raised | Progress | Status at top of modal
        var statBar =
            '<div class="edit-stat-bar" style="background:' + c.surface2 + ';border:1px solid ' + c.border + ';">' +
                '<div class="edit-stat" style="border-right:1px solid ' + c.border + ';">' +
                    '<div class="edit-stat-lbl" style="color:' + c.muted + ';">Raised</div>' +
                    '<div class="edit-stat-val" style="color:#00c96e;">RM ' + fmtRaise + '</div>' +
                '</div>' +
                '<div class="edit-stat" style="border-right:1px solid ' + c.border + ';">' +
                    '<div class="edit-stat-lbl" style="color:' + c.muted + ';">Progress</div>' +
                    '<div class="edit-stat-val" style="color:' + c.text + ';">' + pct + '%</div>' +
                '</div>' +
                '<div class="edit-stat">' +
                    '<div class="edit-stat-lbl" style="color:' + c.muted + ';">Status</div>' +
                    // Color: blue=Completed, red=Inactive, green=Active
                    '<div class="edit-stat-val" style="color:' + (isComplete ? '#4a9eff' : (data.status === 'INACTIVE' ? '#ff4f5e' : '#00c96e')) + ';">' +
                        (isComplete ? 'Completed' : (data.status === 'INACTIVE' ? 'Inactive' : 'Active')) +
                    '</div>' +
                '</div>' +
            '</div>';

        // Edit fields: Title | Target | Description (pre-filled with current values)
        var fields =
            '<div class="edit-field">' +
                '<label style="color:' + c.muted + ';">Campaign Title</label>' +
                '<input id="swal-title" value="' + safeTitle + '" style="background:' + c.surface2 + ';border:1px solid ' + c.border + ';color:' + c.text + ';">' +
                '<span class="edit-current" style="color:' + c.muted + ';">Current: <strong style="color:' + c.text + ';">' + (data.title || '') + '</strong></span>' +
            '</div>' +
            '<div class="edit-field">' +
                '<label style="color:' + c.muted + ';">Funding Target (RM)</label>' +
                '<input id="swal-target" type="number" step="0.01" value="' + data.targetAmount + '" style="background:' + c.surface2 + ';border:1px solid ' + c.border + ';color:' + c.text + ';">' +
                '<span class="edit-current" style="color:' + c.muted + ';">Current goal: <strong style="color:#00c96e;">RM ' + fmtGoal + '</strong></span>' +
            '</div>' +
            '<div class="edit-field">' +
                '<label style="color:' + c.muted + ';">Description</label>' +
                '<input id="swal-desc" value="' + safeDesc + '" style="background:' + c.surface2 + ';border:1px solid ' + c.border + ';color:' + c.text + ';">' +
                '<span class="edit-current" style="color:' + c.muted + ';">Current: <strong style="color:' + c.text + ';">' + (data.description || '—') + '</strong></span>' +
            '</div>';

        // Step 4: Show filled edit modal
        await Swal.fire(Object.assign({}, getSwalBase(), {
            title: 'Edit Campaign',
            html: statBar + fields,
            width: '500px',
            showCancelButton: true,
            confirmButtonText: 'Save Changes',
            cancelButtonText: 'Cancel',
            focusConfirm: false,
            preConfirm: function() {
                var newTitle  = document.getElementById('swal-title').value.trim();
                var newTarget = document.getElementById('swal-target').value;
                var newDesc   = document.getElementById('swal-desc').value.trim();
                if(!newTitle || !newTarget) {
                    Swal.showValidationMessage('Title and target are required');
                    return false;
                }
                // Redirect to EditCampaignServlet with updated values as URL params
                window.location.href = 'editCampaign?id=' + id +
                    '&title='       + encodeURIComponent(newTitle) +
                    '&target='      + newTarget +
                    '&description=' + encodeURIComponent(newDesc);
            }
        }));
    }

    /* ── DELETE CAMPAIGN ────────────────────────────────────────
       Shows SweetAlert2 warning confirmation.
       On confirm = redirects to DeleteCampaignServlet.
       Servlet blocks deletion if campaign has existing donations. */
    function confirmDelete(id, title) {
        var c = getColors();
        Swal.fire(Object.assign({}, getSwalBase(), {
            title: 'Delete Campaign?',
            html: '<p style="color:' + c.text2 + ';">You are about to permanently remove <strong style="color:' + c.text + ';">' + title + '</strong>. This cannot be undone.</p>',
            icon: 'warning',
            iconColor: '#ff4f5e',
            showCancelButton: true,
            confirmButtonColor: '#ff4f5e',
            confirmButtonText: 'Yes, Delete',
            cancelButtonText: 'Cancel',
        })).then(function(r){ if(r.isConfirmed) window.location.href = 'deleteCampaign?id=' + id; });
    }

    /* ── TOGGLE CAMPAIGN STATUS ─────────────────────────────────
       Shows SweetAlert2 confirmation, wording changes based on current status.
       On confirm = redirects to ToggleCampaignServlet which flips
       ACTIVE to INACTIVE or INACTIVE to ACTIVE in the database. */
    function confirmToggle(id, title, currentStatus) {
        var c = getColors();
        var isActive = currentStatus === 'ACTIVE';
        Swal.fire(Object.assign({}, getSwalBase(), {
            title: isActive ? 'Deactivate Campaign?' : 'Activate Campaign?',
            html: '<p style="color:' + c.text2 + ';">' +
                  (isActive
                    ? 'Donors will no longer be able to donate to <strong style="color:' + c.text + ';">' + title + '</strong>.'
                    : 'This will re-enable donations for <strong style="color:' + c.text + ';">' + title + '</strong>.') +
                  '</p>',
            icon: 'warning',
            iconColor: isActive ? '#ff4f5e' : '#00c96e',
            showCancelButton: true,
            confirmButtonColor: isActive ? '#ff4f5e' : '#00c96e',
            confirmButtonText: isActive ? 'Yes, Deactivate' : 'Yes, Activate',
            cancelButtonText: 'Cancel',
        })).then(function(r) {
            if (r.isConfirmed) window.location.href = 'toggleCampaign?id=' + id;
        });
    }

    /* ── ADD USER MODAL ─────────────────────────────────────────
       SweetAlert2 modal with 5 fields:
       Username | Password | Role | Security Question | Security Answer
       On confirm → validates input then redirects to AddUserServlet
       with all values as URL parameters. BCrypt hashing happens server-side. */
    function openAddUserModal() {
        var c = getColors();
        Swal.fire(Object.assign({}, getSwalBase(), {
            title: 'Add New User',
            html:
                '<div class="edit-field">' +
                    '<label style="color:' + c.muted + ';">Username</label>' +
                    '<input id="new-username" placeholder="Enter username" style="background:' + c.surface2 + ';border:1px solid ' + c.border + ';color:' + c.text + ';">' +
                '</div>' +
                '<div class="edit-field">' +
                    '<label style="color:' + c.muted + ';">Password</label>' +
                    '<input id="new-password" type="password" placeholder="Enter password" style="background:' + c.surface2 + ';border:1px solid ' + c.border + ';color:' + c.text + ';">' +
                '</div>' +
                '<div class="edit-field">' +
                    '<label style="color:' + c.muted + ';">Role</label>' +
                    '<select id="new-role" style="background:' + c.surface2 + ';border:1px solid ' + c.border + ';color:' + c.text + ';padding:9px 12px;border-radius:7px;font-size:13.5px;font-family:DM Sans,sans-serif;outline:none;width:100%;">' +
                        '<option value="DONOR">Donor</option>' +
                        '<option value="ADMIN">Admin</option>' +
                    '</select>' +
                '</div>' +
                '<div class="edit-field">' +
                    '<label style="color:' + c.muted + ';">Security Question</label>' +
                    '<select id="new-sq" style="background:' + c.surface2 + ';border:1px solid ' + c.border + ';color:' + c.text + ';padding:9px 12px;border-radius:7px;font-size:13.5px;font-family:DM Sans,sans-serif;outline:none;width:100%;">' +
                        '<option value="pet">What was the name of your first pet?</option>' +
                        '<option value="city">What city were you born in?</option>' +
                        '<option value="mother">What is your mother\'s maiden name?</option>' +
                        '<option value="school">What was the name of your first school?</option>' +
                        '<option value="friend">What is the name of your childhood best friend?</option>' +
                    '</select>' +
                '</div>' +
                '<div class="edit-field" style="margin-bottom:0;">' +
                    '<label style="color:' + c.muted + ';">Security Answer</label>' +
                    '<input id="new-sa" placeholder="Enter answer" style="background:' + c.surface2 + ';border:1px solid ' + c.border + ';color:' + c.text + ';">' +
                '</div>',
            width: '480px',
            showCancelButton: true,
            confirmButtonText: 'Create User',
            cancelButtonText: 'Cancel',
            focusConfirm: false,
            preConfirm: function() {
                var username = document.getElementById('new-username').value.trim();
                var password = document.getElementById('new-password').value;
                var role     = document.getElementById('new-role').value;
                var sq       = document.getElementById('new-sq').value;
                var sa       = document.getElementById('new-sa').value.trim();
                // Client-side validation before redirecting
                if (!username || !password) {
                    Swal.showValidationMessage('Username and password are required');
                    return false;
                }
                if (password.length < 6) {
                    Swal.showValidationMessage('Password must be at least 6 characters');
                    return false;
                }
                if (!sa) {
                    Swal.showValidationMessage('Security answer is required');
                    return false;
                }
                // Redirect to AddUserServlet with all values as URL params
                window.location.href = 'addUser?username=' + encodeURIComponent(username) +
                    '&password='         + encodeURIComponent(password) +
                    '&role='             + role +
                    '&security_question='+ encodeURIComponent(sq) +
                    '&security_answer='  + encodeURIComponent(sa);
            }
        }));
    }

    /* ── DELETE USER ────────────────────────────────────────────
       Client-side guard: if username matches currently logged-in admin,
       show error and stop immediately (no redirect).
       Otherwise show warning confirmation, then redirect to DeleteUserServlet
       which also checks server-side and cascades deletion of all donations. */
    function confirmDeleteUser(id, username, currentAdmin) {
        var c = getColors();
        // Prevent self-deletion (client-side check)
        if (username === currentAdmin) {
            Swal.fire(Object.assign({}, getSwalBase(), {
                title: 'Cannot Delete',
                text: 'You cannot delete your own account.',
                icon: 'error', iconColor: '#ff4f5e',
            }));
            return;
        }
        Swal.fire(Object.assign({}, getSwalBase(), {
            title: 'Delete User?',
            html: '<p style="color:' + c.text2 + ';">This will permanently remove <strong style="color:' + c.text + ';">' + username + '</strong> and all their donation records.</p>',
            icon: 'warning',
            iconColor: '#ff4f5e',
            showCancelButton: true,
            confirmButtonColor: '#ff4f5e',
            confirmButtonText: 'Yes, Delete',
            cancelButtonText: 'Cancel',
        })).then(function(r) {
            if (r.isConfirmed) window.location.href = 'deleteUser?id=' + id;
        });
    }

    /* ── URL MESSAGE HANDLER ────────────────────────────────────
       After servlet redirects back with ?msg=X, show the matching
       SweetAlert2 notification. Then clean the URL using replaceState
       so refreshing the page doesn't re-show the alert. */
    var urlParams = new URLSearchParams(window.location.search);
    if(urlParams.get('msg') === 'has_donations') Swal.fire(Object.assign({}, getSwalBase(), {title:'Cannot Delete', text:'This campaign has existing donations and cannot be removed.', icon:'error', iconColor:'#ff4f5e'}));
    if(urlParams.get('msg') === 'added')         Swal.fire(Object.assign({}, getSwalBase(), {title:'Campaign Created', text:'The new campaign is now live.', icon:'success', iconColor:'#00c96e'}));
    if(urlParams.get('msg') === 'updated')       Swal.fire(Object.assign({}, getSwalBase(), {title:'Changes Saved', text:'Campaign updated successfully.', icon:'success', iconColor:'#00c96e'}));
    if(urlParams.get('msg') === 'toggled')       Swal.fire(Object.assign({}, getSwalBase(), {title:'Status Updated', text:'Campaign status has been changed.', icon:'success', iconColor:'#00c96e'}));
    if(urlParams.get('msg') === 'user_added')    Swal.fire(Object.assign({}, getSwalBase(), {title:'User Created', text:'New user account has been created.', icon:'success', iconColor:'#00c96e'}));
    if(urlParams.get('msg') === 'user_deleted')  Swal.fire(Object.assign({}, getSwalBase(), {title:'User Deleted', text:'The user has been removed.', icon:'success', iconColor:'#00c96e'}));
    if(urlParams.get('msg') === 'user_exists')        Swal.fire(Object.assign({}, getSwalBase(), {title:'Username Taken', text:'That username already exists.', icon:'error', iconColor:'#ff4f5e'}));
    if(urlParams.get('msg') === 'cannot_self_delete') Swal.fire(Object.assign({}, getSwalBase(), {title:'Cannot Delete', text:'You cannot delete your own account.', icon:'error', iconColor:'#ff4f5e'}));
    // Clean URL after showing alert so page refresh doesn't re-trigger it
    if(urlParams.has('msg')) window.history.replaceState({}, document.title, window.location.pathname);

    /* ── AUTO-OPEN SECTION FROM URL ─────────────────────────────
       If URL has ?section=users (set by AddUserServlet/DeleteUserServlet
       redirects), automatically open that section instead of default. */
    var sectionParam = urlParams.get('section');
    if(sectionParam) showSection(sectionParam);
</script>
</body>
</html>