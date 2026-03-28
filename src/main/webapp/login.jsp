<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | Palestine Relief</title>

    <%-- Google Fonts: Lora (headings) + DM Sans (body text) --%>
    <link rel="preconnect" href="https://fonts.googleapis.com">

    <%-- SweetAlert2: used for success notification after registration --%>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

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

        /* ── GLOBAL COLOR TOKENS ─────────────────────────────── */
        :root {
            --green:     #1db954;
            --green-dim: rgba(29,185,84,0.12);
            --red:       #e63946;
            --gold:      #f4a261;
        }

        /* ── BODY ───────────────────────────────────────────────
           Centered vertically and horizontally.
           ::before = subtle green/gold radial gradient glow
           ::after  = large Palestine flag watermark (opacity 3%) */
        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background .25s, color .25s;
            position: relative;
            overflow: hidden;
        }
        body::before {
            content: '';
            position: fixed; inset: 0;
            background-image:
                radial-gradient(circle at 20% 30%, rgba(29,185,84,0.06) 0%, transparent 50%),
                radial-gradient(circle at 80% 70%, rgba(244,162,97,0.04) 0%, transparent 50%);
            pointer-events: none;
        }
        body::after {
            content: '🇵🇸';
            position: fixed; bottom: -40px; right: -20px;
            font-size: 220px; opacity: .03;
            pointer-events: none;
            transform: rotate(-12deg);
        }

        /* ── THEME TOGGLE BUTTON ────────────────────────────────
           Fixed top-right. Shows moon/sun emoji.
           Calls toggleTheme() to swap dark/light. */
        .theme-btn {
            position: fixed; top: 20px; right: 20px;
            width: 36px; height: 36px; border-radius: 9px;
            background: var(--surface); border: 1px solid var(--border);
            cursor: pointer; font-size: 16px;
            display: flex; align-items: center; justify-content: center;
            transition: border-color .2s, background .25s;
            z-index: 10;
        }
        .theme-btn:hover { border-color: var(--green); }

        /* ── LOGIN CARD ─────────────────────────────────────────
           Centered white/dark card containing the login form.
           Max-width 400px. Fades in with fadeUp animation. */
        .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 40px 36px;
            width: 100%;
            max-width: 400px;
            box-shadow: 0 8px 40px var(--shadow);
            position: relative;
            animation: fadeUp .45s ease both;
            transition: background .25s, border-color .25s;
        }

        /* ── BRAND ──────────────────────────────────────────────
           "Palestine Relief" brand name centered at top of card */
        .brand {
            display: flex; align-items: center; gap: 10px;
            justify-content: center; margin-bottom: 28px;
        }
        .brand-icon {
            width: 38px; height: 38px; border-radius: 10px;
            background: var(--green-dim); border: 1px solid rgba(29,185,84,0.25);
            display: flex; align-items: center; justify-content: center;
            font-size: 19px;
        }
        .brand-name { font-family: 'Lora', serif; font-size: 19px; font-weight: 600; }
        .brand-name span { color: var(--green); }

        /* ── CARD TITLE AND SUBTITLE ────────────────────────────
           "Welcome back" heading + "Sign in to your donor account" sub */
        .card-title { font-family: 'Lora', serif; font-size: 22px; font-weight: 600; text-align: center; margin-bottom: 4px; }
        .card-sub   { font-size: 13px; color: var(--muted); text-align: center; margin-bottom: 28px; }

        /* ── FORM FIELDS ────────────────────────────────────────
           Standard label + input pairs with green focus ring */
        .field { display: flex; flex-direction: column; gap: 6px; margin-bottom: 14px; }
        .field label { font-size: 11.5px; font-weight: 600; text-transform: uppercase; letter-spacing: .7px; color: var(--muted); }
        .field input {
            background: var(--surface2);
            border: 1px solid var(--border);
            color: var(--text);
            padding: 11px 14px;
            border-radius: 8px;
            font-size: 14px;
            font-family: inherit;
            outline: none;
            transition: border-color .18s, box-shadow .18s, background .25s;
            width: 100%;
        }
        .field input::placeholder { color: var(--muted); }
        .field input:focus { border-color: var(--green); box-shadow: 0 0 0 3px rgba(29,185,84,0.1); }

        /* ── PASSWORD SHOW/HIDE TOGGLE ──────────────────────────
           Eye button positioned inside the password input field.
           Clicking calls togglePw() to switch type="password"/"text". */
        .pw-wrap { position: relative; }
        .pw-wrap input { padding-right: 40px; }
        .pw-eye {
            position: absolute; right: 12px; top: 50%;
            transform: translateY(-50%);
            cursor: pointer; font-size: 15px; opacity: .5;
            transition: opacity .18s; user-select: none;
            background: none; border: none; padding: 0;
        }
        .pw-eye:hover { opacity: 1; }

        /* ── SUBMIT BUTTON ──────────────────────────────────────
           Full-width green button. Submits POST to LoginServlet. */
        .btn-submit {
            width: 100%; background: var(--green); color: #051a0d;
            border: none; padding: 12px; border-radius: 8px;
            font-size: 14.5px; font-weight: 700; cursor: pointer;
            font-family: inherit; letter-spacing: .2px;
            transition: opacity .18s, transform .1s;
            margin-top: 4px;
        }
        .btn-submit:hover  { opacity: .88; transform: translateY(-1px); }
        .btn-submit:active { transform: translateY(0); }

        /* ── ERROR BOX ──────────────────────────────────────────
           Red box shown when LoginServlet redirects back with ?error=1
           (wrong username or password).
           Shakes on appear to draw attention. */
        .error-box {
            display: flex; align-items: center; gap: 8px;
            background: rgba(230,57,70,0.08);
            border: 1px solid rgba(230,57,70,0.25);
            border-radius: 8px; padding: 10px 14px;
            margin-bottom: 16px;
            animation: shake .35s ease;
        }
        .error-box span { font-size: 13px; color: var(--red); }

        /* ── CARD FOOTER ────────────────────────────────────────
           "Don't have an account? Create one free" → register.jsp
           "Forgot your password?" → forgot_password.jsp */
        .card-footer { text-align: center; margin-top: 20px; font-size: 13px; color: var(--muted); }
        .card-footer a { color: var(--green); text-decoration: none; font-weight: 500; }
        .card-footer a:hover { text-decoration: underline; }
        .divider { display: flex; align-items: center; gap: 10px; margin: 20px 0; color: var(--muted); font-size: 12px; }
        .divider::before, .divider::after { content: ''; flex: 1; height: 1px; background: var(--border); }

        /* ── ANIMATIONS ─────────────────────────────────────────
           fadeUp: card appears with upward slide on page load
           shake: error box shakes when it appears */
        @keyframes fadeUp { from{opacity:0;transform:translateY(16px);}to{opacity:1;transform:none;} }
        @keyframes shake  { 0%,100%{transform:translateX(0);}25%{transform:translateX(-6px);}75%{transform:translateX(6px);} }
    </style>
</head>
<body>

<%-- Theme toggle: fixed top-right button --%>
<button class="theme-btn" onclick="toggleTheme()" id="themeBtn">🌙</button>

<div class="card">

    <%-- Brand name at top of card --%>
    <div class="brand">
        <div class="brand-name">Palestine <span>Relief</span></div>
    </div>

    <div class="card-title">Welcome back</div>
    <div class="card-sub">Sign in to your donor account</div>

    <%-- ── ERROR BOX ────────────────────────────────────────────
         Shown when LoginServlet redirects back with ?error=1
         This happens when username is not found or password is wrong.
         LoginServlet uses BCrypt.checkpw() — never plain text compare. --%>
    <% if("1".equals(request.getParameter("error"))) { %>
    <div class="error-box">
        <span>Invalid username or password. Please try again.</span>
    </div>
    <% } %>

    <%-- ── LOGIN FORM ────────────────────────────────────────────
         Submits POST to LoginServlet (/login).
         LoginServlet fetches user by username, verifies password
         with BCrypt.checkpw(), stores User in session, then redirects:
           ADMIN → admin_dashboard.jsp
           DONOR → donor_dashboard.jsp --%>
    <form action="login" method="post">

        <%-- Username field --%>
        <div class="field">
            <label>Username</label>
            <input type="text" name="username" placeholder="Enter your username"
                   required autocomplete="username">
        </div>

        <%-- Password field with show/hide eye toggle --%>
        <div class="field">
            <label>Password</label>
            <div class="pw-wrap">
                <input type="password" name="password" id="pwInput"
                       placeholder="Enter your password"
                       required autocomplete="current-password">
                <%-- Eye button: calls togglePw() to show/hide password --%>
                <button type="button" class="pw-eye" onclick="togglePw()" id="pwEye">👁️</button>
            </div>
        </div>

        <button type="submit" class="btn-submit">Sign In</button>

        <%-- Forgot password link → forgot_password.jsp (Step 1) --%>
        <div style="text-align:center;margin-top:12px;">
            <a href="forgot_password.jsp"
               style="font-size:12.5px;color:var(--muted);text-decoration:none;transition:color .18s;"
               onmouseover="this.style.color='var(--green)'"
               onmouseout="this.style.color='var(--muted)'">
                Forgot your password?
            </a>
        </div>
    </form>

    <div class="divider">or</div>

    <%-- Link to registration page for new users --%>
    <div class="card-footer">
        Don't have an account? <a href="register.jsp">Create one free</a>
    </div>

</div>

<script>
    var html = document.documentElement;

    /* ── THEME ──────────────────────────────────────────────────
       On load: read saved theme from localStorage (default: dark).
       Shares 'donorTheme' key with all other pages so theme stays
       consistent across index, login, register, dashboard, etc. */
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

    /* ── PASSWORD SHOW/HIDE ─────────────────────────────────────
       Toggles password input between type="password" and type="text".
       Eye emoji changes to closed eye when password is visible. */
    function togglePw() {
        var input = document.getElementById('pwInput');
        var eye   = document.getElementById('pwEye');
        var isHidden = input.type === 'password';
        input.type   = isHidden ? 'text' : 'password';
        eye.textContent = isHidden ? '🙈' : '👁️';
    }

    /* ── POST-REGISTRATION SUCCESS ALERT ────────────────────────
       After RegisterServlet successfully creates an account,
       it redirects to login.jsp?msg=registered.
       This shows a SweetAlert2 success modal welcoming the new user.
       URL is cleaned after so refresh doesn't re-show the alert. */
    (function() {
        var params = new URLSearchParams(window.location.search);
        if (params.get('msg') === 'registered') {
            var isDark = document.documentElement.getAttribute('data-theme') === 'dark';
            Swal.fire({
                background: isDark ? '#13171f' : '#ffffff',
                color:      isDark ? '#e6e8f0' : '#181c2a',
                icon: 'success',
                iconColor: '#1db954',
                title: 'Account Created! 🎉',
                html: '<p style="font-size:14px;line-height:1.6;">Welcome to Palestine Relief.<br>Please sign in to continue.</p>',
                confirmButtonColor: '#1db954',
                confirmButtonText: 'Sign In',
            });
            // Clean URL so refreshing doesn't re-show the alert
            window.history.replaceState({}, document.title, window.location.pathname);
        }
    })();
</script>
</body>
</html>